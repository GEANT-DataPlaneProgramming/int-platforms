import subprocess
import socket
import logging

log = logging.getLogger(__name__)

thrift_verbose = True

#simple_switch_CLI --thrift-port=22222
def connect(thrift_port):
    return subprocess.Popen(['simple_switch_CLI', '--thrift-port', str(thrift_port)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
'''
RuntimeCmd: help table_add
Add entry to a match table: table_add <table name> <action name> <match fields> => <action parameters> [priority]
Eg.: table_add ipv4_lpm ipv4_forward 10.0.3.3/32 => 00:00:00:00:03:03 3
table_add ddos_destinations_monitored src_distribution_monitor 10.0.2.2/32
'''
def addTableEntry(thrift_port, table_name, action_name, match_fields, action_params="", priority=""):
    p = connect(thrift_port)
    entry = "table_add %s %s %s => %s %s" % (table_name, action_name, match_fields, action_params, priority)
    log.debug("Adding table entry %s", entry)
    try:
        stdout, stderr = p.communicate(input=entry.encode(), timeout=5)
    except subprocess.TimeoutExpired:
        p.kill()
        stdout, stderr = p.communicate()
    handle_id = None
    for line in stdout.splitlines():
        line = line.decode()
        if 'Entry has been added with handle' in line:
            handle_id = line.split(' ')[6]
    if thrift_verbose == True:
        log.debug(stdout)
        log.debug("Handle id is %s" % handle_id)
    return handle_id
 
'''
RuntimeCmd: help table_delete
Remove entry from match table: table_delete <table name> <entry handle>
'''
def delTableEntry(thrift_port, table_name, handle_id):
    p = connect(thrift_port)
    entry = "table_delete %s %s" % (table_name, handle_id)
    log.debug("Delete table entry %s", entry)
    stdout, stderr = p.communicate(input=entry.encode(), timeout=5)
    if thrift_verbose == True:
        stdout = stdout.decode()
        log.debug(stdout)
        
        
def readRegister(thrift_port, register, idx=None):
    p = connect(thrift_port)
    if idx is not None:
        entry = "register_read %s %d" % (register, idx)
        log.debug("Read register %s", entry)
        stdout, stderr = p.communicate(input=entry.encode(), timeout=5)
        # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
        for line in stdout.splitlines():
            line = line.decode()
            m = re.match("RuntimeCmd:\s*\w+\[\d+\]\s*=\s*(\d+)", line)
            if m:
                return int(m.group(1))
    else:
        entry = "register_read %s" % (register)
        log.debug("Read register %s", entry)
        stdout, stderr = p.communicate(input=entry.encode(), timeout=1)
        for line in stdout.splitlines():
            line = line.decode()
            if '=' not in line:
                continue
            line = line.split(',')
            reg_vals = [line[0].split(' ')[-1]] + line[1:]
            reg_vals = [int(val) for val in reg_vals]
            return reg_vals
        return []
   
def writeRegister(thrift_port, register, idx, value):
    p = connect(thrift_port)
    entry = "register_write %s %d %d" % (register, idx, value)
    log.debug("Write register %s", entry)
    stdout, stderr = p.communicate(input=entry.encode(), timeout=5)
    # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
    for line in stdout.splitlines():
        line = line.decode()
        log.debug(line)
        #m = re.match("RuntimeCmd:\s*\w+\[\d+\]\s*=\s*(\d+)", line)
        #if m:
        #    return int(m.group(1))
        
'''
RuntimeCmd: help register_reset
Reset all the cells in the register array to 0: register_reset <name>
'''
def resetRegister(thrift_port, register):
    p = connect(thrift_port)
    entry = "register_reset %s" % register
    log.debug("Reset register %s", entry)
    stdout, stderr = p.communicate(input=entry.encode(), timeout=1)
    stdout = stdout.decode()
    if 'Error' in stdout:
        log.debug(stdout)
    #print("Register %s reseted" % register)
    
'''
Read counter value: counter_read <name> <index>
stdout example
Control utility for runtime P4 table manipulation [4]
RuntimeCmd: total_traffic_counter[0]=  BmCounterValue(packets=225, bytes=22050)
'''	

def readCounter(thrift_port, counter, idx):
    p = connect(thrift_port)
    if idx is not None:
        entry = "counter_read %s %d" % (counter, idx)
        log.debug("Read counter %s", entry)
        stdout, stderr = p.communicate(input=entry.encode(), timeout=1)
        values = re.findall('\d+', stdout.decode()) #values always in format [4, 0, packets, bytes]
        return "%s= %s, %s [packets, bytes]" % (counter, values[2], values[3]) 

def resetCounter(thrift_port, counter, idx):
    p = connect(thrift_port)
    entry = "counter_reset %s" % (counter)
    log.debug("Reset counter %s", entry)
    stdout, stderr = p.communicate(input=entry.encode(), timeout=1)
    #print("Counter %s reseted" % counter)	
    
def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))


