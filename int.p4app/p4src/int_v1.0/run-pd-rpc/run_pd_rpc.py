#!/usr/bin/python

# Copyright 2017-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

"""
Runner for PD
"""
try:
    import logging
    logging.basicConfig(format="%(levelname)s: %(message)s", level="WARNING")
except:
    print("  ERROR: Cannot import the required logging module")
    exit(1)
    
try:
    import sys
    import os
    import argparse
    import code
    import importlib
    import atexit
    import inspect
    import traceback
    import struct
    import subprocess
    import re
    import pdb
    import time
    import copy
    import threading

except:
    logging.error(
"""Failed to load one or more of the following modules:

       os, sys, argparse, code, importlib, atexit, inspect, traceback, struct
       subprocess, re, pdb, time, copy, threading

       These are standard Python modules and must be available.
       Please, check your Python installation.
""")
    sys.exit(1)

# Thrift modules. They are mandatory
try:
    from thrift.transport import TSocket
    from thrift.transport import TTransport
    from thrift.protocol  import TBinaryProtocol
    from thrift.protocol  import TMultiplexedProtocol
except:
    logging.error(
"""Failed to load Thrift modules.
       Please, check your Thrift installation
""")
    sys.exit(1)

# Scapy is optional, but might be quite useful. e.g. to form packets for the
# packet generator. It can also allow you to send packets directly from the
# tool, but to do that you need to rnu as root.
#
# The main drawback of importing scapy is that it adds a lot of symbols to the
# global namespace, making autocompletion a little less useful.
#
#try:
#    from scapy.all import *
#    for proto in ["igmp", "vxlan", "mpls", "erspan", "vxlan", "bfd", "nvgre"]:
#        load_contrib(proto)
#except:
#    logging.warning("Scapy is not available. This is OK if you don't need it")

#
# Autocompletion. We offer a choice between jedi and rlcompleter
try:
    import readline
    readline_support = True
except:
    readline_support = False
    logging.warning(
"""readline module is not available. The tool will work,
         but command history wil not be saved
""")

try:
    from jedi.utils import setup_readline
    autocompleter_support = "jedi"
    import jedi.settings
    jedi.settings.case_insensitive_completion=False
    readline_support = True
except ImportError:
    try:
        import rlcompleter
        autocompleter_support = "rlcompleter"
    except:
        autocompleter_support = None
        logging.warning(
"""jedi or rlcompleter modules are not available.
         The tool will work, but there will be no autocompletion
""")
        
dev         = 0
allpipes    = None
allports    = []
sess_hdl    = None
pkt_sess    = None
mc_sess     = None

from_hw     = None  # Total hack. Will be set to p4_pd.counter_flags(True)  
from_sw     = None  # Total hack. Will be set to p4_pd.counter_flags(True)

import_done = False
bprotocols  = {}
show_trace  = False # Do not show full trace on exceptions

def import_star(module_name):
    """This function implements the equivalent of 

       from module_name import *

    The advantages are that module_name can be a string, computed at runtime
    and that it can be called from within a function
    """

    global import_done
    
    try:
        mod = importlib.import_module(module_name)
    except:
        logging.error("Cannot load module {}".format(module_name))
        raise ImportError
    
    for sym in dir(mod):
        if sym[0:2] != "__":
            globals()[sym]=mod.__dict__[sym]

    if not import_done:
        logging.info("from {:<20s} import *".format(module_name))

def wrap_api(func, first_args):
    """
    Parameters:
       - func       -- the function to wrap
       - first_args -- a list of tuples in the form of 
                       ("parameter_name", "global_var") that indicate which 
                       parameters need to become optional and how they will
                       get replaced
    Returns:
       - a new (wrapped) function

    Example:
       Convert a function
          mc.mgrp_create(sess_hdl, dev_id, mgrp) 
       into 
          mc.mgrp_create(mgrp, sess_hdl=mc_sess, dev_id=dev)
      
       mc.mgrp_create = wrap_api(mc.mgrp_create, 
                                 [("sess_hdl", "mc_sess"), ("dev_id", "dev")])
    """

    def wrapper(*args, **kwargs):
        new_args=()
        for (arg_name, arg_val) in first_args:
            if arg_name in kwargs.keys():
                new_args = new_args +  (kwargs[arg_name],)
                del(kwargs[arg_name])
            else:
                new_args = new_args + (globals()[arg_val],)
        args = new_args + args
        return func(*args, **kwargs)
    #
    # And now let's fix the name and the docstring
    #
    result = wrapper
    result.__name__ = func.__name__
    result.__module__ = func.__module__
    
    d = func.__doc__.split("\n")
    for (arg_name, arg_val) in first_args:
        for s in d:
            if re.search(arg_name, s):
                d.remove(s)
                d.append(s + "=" + arg_val)
                break
    result.__doc__  = "\n".join(d)
    return result

def apis_convert(obj, sess_hdl_name="sess_hdl"):
    #
    # Experimental code to munge most of the APIs to remove the need to specify
    # sess_hdl and dev_id/dev_tgt
    #
    for f in dir(obj):
        func = getattr(obj, f)
        if not inspect.isroutine(func):
            continue
        
        a = inspect.getargspec(func)
        new_args = []
        for arg in a.args[1:]:
            if arg == 'sess_hdl':
                new_args.append((arg, sess_hdl_name))
            elif (arg == 'dev_id' or
                  arg == 'device_id' or
                  arg == 'dev' or
                  arg == 'device'):
                new_args.append((arg, "dev"))
            elif arg == 'dev_tgt':
                new_args.append((arg, "allpipes"))
        if len(new_args) > 0:
            setattr(obj, f, wrap_api(func, new_args))
                                          
def mc_apis_convert(obj):
    return apis_convert(obj, sess_hdl_name="mc_sess")

def pkt_apis_convert(obj):
    return apis_convert(obj, sess_hdl_name="pkt_sess")

#
# Common functions to simplify command parameter handling with the wrapped
# APIs
#
def api_common_args_dev(session_handle=None, device_id=None):
    """
    Handling of the common sess_hdl and device_id parameters in most
    commands. If they are provided, use them, otherwise default to sess_hdl
    and dev
    """
    if session_handle is None:
        session_handle = sess_hdl
    if device_id is None:
        device_id      = dev
    return session_handle, device_id

def api_common_args(session_handle=None, device_target=None):
    """
    Handling of the common sess_hdl and device_target parameters in most
    commands. If they are provided, use them, otherwise default to sess_hdl
    and allpipes
    """
    if session_handle is None:
        session_handle = sess_hdl
    if device_target is None:
        device_target  = allpipes
    return session_handle, device_target

def mc_common_args(session_handle=None, device_id=None):
    """
    Handling of the common sess_hdl and device_id parameters in Multicast
    commands. If they are provided, use them, otherwise default to mc_sess
    and dev
    """
    if session_handle is None:
        session_handle = mc_sess
    if device_id is None:
        device_id = dev
    return session_handle, device_id

def limit_count(count, on_device):
    """
    Handling of the optional "count" parameter, common in many commands.
    
    Parameters:
      - count     -- desired number of elements
      - on_device -- number of elements on device
 
    If count is None or 0 return what's on device
    If count > 0 use count, unless it is more than what's on device. 
    If count < 0 that means "abs(count) less than what's on device

    Typical usage: 
       count = limit_count(count, mc.mgrp_get_count())
    """
    if count is None:
        return on_device
    elif count > 0:
        return min(count, on_device)
    else:
        return max(on_device + count, 0)


class bfThrift( object ):
    """
    A class to create Thrift connection, Barefoot-style
    """
    def __init__( self, port, module, api_name,
                  multiplexed=True, thrift_ip='localhost',
                  prefix=None, bound_func=True, var_name=None,
                  type_prefix=None, api_convert=apis_convert):
        """
        This class opens a Thrift connection to the already running bf-sde
        shell and imports a particular the Thrift module.

        Methods users will use are available as self.func where function name
        has the Thrift module prefix removed.

        The original thrift module is placed in self.thrift
        TTypes  are placed in self.ttypes
        Constand are placed in self.const

        port        : (int) TCP port like 9090
        module      : (str) Thrift module name
        api_name    : (str) API name
        multiplexed : (bool) True if a port is shared between a few clients
                        This setting needs to match server side setting
        thrift_ip   : (str) Host name
        prefix      : (str) Prefix in front of Thrift function name to
                        remove.  If not specified, api_name will be used
        bound_func  : (bool) True will bind Thrift func (under self.thrift)
                        to self to hide Thrift functions.  Use False if func
                        bounding requires additional manipulation.
        var_name    : the name of the variable we'll assign to (for diagnostic)
        type_prefix : in some cases (switchAPI) type names have different prefix
                      than API functtions themselves :( Moreover, it can vary
                      (e.g. switcht_ or switct_api_).
        api_convert : An optional function to simplify APIs by making initial 
                      common parameters optional
        """
        #
        # Open Thrift connection if we haven't done it before
        #
        global bprotocols
        global import_done

        # print("Importing", module, api_name)
        
        if port not in bprotocols.keys():
            transport=TSocket.TSocket(thrift_ip, port)
            transport=TTransport.TBufferedTransport(transport)
            try:
                transport.open()
                bprotocols[port] = TBinaryProtocol.TBinaryProtocol(transport)
            except:
                raise IOError(
                    'Cannot connect to Thrift Server at {}:{}'.format(
                        thrift_ip, port))

        elif not multiplexed:
            logging.error(
                'Aready connected to port {} using a different protocol'.
                format(port))

        bprotocol = bprotocols[port]

        if prefix == None:
            prefix = api_name

        #
        # Import API functions
        #
        mod = importlib.import_module('.'.join([module, api_name]))
        if multiplexed:
            proto = TMultiplexedProtocol.TMultiplexedProtocol(bprotocol, api_name)
        else:
            proto = bprotocol

        self.thrift = mod.Client(proto)
        
        # Bind only user methods to the class, not Thrift methods
        method_list = inspect.getmembers( self.thrift, inspect.ismethod )
        method_dict = dict(method_list)
        
        for (m_name, m_ref) in method_list:
            if m_name.startswith(prefix + "_"):
                setattr(self, m_name[len(prefix)+1:], m_ref)
            elif m_name.startswith("send_") or m_name.startswith("recv_"):
                if m_name[5:] in method_dict:
                    continue # This is an internal Thrift func
            else:
                setattr(self, m_name, m_ref)

        if not args.no_api_convert:
            if api_convert is not None:
                api_convert(self)
        
        #
        # Import API types and constants to add to self.ttypes and self.const
        # (remove prefix) from the beginning
        #

        # Create basic object self.ttypes to hold Thrift TTypes objects
        # self.ttypes = type( 'bfThrift_ttypes', (), {} )
        pd_t = importlib.import_module(".".join([module, "ttypes"]))

        if type_prefix is None:
            type_prefix = prefix
        tp = re.compile(type_prefix + "_")
            
        for t in dir(pd_t):
            m = re.match(tp,t)
            if m is not None:
                # setattr( self.ttypes, t[m.span()[1]:], pd_t.__dict__[t])
                setattr(self, t[m.span()[1]:], pd_t.__dict__[t])
            elif not t.startswith("__"):
                setattr(self, t, pd_t.__dict__[t])
        
        # Create basic object self.const to hold Thrift constants objects
        # self.const = type( 'bfThrift_const', (), {} )
        pd_c = importlib.import_module(".".join([module, "constants"]))
        for t in dir(pd_c):
            if t in [ TType, TMessageType, TException, TApplicationException ]:
                continue
            try:
                if getattr(pd_t, t) is not None:
                    continue # Already imported from ttypes
            except:
                pass
            
            if t.startswith(prefix + "_"):
                # setattr( self.const, t[len(prefix) + 1:], pd_t.__dict__[t])
                setattr(self, t[len(prefix) + 1:], pd_c.__dict__[t])
            elif not t.startswith("__"):
                setattr(self, t, pd_c.__dict__[t])

        # print("Imported constants")
        #
        # Print Usage Info, but only if we do not have an
        # established session
        #
        if not import_done:
            logging.info("Use {:<20s} to access {} APIs".
                  format(var_name if var_name != None else api_name, api_name))

    reserved_names = [
        "TApplicationException", "TBinaryProtocol", "TException",
        "TMessageType", "TProtocol", "TTransport", "TType",
        "fastbinary", "res_pd_rpc", "thrift" ]
    
    #
    # This custom implementation of __dir__ method filters out all reserved
    # and thrift-related attributes in order to make autocompletion easier
    #
    def __dir__(self):
        
        return [x for x in self.__dict__
                if (not x.startswith("__") and not x in self.reserved_names) ]
    
        
def open_session():
    global sess_hdl
    global pkt_sess
    global mc_sess
    
    if sess_hdl is None:
        sess_hdl = conn_mgr.client_init()
        logging.info("Opened PD  API Session (sess_hdl): {}".
              format(sess_hdl))
    else:
        if show_trace:
            logging.info("Continue PD  API Session (sess_hdl): {}".
                  format(sess_hdl))

    if not args.no_mc:
        if mc_sess is None:
            mc_sess = mc.create_session()
            logging.info("Opened MC  API Session (mc_sess) : {:#08x}".
                  format(mc_sess))
        else:
            if show_trace:
                logging.info("Continue MC  API Session (mc_sess) : {:#08x}".
                      format(mc_sess))
                
    if TARGET == "asic" or TARGET == "asic-model":
        if pkt_sess is None:
            pkt.init()
            pkt_sess = pkt.client_init()
            logging.info("Opened PKT API Session (pkt_sess): {}\n".
                  format(pkt_sess))
        else:
            if show_trace:
                logging.info("Continue PKT API Session (pkt_sess): {}".
                      format(pkt_sess))
    
@atexit.register
def close_session():
    try:
        if sess_hdl is not None:
            logging.info("Closing session {}".format(sess_hdl))
            conn_mgr.client_cleanup()
        
        if mc_sess is not None:
            logging.info("Closing MC API session {:#08x}".format(mc_sess))
            mc.destroy_session()
        
        if pkt_sess is not None:
            logging.info("Closing Packet Manager Session {}".format(pkt_sess))
            pkt.client_cleanup()
            pkt.cleanup()
    except:
        pass

        
def import_common_apis():
    global p4_pd
    global conn_mgr
    global mc
    global tm
    global sd
    global devport
    global pal
    global pkt
    global knet
    global pm
    global plcmt
    global mirror
    global from_sw
    global from_hw
    global pktgen
    
    # Import common Thrift routines like hex_to_i16()
    try:
        import_star("ptf.thriftutils")
    except:
        sys.exit(1)
        
    # Import Common types for PD APIs, like DevTarget()
    try:
        import_star("res_pd_rpc.ttypes")
    except:
        print("      Make sure your SDE is built for {} target".
              format(TARGET))
        sys.exit(1)
        
    # Import Port Mapping functions
    try:
        import_star("port_mapping")
    except:
        logging.warning(
"""Cannot load port_mapping module.
         Port mapping functions will not be available
""")

    if PROG != None:
        p4_pd    = bfThrift(port        = 9090,
                            thrift_ip   = args.thrift_ip,
                            module      = ".".join([PROG, "p4_pd_rpc"]),
                            api_name    = PREFIX,
                            var_name    = "p4_pd")

        # The problem: table APIs accept True/False, while counter APIs want
        # p4_pd.counter_flags_t() and do not accept True/False. Same is true
        # for the register APIs: officially they want p4_pd.register_flags_t().
        # Fortunately, they do not really care and so EVERYONE (even tables)
        # accept p4_pd.counter_flags_t. So that's what we'll use.
        # Yes, this is a hack
    
        from_hw = p4_pd.counter_flags_t(True)
        from_sw = p4_pd.counter_flags_t(False)
    
    conn_mgr = bfThrift(port        = 9090,
                        thrift_ip   = args.thrift_ip,
                        module      = "conn_mgr_pd_rpc",
                        api_name    = "conn_mgr")

    mc       = bfThrift(port        = 9090,
                        thrift_ip   = args.thrift_ip,
                        module      = "mc_pd_rpc",
                        api_name    = "mc",
                        api_convert = mc_apis_convert)
    
    tm       = bfThrift(port        = 9090,
                        thrift_ip   = args.thrift_ip,
                        module      = "tm_api_rpc",
                        api_name    = "tm")
    
    devport  = bfThrift(port        = 9090,
                        thrift_ip   = args.thrift_ip,
                        module      = "devport_mgr_pd_rpc",
                        api_name    = "devport_mgr",
                        var_name    = "devport")
    
    if TARGET == "asic" or TARGET == "asic-model":
        knet     = bfThrift(port        = 9090,
                            thrift_ip   = args.thrift_ip,
                            module      = "knet_mgr_pd_rpc",
                            api_name    = "knet_mgr",
                            prefix      = "knet",
                            var_name    = "knet")
    
        pal    = bfThrift(9090, "pal_rpc",          "pal",
                          thrift_ip=args.thrift_ip)
        
        pkt    = bfThrift(9090, "pkt_pd_rpc",       "pkt",
                          thrift_ip=args.thrift_ip,
                          api_convert = pkt_apis_convert)
        plcmt  = bfThrift(9090, "plcmt_pd_rpc",     "plcmt",
                          thrift_ip=args.thrift_ip)
        mirror = bfThrift(9090, "mirror_pd_rpc",    "mirror",
                          thrift_ip=args.thrift_ip)

        pktgen = PktGen(conn_mgr)
        if not import_done:
            logging.info("Use {:<20s} to access {} APIs\n".
                  format("pktgen", "pktgen(conn_mgr)"))

    if TARGET == "asic":
        sd     = bfThrift(9090, "sd_pd_rpc",        "sd",
                          thrift_ip=args.thrift_ip)
        try:
            pm = bfThrift(port        = 9090,
                          thrift_ip   = args.thrift_ip,
                          module      = "pltfm_pm_rpc",
                          api_name    = "pltfm_pm_rpc",
                          prefix      = "pltfm_pm",
                          var_name    = "pm")
        except IOError as e:
            logging.warning(
"""Platform Manager APIs are not available: %s
         Ignore this message if you are running against the
         asic-model or add '--target asic-model' to the
         command line to suppress this message
""", e.message)

    open_session()
    
def import_diag_apis():
    global diag

    try:
        diag = bfThrift(port         = 9096,
                        thrift_ip   = args.thrift_ip,
                        module       = "diag_rpc",
                        api_name     = "diag_rpc",
                        multiplexed  = False,
                        prefix       = "diag",
                        var_name     = "diag")
    except IOError as e:
        if show_trace:
            logging.warning("diagAPI is not available:", e.message)

def import_switch_apis():
    global switchapi
    global sai
    
    try:
        switchapi = bfThrift(port        = 9091,
                             thrift_ip   = args.thrift_ip,
                             module      = "switchapi_thrift",
                             api_name    = "switch_api_rpc",
                             prefix      = "switch_api",
                             multiplexed = False,
                             var_name    = "switchapi",
                             type_prefix = "switcht(_api)?")
        
        # Import constants from switch_api_headers module
        m = importlib.import_module("switchapi_thrift.switch_api_headers")
        for c in dir(m):
            if c.startswith("SWITCH_"):
                setattr(switchapi, c[7:], getattr(m, c))
            elif c.startswith("SFLOW_"): # A little workaround for a bug
                setattr(switchapi, c, getattr(m, c))
                
    except IOError as e:
        if show_trace:
            logging.warning("switchAPI is not available:", e.message)

    try:
        sai       = bfThrift(port        = 9092,
                             thrift_ip   = args.thrift_ip,
                             module      = "switchsai_thrift",
                             api_name    = "switch_sai_rpc",
                             prefix      = "sai_thrift",
                             multiplexed = False,
                             var_name    = "sai")
    except IOError as e:
        if show_trace:
            logging.warning("SAI is not available:", e.message)

def import_all_apis():
    global import_done
    
    try:
        import_common_apis()
    except Exception as e:
        print(
"""
        Failed to connect to Thrift Server for the common APIs
        (conn_mgr, PD, etc.)
        
        Here are common mistakes:
           -- Incorrect program NAME ({!s:})
              -- Make sure that the program exists
              -- Do not use .p4 suffix
              -- Do not use full path name 
           -- switchd process is not running
              -- Make sure you start it
           -- Thrift server is not running inside switchd
              --Make sure you compiled it with Thrift support enabled
           -- IP address ({}) is not correct
              -- If you are trying to connect to a remote host, check
                 connectivity
           -- Thrift port ({}) is not correct
              -- If you are using a different port, script needs to be modified
           -- You have too many open sessions
              -- restart switchd or use "--no-mc" parameter

        Check all of the above and try again
""".format(PROG, args.thrift_ip, 9090))
        print(e)
        raise e
    if PROG == "diag":
        import_diag_apis()
    if PROG == "switch":
        import_switch_apis()

    import_done = True

def reset_connection():
    global bprotocols

    for port in bprotocols:
        if show_trace:
            print("Resetting connection on port {}".format(port))
        bprotocols[port].trans.close()
        
    bprotocols={}
    import_all_apis()

def decode_error(err_str):
    bf_status_codes = [
        "Success",
        "Not ready",
        "No system resources",
        "Invalid arguments",
        "Already exists",
        "HW access fails",
        "Object not found",
        "Max sessions exceeded",
        "Session not found",
        "Not enough space",
        "Resource temporarily not available, try again later",
        "Initialization error",
        "Not supported in transaction",
        "Resource held by another session",
        "IO error",
        "Unexpected error",
        "Action data entry is being referenced by match entries",
        "Operation not supported",
        "Updating hardware failed",
        "No learning clients registered",
        "Idle time update state already in progress",
        "Device locked",
        "Internal error",
        "Table not found",
        "In use",
        "Object not implemented" ]
    
    pipe_mgr_status_codes = [
        "Success",
        "Not ready",
        "No system resources",
        "Invalid argument",
        "Already exists",
        "Communications failure",
        "Object not found",
        "Max sessions exceeded",
        "Session not found",
        "Table full",
        "Resource busy",
        "Initialization error",
        "API is not supported inside a transaction",
        "Table in use",
        "I/O error",
        "Unexpected error",
        "Entry still in use",
        "Operation is not supported",
        "Low-Level Driver Failure",
        "No learn clients",
        "Idle Timeout update in progress",
        "Device is busy",
        "Internal error",
        "Table doesn't exist"]

    try:
        m = re.search('Invalid(.*)Operation\(code=([0-9]+)\)', err_str)
        err_type = m.group(1)
        err_code = int(m.group(2))
        #
        # This is overcomplicated, but has to deal with the fact that different
        # components use their own error codes
        #
        if err_type == "Table":
            return pipe_mgr_status_codes[err_code]
        else:
            return bf_status_codes[err_code]
    except:
        return ""

def handle_traceback():
    global console_traceback

    bf_exceptions = [conn_mgr.InvalidConnMgrOperation,
                     conn_mgr.InvalidPktGenOperation,
                     devport.InvalidDevportMgrOperation,
                     mc.InvalidMcOperation,
                     tm.InvalidTmOperation,
                     pal.InvalidPalOperation]
    
    if PROG != None:
        bf_exceptions.extend([p4_pd.InvalidCounterOperation,
                     p4_pd.InvalidDbgOperation,
                     p4_pd.InvalidLearnOperation,
                     p4_pd.InvalidLPFOperation,
                     p4_pd.InvalidMeterOperation,
                     p4_pd.InvalidRegisterOperation,
                     p4_pd.InvalidSnapshotOperation,
                     p4_pd.InvalidTableOperation,
                     p4_pd.InvalidWREDOperation])

    if TARGET == "asic" or TARGET == "asic-model":
        bf_exceptions.extend([
            pkt.InvalidPktOperation,
            plcmt.InvalidPlcmtOperation])

    if TARGET == "asic":
        bf_exceptions.append(sd.InvalidSdOperation)

    type, value, tb = sys.exc_info()
    tblist = traceback.extract_tb(tb)

    if show_trace:
        print(type, value, tb)
        for tb_entry in tblist:
            print(tb_entry)
    
    #
    # This if() statement tries to analyze the exceptions for the number
    # of common problems
    #
    if  type in bf_exceptions:
        #
        # Ideally, we should use decode_error(value.code), but the
        # problem is that different components and their exceptions
        # use their own codes
        print("ERROR:", decode_error(repr(value)), "({:d})".format(value.code))
    elif type == AttributeError:
        filename, lineno, name, line = tblist[-1] # Check the last place
        if name == "write":
            if line.startswith("self.dev_tgt.write"):
                print(
"""
ERROR: This API requires dev_all()/dev_pipe(<pipe_num>), not dev_id()
""")
            elif line.startswith("self.dev_id.write"):
                print(
"""
ERROR: This API requires dev_id(), not dev_all()/dev_pipe()
""")
            elif line.startswith("self.match_spec.write"):
                print(
"""
ERROR: Incorrect type specified for the match_spec
       Use p4_pd.<table>_match_spec_t object
""")
            elif line.startswith("self.action_spec.write"):
                print(
"""
ERROR: Incorrect type specified for the action_spec
       Use p4_pd.<action>_action_spec_t object
""")
            elif line.startswith("self.flags.write"):
                print(
"""
ERROR: Incorrect type specified for the flags
       Use p4_pd.counter_flags_t() or p4_pd_register_flags_t() object. 
       You can also use predefined values "from_hw" and "from_sw" 
""")
            else:
                print("ERROR:", value)
        elif name == "writeByte":
            filename, lineno, name, line = tblist[-4] # Check the last place
            if name == "write" and line.find("dev_id") >= 0:
                print(
"""
ERROR: This API requires dev_id(), not dev_all()/dev_pipe()
""")
            else:
                print("ERROR:", value)
        elif name == "writeI32" and repr(value).find("DevTarget_t"):
            print(
"""
ERROR: This API requires dev_id(), not dev_all()/dev_pipe()
""")            
        else:
            print("ERROR:", value)   
    elif type == TypeError:
        print("ERROR:", value)
    elif type == struct.error:
        filename, lineno, name, line = tblist[-5] # Check the last place
        if name.find("write") >= 0:
            if line.startswith("self.match_spec.write"):
                print(
"""
ERROR: Match_spec contains values of incorrect types or some might be missing
       Please, use help(p4_pd.<table>_match_spec_t)
       Typical mistakes include:
          -- not using macAddr_to_string()   for MAC  addresses
          -- not using ipv4Addr_to_i32()     for IPv4 addresses
          -- not using ipv6Addr_to_string()  for IPv6 addresses   
          -- not using hex_to_byte()         for 8-bit  integers > 127 (0x7F)
          -- not using hex_to_i16()          for 16-bit integers > 32767
          -- not using hex_to_i32()          for 32-bit integers
""")
            elif line.startswith("self.action_spec.write"):
                print(
"""
ERROR: Action_spec contains values of incorrect types or some might be missing
       Please, use help(p4_pd.<action>_action_spec_t)
       Typical mistakes include:
          -- not using macAddr_to_string()   for MAC  addresses
          -- not using ipv4Addr_to_i32()     for IPv4 addresses
          -- not using ipv6Addr_to_string()  for IPv6 addresses   
          -- not using hex_to_byte()         for 8-bit  integers > 127 (0x7F)
          -- not using hex_to_i16()          for 16-bit integers > 32767
          -- not using hex_to_i32()          for 32-bit integers
""")
            else:
                print("ERROR:", value)
    else:
        console_traceback()

    # Let's look at the traceback.
    # If the exception was explicitly raised by the Thrift client binding
    # no need to do anything
    (filename, lineno, name, line) = tblist[-1]
    if line == "raise result.ouch":
        pass
    else:
        # If we can find calls to Thrift in there,
        # then we better reset the connection. Otherwise, there is no need to
        # do it
        for filename, lineno, name, line in tblist:
            if (filename.lower().find("thrift") > 0  or
                filename.lower().find("ttransport") > 0 or
                filename.lower().find("_pd") > 0 or
                (line is not None and (
                    line.lower().find("write(") > 0))):
                if show_trace:
                    print(
"""
Resetting Thrift Connection. Please, check that you
specified correct arguments to the API you attempted to execute
""")
                    reset_connection()
                    break
    
def dev_id(dev=None):
    if dev is None:
        return globals()["dev"]
    else:
        return dev
    
def setdev(device):
    global dev
    global allpipes
    global allports
    
    dev      = device
    allpipes = dev_all()

    allports = [pal.port_get_first()]
    while True:
        try:
            allports.append(pal.port_get_next(allports[-1]))
        except:
            break

    if PROG == None:
        sys.ps1="PD-Fixed[{:d}]>>> ".format(dev)
    elif PROG == PREFIX:
        sys.ps1="PD({!s:})[{:d}]>>> ".format(PROG, dev)
    else:
        sys.ps1="PD({:s}/{:s})[{:d}]>>> ".format(PROG, PREFIX, dev)
        

def dev_all(dev=None):
    return DevTarget_t(dev_id(dev), hex_to_i16(0xFFFF))

def dev_pipe(pipe, dev=None):
    return DevTarget_t(dev_id(dev), hex_to_i16(pipe))

def check_env():
    global SDE
    global SDE_INSTALL
    
    try:
        SDE = os.environ["SDE"]
    except KeyError:
        logging.error("SDE environment variable is not set")
        quit()

    try:
        SDE_INSTALL= os.environ["SDE_INSTALL"]
    except KeyError:
        logging.warning(
"""SDE_INSTALL environment variable is not set. 
         Assuming $SDE/install
""")
        SDE_INSTALL = "/".join([SDE, "install"])

    logging.info("Using         SDE %s", SDE)
    logging.info("Using SDE_INSTALL %s", SDE_INSTALL)

def parse_args():
    global PROG, PREFIX, TARGET
    global args
    
    parser=argparse.ArgumentParser("PD RPC Runner")

    parser.add_argument(
        "-p", "--program", 
        type=str,
        help="""
                The name of the P4 program (P4_NAME) to interface with.
                If empty, no PD APIs will be imported, but fixed APIs will be
             """)
    
    parser.add_argument(
        "-P", "--prefix",
        type=str,
        help="""
        PD API prefix (P4_PREFIX) if different from the program name
        By default it is the same as P4_NAME
        For P4_NAME "switch" P4_PREFIX is "dc"
        """)
    
    parser.add_argument(
        "-d", "--target-type",
        type=str.lower,
        choices=["asic", "asic-model", "hw"],
        #default="asic",
        help="""
        P4 Target:
            asic       -- Tofino device or its register-accurate model
            asic-model -- Register-accurate model
            hw         -- Real device
        """)
    
    parser.add_argument(
        "--thrift-ip",
        type=str,
        default="localhost",
        help="IP address or a hostname of the Thrift server")

    parser.add_argument(
        "--no-rcload", action='store_true',
        help="Do not load startup scripts even if present")

    parser.add_argument(
        "--no-wait", action='store_true',
        help="Do not wait for switchd to become ready")

    parser.add_argument(
        "--no-mc", action='store_true',
        help="Do not connect to MC Session (due to a limited number of those)")

    parser.add_argument(
        "-i", "--interact", action='store_true',
        help="Go into the interactive mode after executing the provided script. Ignored if no script is specified")

    parser.add_argument(
        "-e", "--eval",
        type=str,
        help="""
        Evaluate the provided code in the tool's context. 
        Note: for the ease of scripting standard help and info is not printed
        """)
    
    parser.add_argument(
        "--no-api-convert", action='store_true',
        help="Do not attempt to convert the APIs by making the common arguments optional")
    
    parser.add_argument(
        "script",
        type=str,
        nargs='?',
        help="A Python script to execute in the prepared context")
    
    args=parser.parse_args()

    if args.eval == None and args.script == None:
        args.interact = True
        
    if args.interact:
        logging.getLogger().setLevel("INFO")
        
    PROG   = args.program
    if PROG != None:
        if args.prefix == None:
            if PROG == "switch":
                PREFIX="dc"
            else:
                PREFIX = PROG
        else:
            PREFIX = args.prefix
    else:
        if args.prefix != None:
            logging.warning("No P4 program is specified, so prefix is ignored")
            PREFIX = None
            
    TARGET = args.target_type

    if TARGET == None:
        lsmod = subprocess.check_output('lsmod').decode("utf-8")
        if lsmod.find("bf_kdrv") == -1 and lsmod.find("bf_kpkt") == -1:
            TARGET="asic-model"
        else:
            TARGET="asic"
    else:
        TARGET=TARGET.lower()

    logging.info("Running on %s", TARGET)
    
def set_paths(install_dir):
    global SDE_PYPATH
    SDE_PYPATH = os.path.join(install_dir, "lib", "python2.7", "site-packages")
    sys.path.append(SDE_PYPATH)
    sys.path.append(os.path.join(SDE_PYPATH, "p4testutils"))
    if (TARGET == "asic" or
        TARGET == "hw"   or
        TARGET == "asic-model"):
        sys.path.append(os.path.join(SDE_PYPATH, "tofino"))
        sys.path.append(os.path.join(SDE_PYPATH, "tofinopd"))
    else:
        raise ValueError("Unknown target type")
    #
    # Prepend our own paths
    #
    sys.path.insert(0, os.path.expanduser(
        os.path.join('~', '.pd_rpc', 'rc')))
    sys.path.insert(0, os.path.expanduser(
        os.path.join('~', '.pd_rpc', 'rc', str(PROG))))

def wait_for_switchd():
    if TARGET == "asic" or TARGET == "asic-model":
        logging.info("Waiting for the target")
        subprocess.check_output(
            ["python",
             os.path.join(SDE_PYPATH,"p4testutils", "bf_switchd_dev_status.py"),
             "--host", args.thrift_ip,
             "--port", "7777"])
        logging.info("Connected to the target\n")
                     
#
# Load rc files
#
# This is tricky, since we want to load them as scripts, i.e. sequences
# of commands that will share the contents of the interpreter, not
# regular Python modules
#
def execscript(script):
    if not os.path.isabs(script):
        script = os.path.join(SCRIPT_DIR, script)
        
    cmd = """
try:
    fname="%s"
    execfile(fname)
    logging.info("Loaded {}".format(fname))
except Exception as e:
    print(e)
    quit()
"""
    console.runsource(cmd % script)
    
def rc_exec(c, rc_file):
    rc_cmd = """
try:
    fname="%s"
    execfile(fname)
    logging.info("Loaded {}".format(fname))
except IOError:
    pass
"""
    c.runsource(rc_cmd % (rc_file))

def rc_load(c):
    if not args.no_rcload:
        rc_file = os.path.expanduser(
            os.path.join("~", '.pd_rpc', '_rc_.py'))
        rc_exec(c, rc_file)
        rc_file = os.path.expanduser(
            os.path.join("~", '.pd_rpc', '_rc_', str(PROG), '_rc_.py'))
        rc_exec(c, rc_file)
    else:
        logging.info("Skipping loading rc files")
        
def run_shell(script):
    global console
    global console_traceback
    global SCRIPT_DIR

    setdev(0)
    # Tab completion
    if autocompleter_support == "jedi":
        setup_readline()
    elif autocompleter_support == "rlcompleter":
        if readline_support:
            readline.parse_and_bind("tab: complete")

    if readline_support:
        # History goes into $HOME/.pd_rpc/history/<PROG>
        histdir = os.path.join(os.environ['HOME'], '.pd_rpc', 'history')
        try:
            os.makedirs(histdir)
        except:
            pass
        
        histfile = os.path.join(histdir, str(PROG))
        try:
            readline.read_history_file(histfile)
        except IOError:
            pass
        
        atexit.register(readline.write_history_file, histfile)

    console = code.InteractiveConsole(globals())
    console_traceback = console.showtraceback
    console.showtraceback = handle_traceback

    show_trace = True  # Show full trace during script execution
    rc_load(console)
    if script is not None:
        # Add the directory that contains the script to PYTHONPATH
        # It allows easy importing of the other scripts from the same directory
        SCRIPT_DIR=os.path.dirname(os.path.realpath(script))
        sys.path.insert(0, SCRIPT_DIR)
        
        # Execute the script within the interactive console context
        execscript(os.path.basename(script))
    else:
        args.interact = True
        
    if args.interact==True:
        show_trace = False # Do not show full trace in interactive mode
        console.interact()

def history(lnum=False):
    """
    Print the history of the commands entered before. By default it just
    prints the commands for the ease of copy-paste. If lnum is True, it also
    prints line numbers
    """
    try:
        for i in range(1, readline.get_current_history_length()+1):
            if lnum:
                print("{:5d}: ".format(i), end="")
            print(readline.get_history_item(i))
    except:
        print("readline module is not available")

#############################################################################
#############################################################################
#############################################################################
#############################################################################

#
# Helper functions for Tofino. We could've put them into an rc file, but
# that would complicate shipping. If their number grows, we'll do something
#
def to_devport(pipe, port):
    """
    Convert a (pipe, port) combination into a 9-bit (devport) number
    NOTE: For now this is a Tofino-specific method
    """
    return pipe << 7 | port

def to_pipeport(dp):
    """
    Convert a physical 9-bit (devport) number into (pipe, port) pair
    NOTE: For now this is a Tofino-specific method
    """
    return (dp >> 7, dp & 0x7F)

def devport_to_mcport(dp):
    """
    Convert a physical 9-bit (devport) number to the index that is used by 
    MC APIs (for bitmaps mostly)
    NOTE: For now this is a Tofino-specific method
    """
    (pipe, port) = to_pipeport(dp)
    return pipe * 72 + port

def mcport_to_devport(mcport):
    """
    Convert a MC port index (mcport) to devport
    NOTE: For now this is a Tofino-specific method
    """
    return to_devport(mcport / 72, mcport % 72)

def devports_to_mcbitmap(devport_list):
    """
    Convert a list of devports into a Tofino-specific MC bitmap
    """
    bit_map = [0] * ((288 + 7) / 8)
    for dp in devport_list:
        mc_port = devport_to_mcport(dp)
        bit_map[mc_port / 8] |= (1 << (mc_port % 8))
    return bytes_to_string(bit_map)

def mcbitmap_to_devports(mc_bitmap):
    """
    Convert a MC bitmap of mcports to a list of devports
    """
    bit_map = string_to_bytes(mc_bitmap)
    devport_list = []
    for i in range(0, len(bit_map)):
        for j in range(0, 8):
            if bit_map[i] & (1 << j) != 0:
                devport_list.append(mcport_to_devport(i * 8 + j))
    return devport_list

def lags_to_mcbitmap(lag_list):
    """
    Convert a list of LAG indices to a MC bitmap
    """
    bit_map = [0] * ((256 + 7) / 8)
    for lag in lag_list:
        bit_map[lag / 8] |= (1 << (lag % 8))
    return bytes_to_string(bit_map)
    
def mcbitmap_to_lags(mc_bitmap):
    """
    Convert an MC bitmap into a list of LAG indices
    """
    bit_map = string_to_bytes(mc_bitmap)
    lag_list = []
    for i in range(0, len(bit_map)):
        for j in range(0, 8):
            if bit_map[i] & (1 << j) != 0:
                devport_list.append(i * 8 + j)
    return lag_list

#############################################################################
#
# Helper functions for PD APIs. Initially developed inside _rc_.py but moved
# here to ease shipping
#
#############################################################################

#
# Signed-Unsigned conversions
#
def i8(val):
    if -128 <= val and val <= 127:
        return val
    if 128 <= val and val <= 255:
        return val - 256
    raise ValueError

def u8(val):
    if -128 <= val and val <= -1:
        return 256 + val
    if 0 <= val and val <= 255:
        return val
    raise ValueError
    
def i16(val):
    if -32768 <= val and val <= 32767:
        return val
    if 32768 <= val and val <= 65535:
        return val - 65536
    raise ValueError

def u16(val):
    if -32768 <= val and val <= -1:
        return 65536 + val
    if 0 <= val and val <= 65535:
        return val
    raise ValueError
    
def i32(val):
    if -2147483648 <= val and val <= 2147483647:
        return val
    if 2147483648 <= val and val <= 4294967295:
        return val - 4294967296
    raise ValueError

def u32(val):
    if -2147483648 <= val and val <= -1:
        return 4294967296 + val
    if 0 <= val and val <= 4294967295:
        return val
    raise ValueError
    
#
# Dumping tables and other objects
#

def myrepr(value):
    if isinstance(value, int):
        # This is a little hacky, but not much we can do, given
        # the lack of clear type indications in Python and signed-only
        # types in Thrift
        #if -128 <= value and value <= 127:
        #    return "%d (0x%X)" % (u8(value), u8(value))
        #elif -32768 <= value and value <= 32767:
        #    return "%d (0x%X)" % (u16(value), u16(value))
        #else:
            return "%d (0x%X)" % (u32(value), u32(value))
    elif isinstance(value, str):
        return ':'.join('%02x' % ord(x) for x in value)
    else:
        return repr(value)
    
def print_priority(prio):
    print("Priority:    ", prio)

def print_match_spec(match_spec):
    print("Match Spec:")
    #
    # Filter out fields with _mask==0, since nobody cares
    #
    field_list = sorted(match_spec.__dict__.keys())
    filtered_field_list = list(field_list)
    for f in field_list:
        if hasattr(match_spec, f + "_mask"):
            mask = str(getattr(match_spec, f + "_mask"))
            if mask == "0"*len(mask) or mask == "\x00"*len(mask):
                filtered_field_list.remove(f)
                filtered_field_list.remove(f+"_mask")
                
    for f in filtered_field_list:
        print("    {:<30s} = {}".format(f, myrepr(getattr(match_spec, f))))

def print_action_desc(action_desc):
    print("Action:\n   ", action_desc.name)
    action_data_attr = "{}_{}".format(PREFIX, action_desc.name)
    if hasattr(action_desc.data, action_data_attr):
        action_data = getattr(action_desc.data, action_data_attr)
        if hasattr(action_data, "__dict__"):
            print("Action Data:")
            for f in sorted(action_data.__dict__.keys()):
                print("    {:<30s} = {}".
                      format(f[7:], myrepr(getattr(action_data, f))))
    
def print_entry(entry):
    if hasattr(entry, "priority"):
        print_priority(entry.priority)
        
    if hasattr(entry, "match_spec"):
        print_match_spec(entry.match_spec)
            
    if hasattr(entry, "action_desc"):
        print_action_desc(entry.action_desc)
        
    if hasattr(entry, "has_mbr_hdl"):
        if getattr(entry, "has_mbr_hdl") == 1:
            print("Action Profile Member: {0:#010x} ({0:d})".
                  format(entry.action_mbr_hdl))

    if hasattr(entry, "has_grp_hdl"):
        if getattr(entry, "has_grp_hdl") == 1:
            print("Action Profile Group: {0:#010x} ({0:d})".
                  format(entry.selector_grp_hdl))
            
#
# Table dumping
#
def get_entries(table, count=None, sess_hdl=None, dev_tgt=None):
    """
Return a list containing handles of all the entries in a given table.

The optional argument "count" can be used to specify that you want no more 
than "count" entries.
    """

    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    try:
        exec("ec = p4_pd.{}_get_entry_count(sess_hdl=sess, dev_tgt=tgt)".
             format(table))
    except AttributeError:
        return []

    ec = limit_count(count, ec)
    
    if ec == 0:
        return []
    
    exec("fh = p4_pd.{}_get_first_entry_handle(sess_hdl=sess, dev_tgt=tgt)".
         format(table))
    entries = [fh]
    if ec > 1:
        exec("entries.extend(p4_pd.{}_get_next_entry_handles(fh, ec-1, sess_hdl=sess, dev_tgt=tgt))".format(table))

    return entries[0:ec]

def dump_table(table, entries=None, count=None, read_from_hw=from_sw, sess_hdl=None, dev_tgt=None):
    """
Dump a table. By default all entries from all pipes will be dumped.

Optional parameters:
    tgt          -- DevTarget() -- which device to dump a table from
    entries      -- a list of entry handles. Dump only those entries
    count        -- how many entries to dump (if you do not need all)
    read_from_hw -- read the entries from the HW and decode that information
                    instead of dumping the contents of the SW cache
    """

    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    exec("ec = p4_pd.{}_get_entry_count(sess_hdl=sess, dev_tgt=tgt)".
         format(table))

    if entries == None:
        entries = get_entries(table, count, sess_hdl=sess, dev_tgt=tgt)
    print("Table", table, "Entry Count:", ec)

    if hasattr(p4_pd, "%s_get_ttl" % table):
        get_ttl = True
        cmd_get_ttl = ("ttl = p4_pd.%s_get_ttl(e, sess_hdl=sess, dev_id=tgt.dev_id)" % table)
    else:
        get_ttl = False

    # This code has to wait for DRV-1115    
    #if hasattr(p4_pd, "%s_get_hit_state" % table):
    #    get_hit = True
    #    cmd_get_hit = ("hit = p4_pd.%s_get_hit_state(e, sess_hdl=sess, dev_id=tgt.dev_id)" % table)
    #    try:
    #        exec("p4_pd.{}_update_hit_state(sess_hdl=sess, dev_id=tgt.dev_id)".
    #             format(table))
    #    except:
    #        get_hit = False # Table is not in POLL mode
    #else:
    #    get_hit = False
        
    cmd = ("entry = p4_pd.%s_get_entry(e, read_from_hw, sess_hdl=sess, dev_id=tgt.dev_id)" % table)

    for e in entries:
        exec(cmd)
        print("----------------------")
        print("Entry Handle:", e, end="")
        if get_ttl:
            exec(cmd_get_ttl)
            if ttl == 0:
                print("Static", end="")
            else:
                print("TTL: ", ttl, end="")
        #if get_hit:
        #    exec(cmd_get_hit)
        #    if hit:
        #        print("Hit", end="")
        print
        print_entry(entry)
        
           

    try:
        exec("deh = p4_pd.{}_table_get_default_entry_handle(sess_hdl=sess, dev_tgt=tgt)".format(table))
        exec("entry = p4_pd.{}_get_entry(deh, read_from_hw, sess_hdl=sess, dev_id=tgt.dev_id)".format(table))
        print("*********************")
        print("DEFAULT ACTION: (Entry Handle: {})".format(deh))
        print_action_desc(entry.action_desc)
    except:
        pass
        
def clear_table(table, entries=None, sess_hdl=None, dev_tgt=None):
    """
Delete all entries from a given table. The optional parameter 'entries' may 
contain a list of entries to delete (instead of all)
    """
    
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)

    if entries == None:
        entries = get_entries(table, sess_hdl=sess, dev_tgt=tgt)

    cmd = "p4_pd.{}_table_delete(e, sess_hdl=sess, dev_id=tgt.dev_id)".format(table)
    conn_mgr.begin_batch()
    for e in entries:
        exec(cmd)
    conn_mgr.end_batch(True)
    
    cmd = "p4_pd.{}_table_reset_default_entry(sess_hdl=sess, dev_tgt=tgt)".format(table)
    try:
        exec(cmd)
    except:
        pass
    cmd = "p4_pd.{}_idle_tmo_disable(sess_hdl=sess, dev_id=tgt.dev_id)".format(table)
    try:
        exec(cmd)
    except:
        pass
    
#
# Action Profile dumping
#
def get_action_profile_entries(table, count=None, read_from_hw=from_sw, sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    exec("ec = p4_pd.{}_get_act_prof_entry_count(sess_hdl=sess, dev_tgt=tgt)".
         format(table))

    if ec == 0:
        return []

    exec("fh = p4_pd.{}_get_first_member(sess_hdl=sess, dev_tgt=tgt)".
         format(table))
    entries = [fh]
    if ec > 1:
        exec("entries.extend(p4_pd.{}_get_next_members(fh, ec-1, sess_hdl=sess, dev_tgt=tgt))".format(table))

    #
    # Because get_act_prof_entry_count() may count each member multiple times
    # (depending on whether it is used in groups or not), the "tail" of the
    # list might be filled with "-1"s. We need to chop it off
    #
    try:
        entries = entries[0:entries.index(-1)]
    except:
        pass

    # Cut off more entries if that's what the user requested
    return entries[0:count]

def dump_action_profile(table, entries=None, count=None, read_from_hw=from_sw, sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    exec("ec = p4_pd.{}_get_act_prof_entry_count(sess_hdl=sess, dev_tgt=tgt)".
         format(table))

    if entries == None:
        entries = get_action_profile_entries(table, count, read_from_hw, sess_hdl=sess, dev_tgt=tgt)
    print("Action Profile", table,
          "Entry Count:", len(entries),
          "Total Occupancy:", ec)
    
    for e in entries:
        exec("entry = p4_pd.{}_get_member(e, read_from_hw, sess_hdl=sess, dev_id=tgt.dev_id)".format(table))
        print("----------------------")
        print("Entry Handle:", e)
        print_action_desc(entry)

#
# Action Profile with Selector Dumping
#
def get_action_selector_groups(table, count=None, read_from_hw=from_sw, sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    exec("gc = p4_pd.{}_get_selector_group_count(sess_hdl=sess, dev_tgt=tgt)".
         format(table))
    if gc == 0:
        return []
    
    exec("fg = p4_pd.{}_get_first_group(sess_hdl=sess, dev_tgt=tgt)".
         format(table))
    groups = [fg]
    if gc > 1:
        exec("groups.extend(p4_pd.{}_get_next_groups(fg, gc-1, sess_hdl=sess, dev_tgt=tgt))".format(table))

    return groups[0:count]

def get_action_selector_group_members(table, group, count=None, read_from_hw=from_sw, sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    try:
        exec("fh = p4_pd.{}_get_first_group_member(group, sess_hdl=sess, dev_id=tgt.dev_id)".format(table))
        entries = [fh]
        ec=1
    except:
        return []

    while True:
        try:
            exec("more_entries = p4_pd.{}_get_next_group_members(group, fh, 120, sess_hdl=sess, dev_id=tgt.dev_id)".format(table))
        except:  # No more entries
            return entries
        
        try:
            last_valid = more_entries.index(0)
        except:
            last_valid = len(more_entries)
    
        entries.extend(more_entries[0:last_valid])
        ec = len(entries)
        fh = entries[-1]
        
        if count is not None and ec > count:
            return entries[0:count]
        
        if last_valid < len(more_entries):
            return entries
        
def dump_action_selector_group(table, group, count=None,
                               read_from_hw=from_sw,
                               sess_hdl=None, dev_tgt=None):
    
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    entries = get_action_selector_group_members(table, group, count=None,
                                                read_from_hw=from_sw,
                                                sess_hdl=sess, dev_tgt=tgt)
    print("Selector Group: {:#010x}   Entries: {}".format(group, entries))
    
def dump_action_selector_groups(table, groups=None, count=None,
                                entry_count=None, read_from_hw=from_sw,
                                sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    exec("gc = p4_pd.{}_get_selector_group_count(sess_hdl=sess, dev_tgt=tgt)".
         format(table))

    if groups == None:
        groups = get_action_selector_groups(table, count,
                                            read_from_hw,
                                            sess_hdl=sess, dev_tgt=tgt)
    print("Action Selector", table, "Group Count:", gc)
    
    for g in groups:
        dump_action_selector_group(table, g, entry_count,
                                   read_from_hw,
                                   sess_hdl=sess, dev_tgt=tgt)

#
# Multicast commands
#
def mc_groups_get(count=None, sess_hdl=None, dev_id=None):
    """
    Return a list of all Multicast Groups configured on the device.

    Parameters:
        - count    -- limit the number of returned Multicast Groups
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    mcg_count = limit_count(count, mc.mgrp_get_count(sess_hdl=sess, dev_id=dev))
    mcg_list = []
    if mcg_count > 0:
        mcg_list.append(mc.mgrp_get_first(sess_hdl=sess, dev_id=dev))
    if mcg_count > 1:
        mcg_list.extend(mc.mgrp_get_next_i(mcg_list[-1],
                                           mcg_count - 1,
                                           sess_hdl=sess, dev_id=dev))
    return mcg_list

def mc_nodes_get(count=None, sess_hdl=None, dev_id=None):
    """
    Return a list of all Multicast nodes, configured on the device.

    Parameters:
        - count    -- limit the number of returned Multicast Nodes
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    node_count = limit_count(count,
                             mc.node_get_count(sess_hdl=sess, dev_id=dev))
    node_list = []
    if node_count > 0:
        node_list.append(mc.node_get_first(sess_hdl=sess, dev_id=dev))
    if node_count > 1:
        node_list.extend(mc.node_get_next_i(node_list[-1],
                                            node_count - 1,
                                            sess_hdl=sess, dev_id=dev))
    return node_list

def mc_ecmps_get(count=None, sess_hdl=None, dev_id=None):
    """
    Return a list of all Multicast L1 Choice (ECMP) nodes, 
    configured on the device.

    Parameters:
        - count    -- limit the number of returned ECMPs
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    ecmp_count = limit_count(count,
                             mc.ecmp_get_count(sess_hdl=sess, dev_id=dev))
    ecmp_list = []
    if ecmp_count > 0:
        ecmp_list.append(mc.ecmp_get_first(sess_hdl=sess, dev_id=dev))
    if ecmp_count > 0:
        ecmp_list.extend(mc.ecmp_get_next_i(ecmp_list[-1],
                                            ecmp_count - 1,
                                            sess_hdl=sess, dev_id=dev))
    return ecmp_list

def mc_groups_clear(sess_hdl=None, dev_id=None):
    """
    Delete all Multicast groups, configured on the device.

    Parameters:
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    for mcg in mc_groups_get(sess_hdl=sess, dev_id=dev):
         mc.mgrp_destroy(mcg, sess_hdl=sess, dev_id=dev)
    mc.complete_operations(sess_hdl=sess)
        
def mc_nodes_clear(sess_hdl=None, dev_id=None):
    """
    Delete all Multicast L1 Nodes, configured on the device.

    Parameters:
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    # A small workaround for a bug in node_get_next_i in SDE-8.1.0
    for node in mc_nodes_get(-1, sess_hdl=sess, dev_id=dev):
         mc.node_destroy(node, sess_hdl=sess, dev_id=dev)
    for node in mc_nodes_get(sess_hdl=sess, dev_id=dev):
         mc.node_destroy(node, sess_hdl=sess, dev_id=dev)
    mc.complete_operations(sess_hdl=sess)

def mc_ecmps_clear(sess_hdl=None, dev_id=None):
    """
    Delete all Multicast L1 Choice (ECMP) Nodes, configured on the device.

    Parameters:
        - sess_hdl  -- Multicast Session ID (the value of sess_hdl if None)
        - dev_id   -- Device id (the value of dev if None)
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    for ecmp in mc_ecmps_get(sess_hdl=sess, dev_id=dev):
        mc.ecmp_destroy(ecmp, sess_hdl=sess, dev_id=dev)
    mc.complete_operations(sess_hdl=sess)
    

def clear_mc(sess_hdl=None, dev_id=None):
    """
    Clear the state of the multicast engine. 

    Currently we delete all the L1 Nodes, L1 Choice Nodes and Multicast Groups
    """
    (sess, dev) = mc_common_args(sess_hdl, dev_id)
    mc_groups_clear(sess_hdl=sess, dev_id=dev)
    mc_ecmps_clear(sess_hdl=sess, dev_id=dev)
    mc_nodes_clear(sess_hdl=sess, dev_id=dev)
    
    # Clear LAGs
    for lag in range(0, 255):
        mc.set_lag_membership(i8(lag), devports_to_mcbitmap([]),
                              sess_hdl=sess, dev_id=dev)
        
    # Clear Port Prune tables
    for yid in range(0, 288):
        mc.update_port_prune_table(i16(yid), devports_to_mcbitmap([]),
                                   sess_hdl=sess, dev_id=dev)
    mc.complete_operations(sess_hdl=sess)

#
# Generic commands
#
def dump(p4_object_name, entries=None, count=None, read_from_hw=from_sw, groups=None, entry_count=None, sess_hdl=None, dev_tgt=None):
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    if hasattr(p4_pd, "%s_entry_desc_t" % p4_object_name):
        dump_table(p4_object_name, entries, count, read_from_hw,
                   sess_hdl=sess, dev_tgt=tgt)
    elif hasattr(p4_pd, "%s_get_selector_group_count" % p4_object_name):
        if entries != []:
            dump_action_profile(p4_object_name, entries, count, read_from_hw)
            
        dump_action_selector_groups(p4_object_name, groups, count,
                                     entry_count, read_from_hw)
    elif hasattr(p4_pd, "%s_get_act_prof_entry_count" % p4_object_name):
        dump_action_profile(p4_object_name, entries, count, read_from_hw)
    else:
        print("Cannot dump", p4_object_name)

def clear_all(verbose=0, sess_hdl=None, dev_tgt=None):
    (sess, tgt) = api_common_args(sess_hdl, dev_tgt)
    
    if PROG != None:
        for t in dir(tables):
            if not t.startswith('__'):
                if verbose:
                    print("Clearing", t, "...", end="")

                clear_table(t, sess_hdl=sess, dev_tgt=tgt)

                if verbose:
                    print("DONE")

    # Clear the multicast configuration (at least partially). Ideally we should
    # also clear lag membership, prune table, etc. 
    if mc_sess is not None:
        clear_mc(sess_hdl=mc_sess, dev_id=tgt.dev_id)

#
# Fixed API Helpers
#

class PktGen:
    # These are needed for better autocompletion
    TriggerType_t = None
    def __init__(self, conn_mgr):
        for f in dir(conn_mgr):
            if f.startswith("pktgen_"):
                setattr(self, f[7:], getattr(conn_mgr, f))
            if f.startswith("PktGen"):
                setattr(self, f[6:], getattr(conn_mgr, f))
            if f == "PortMask_t":
                setattr(self, "PortMask_t", conn_mgr.PortMask_t)
        self.Stats = {}

    def app_cfg_init(self):
        return self.AppCfg_t(
            trigger_type=conn_mgr.PktGenTriggerType_t.TIMER_ONE_SHOT,
            buffer_offset=0, length=0,
            timer=0,
            batch_count=0, ibg=0, ibg_jitter=0,
            pkt_count=0,   ipg=0, ipg_jitter=0,
            pattern_key=0, pattern_msk=0,
            src_port=68,   src_port_inc=0)
                
    class Counters:
        def __init__(self):
            self.zero = {}
            self.last = {}
            self.curr = {}
            for app in range(0, 8):
                self.zero[app] = {}
                self.last[app] = {}
                self.curr[app] = {}
                for pipe in range(-1, 4):
                    self.zero[app][pipe] = {
                        'tstamp' : 0, 'Events' : 0, 'Batches': 0, 'Packets': 0}
                    self.last[app][pipe] = {
                        'tstamp' : 0, 'Events' : 0, 'Batches': 0, 'Packets': 0}
                    self.curr[app][pipe] = {
                        'tstamp' : 0, 'Events' : 0, 'Batches': 0, 'Packets': 0}
 
        def shift(self):
            self.last = copy.deepcopy(self.curr)

        def clear(self):
            self.zero = copy.deepcopy(self.curr)

    def get_counters(self, sess_hdl=None, device=None):
        PGR=self.Stats
        (sess, dev_id) = api_common_args_dev(sess_hdl, device)

        # Make sure we have an object, representing the current device
        try:
            pgr = PGR[dev_id]
        except KeyError:
            PGR[dev_id] = self.Counters()
            pgr = PGR[dev_id]

        # Always collect all the counters across all the pipes in the device
        tgt_list = [DevTarget_t(dev_id, pipe)
                    for pipe in range(0, pal.num_pipes_get(device=dev_id))]

        for app in range(0, 8):
            for c in  ['Events', 'Batches', 'Packets']:
                pgr.curr[app][-1][c] = 0
            for t in tgt_list:
                pipe = t.dev_pipe_id
                pgr.curr[app][pipe]['Events'] = (
                    self.get_trigger_counter(app, sess_hdl=sess, dev_tgt=t))
                pgr.curr[app][pipe]['Batches'] = (
                    self.get_batch_counter(app, sess_hdl=sess, dev_tgt=t))
                pgr.curr[app][pipe]['Packets'] = (
                    self.get_pkt_counter(app, sess_hdl=sess, dev_tgt=t))

                pgr.curr[app][pipe]['tstamp'] = time.time()

                # Calculate device totals
                for c in  ['Events', 'Batches', 'Packets']:
                    pgr.curr[app][-1][c] += pgr.curr[app][pipe][c]
            pgr.curr[app][-1]['tstamp'] = time.time()

    def show_counters(self, zero=False, same=False, apps=None,
                      sess_hdl=None, dev_tgt=None):
        PGR = self.Stats
        (sess, tgt) = api_common_args(sess_hdl, dev_tgt)

        # Collect the latest counters. This will also create a PGR object for
        # the device if that hasn't been done
        self.get_counters(sess, tgt.dev_id)
        pgr = PGR[tgt.dev_id]

        apps = range(0, 8) if apps == None else apps
        pipe = tgt.dev_pipe_id
    
        print(
"""
+============+======================+======================+==================+
|  Counter   |     Value            |   Increment          |       Rate       |
+============+======================+======================+==================+""")

        for app in apps:
            if not ((pgr.curr[app][pipe]['Packets'] != pgr.zero[app][pipe]['Packets'] or zero) and
                    (pgr.curr[app][pipe]['Packets'] != pgr.last[app][pipe]['Packets'] or same)):
                continue
        
            print(
"| App {:1}:     |                      |                      |                  |".format(app))
            for c in ['Events', 'Batches', 'Packets']:
                value     = pgr.curr[app][pipe][c] - pgr.zero[app][pipe][c]
                increment = pgr.curr[app][pipe][c] - pgr.last[app][pipe][c]
                time_diff = pgr.curr[app][pipe]['tstamp'] - pgr.last[app][pipe]['tstamp']
            
                print("| {:>10} | {:20} | {:20} | {:>16} |".format(
                    c, value, increment,
                    "--" if time_diff == 0 or pgr.last[app][pipe]['tstamp'] == 0
                    else "{:.2f}/s".format(increment/time_diff))) 
                print(
"+------------+----------------------+----------------------+------------------+")                
        pgr.shift()

    def clear_counters(self, sess_hdl=None, dev_tgt=None):
        PGR = self.Stats
        (sess, tgt) = api_common_args(sess_hdl, dev_tgt)

        # Collect the latest counters. This will also create a PGR object for
        # the device if that hasn't been done
        self.get_counters(sess, tgt.dev_id)
        pgr = PGR[tgt.dev_id]

        pgr.clear()

class PortCounters:
    def __init__(self, dev):
        # Get Device Ports
        self.allports = [pal.port_get_first(device=dev)]
        while True:
            try:
                self.allports.append(pal.port_get_next(
                    self.allports[-1], device=dev))
            except:
                break
        
        
#
# One time preprocessing of p4_pd
#
tables          = type("p4_pd_tables", (), {})
action_profiles = type("p4_pd_action_profiles", (), {})
counters        = type("p4_pd_counters", (), {})
meters          = type("p4_pd_meters", (), {})
registers       = type("p4_pd_registers", (), {})

def get_p4_objects():
    global tables
    global action_profiles
    global counters
    global meters
    global counters
    
    if PROG == None:
        raise TypeError("PD APIs Not Imported")
    
    # Tables
    suffix="_entry_desc_t"
    suffix_len=len(suffix)
    for m in sorted(p4_pd.__dict__.keys()):
        if m.endswith(suffix):
            table=m[0:-suffix_len]
            setattr(tables, table, table)
    # Action Profiles
    suffix="_del_member"
    suffix_len=len(suffix)
    for m in sorted(p4_pd.__dict__.keys()):
        if m.endswith(suffix):
            action_profile=m[0:-suffix_len]
            setattr(action_profiles, action_profile, action_profile)
    # Counters
    prefix="counter_read_"
    prefix_len=len(prefix)
    for m in sorted(p4_pd.__dict__.keys()):
        if m.startswith(prefix):
            counter=m[prefix_len:]
            setattr(counters, counter, counter)
    # Meters
    prefix="meter_read_"
    prefix_len=len(prefix)
    for m in sorted(p4_pd.__dict__.keys()):
        if m.startswith(prefix):
            meter=m[prefix_len:]
            setattr(meters, meter, meter)
    # Registers
    prefix="register_read_"
    prefix_len=len(prefix)
    for m in sorted(p4_pd.__dict__.keys()):
        if m.startswith(prefix):
            register=m[prefix_len:]
            setattr(registers, register, register)

#############################################################################
#
# MAIN
#
def main():
    parse_args()
    check_env()
    set_paths(SDE_INSTALL)

    try:
        if os.environ['CASE'] != None:
            set_paths(os.path.join(os.environ['CASE'], 'install'))
    except:
           pass
 
    if not args.no_wait:
        wait_for_switchd()   

    import_all_apis()
    if PROG != None:
        get_p4_objects()

    if args.eval != None:
        try:
            exec(args.eval)
        except Exception as e:
            print(e)
            exit(1)
    else:    
        run_shell(args.script)

##############################################################################

if __name__ == "__main__":
    main()
