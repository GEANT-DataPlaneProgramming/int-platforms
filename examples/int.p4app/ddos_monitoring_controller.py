#!/usr/bin/python

import subprocess
import threading
import re
import socket
import struct
from time import sleep, time

S1 = 22222
S2 = 22223
S3 = 22224

PERIOD_DURATION = 3 #sec
sketch_memory_verbose = True
SKETCH_DEPTH = 4   # how many hash function are used

############################################
#	UTILITY FUNCTIONS
############################################

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
    stdout, stderr = p.communicate(input="table_add %s %s %s => %s %s" % (table_name, action_name, match_fields, action_params, priority))
    handle_id = None
    for line in stdout.splitlines():
        if 'Entry has been added with handle' in line:
            handle_id = line.split(' ')[6]
    if sketch_memory_verbose == True:
        print(stdout)
        print("Handle id is %s" % handle_id)
    return handle_id
 
'''
RuntimeCmd: help table_delete
Remove entry from match table: table_delete <table name> <entry handle>
'''
def delTableEntry(thrift_port, table_name, handle_id):
    p = connect(thrift_port)
    stdout, stderr = p.communicate(input="table_delete %s %s" % (table_name, handle_id))
    if sketch_memory_verbose == True:
        print(stdout)
        
        
def readRegister(thrift_port, register, idx=None):
    p = connect(thrift_port)
    if idx is not None:
        stdout, stderr = p.communicate(input="register_read %s %d" % (register, idx))
        # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
        for line in stdout.splitlines():
            m = re.match("RuntimeCmd:\s*\w+\[\d+\]\s*=\s*(\d+)", line)
            if m:
                return int(m.group(1))
    else:
        stdout, stderr = p.communicate(input="register_read %s" % (register))
        for line in stdout.splitlines():
            if '=' not in line:
                continue
            line = line.split(',')
            reg_vals = [line[0].split(' ')[-1]] + line[1:]
            reg_vals = [int(val) for val in reg_vals]
            return reg_vals
        return []
    
'''
RuntimeCmd: help register_reset
Reset all the cells in the register array to 0: register_reset <name>
'''
def resetRegister(thrift_port, register):
    p = connect(thrift_port)
    stdout, stderr = p.communicate(input="register_reset %s" % register)
    if 'Error' in stdout:
        print(stdout)
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
        stdout, stderr = p.communicate(input="counter_read %s %d" % (counter, idx))
        values = re.findall('\d+', stdout) #values always in format [4, 0, packets, bytes]
        return "%s= %s, %s [packets, bytes]" % (counter, values[2], values[3]) 

def resetCounter(thrift_port, counter, idx):
    p = connect(thrift_port)
    stdout, stderr = p.communicate(input="counter_reset %s" % (counter))
    #print("Counter %s reseted" % counter)	
    
def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))
'''
Change the parameters for a custom crc16 hash: set_crc16_parameters <name> <polynomial> <initial remainder> <final xor value> <reflect data?> <reflect remainder?>
Set parameters in crc16 and crc32 functions

other good polynomial values are:
16:
  0x0330, 0x8335, 0x833F, 0x033A, 
  0x832B, 0x032E, 0x0324, 0x8321,
  0x0360, 0x8365, 0x836F, 0x036A, 
  0x837B, 0x037E, 0x0374, 0x8371,

32:
  0x8AAD2B2F, 0x8E6C3698, 0x832F1041, 0x87EE0DF6,
  0x99A95DF3, 0x9D684044, 0x902B669D, 0x94EA7B2A,
  0xE0B41DE7, 0xE4750050, 0xE9362689, 0xEDF73B3E,
  0xF3B06B3B, 0xF771768C, 0xFA325055, 0xFEF34DE2,
'''
def set_crc16_parameters(thrift_port, index):
    p = connect(thrift_port)
    stdout, stderr = p.communicate(input="set_crc16_parameters calc_%d 0x02CE 0x0000 0x0000 true true" %index)

def set_crc32_parameters(thrift_port, index):
    p = connect(thrift_port)
    stdout, stderr = p.communicate(input="set_crc32_parameters calc_%d 0x23431B1C 0xffffffff 0xffffffff true true" %index)

############################################
#	GENERIC MONITORING METHOD
############################################

def read_sketch_registers(core_name, cnt, cells=50):
    if sketch_memory_verbose == False:
        return
        
    print("Reading %s memory:" % core_name)
    for i in range(1, cnt+1):
        print("\t"),
        print(readRegister(S1, "%s%i" % (core_name, i))[:cells])
    
def get_sketch_registers(monitoring_method):
    registers = []
    
    registers.append('%s_distribution_heavy_hitter' % monitoring_method)
    registers.append('%s_cnt_distribution_heavy_hitter' % monitoring_method)
    registers.append('%s_distribution_heavy_hitter_index' % monitoring_method)
    
    for reg_id in range(1, SKETCH_DEPTH+1):
        registers.append('%s_distribution_register%d' % (monitoring_method, reg_id))
        registers.append('%s_distribution_bloom_register%d' % (monitoring_method, reg_id))

    
    return registers

"""
Activate a particular monitoring method for a specic number of observations periods
@param method_name - Monitoring method name (i.e.: 'src', 'src_port', 'dst_port', 'total_traffic', 'ip_protocols'
@param periods - Number of observation periods (1,2,3, ...) or 'Infinite'
""" 
class MonitoringMethod:

    def __init__(self, method_name, target, periods="Infinite"):
        self.periods = periods
        self.period_id = 0
        self.target = target
        self.method_name = method_name
        
    def start(self):
        #print("Activating DDoS %s monitoring method" % self.method_name)
        start_time = time()
        while self.period_id < self.periods or self.periods == "Infinite":
            self.handle_id = addTableEntry(S1, "ddos_destinations_monitored", "%s_distribution_monitor" % self.method_name, "%s/32" % self.target) #"10.0.2.2/32"
            add_entry_time = time()
            sleep(PERIOD_DURATION)
            sleep_time = time()
            delTableEntry(S1, "ddos_destinations_monitored", self.handle_id)
            del_entry_time = time()
            self.perform_actions()
            actions_time = time()
            self.period_id += 1
        #print("add_entry: %.2fs, sleep: %.2fs, actions: %.2fs, del_entry: %.2fs" % 
        #        (add_entry_time-start_time, sleep_time-add_entry_time, actions_time-sleep_time, del_entry_time-actions_time))
        
    def perform_actions(self):
        raise NotImplementedError('subclasses must override perform_actions()!')

"""
Activate a particular sketch-based monitoring method for a specic number of observations periods
@param method_name - Monitoring method name (i.e.: 'src', 'src_port', 'dst_port', 'ip_protocols')
@param periods - Number of observation periods (1,2,3, ...) or 'Infinite'
""" 		
class SketchMonitoring(MonitoringMethod):

    def perform_actions(self):
        read_sketch_registers("%s_distribution_register" % self.method_name, cnt=SKETCH_DEPTH)
        read_sketch_registers("%s_distribution_bloom_register" % self.method_name, cnt=SKETCH_DEPTH)
        #print(readRegister(S1, "%s_distribution_heavy_hitter_index" % self.method_name))
     
        self.display()

        start_time = time()
        for register in get_sketch_registers(self.method_name):
            resetRegister(S1, register)
        #print("registers reset: %.2fs" % (time()-start_time,))
            
    def display(self):
        start_time = time()
        #print("for %s %s are: " % (self.target, self.method_name)),
        values = readRegister(S1, "%s_distribution_heavy_hitter" % self.method_name)
        addresses = readRegister(S1, "%s_cnt_distribution_heavy_hitter" % self.method_name)
        hitters_read = time()
        cnts = []
        for address in  addresses:
            if int(address) == 0:
                continue
            hashtable_id = (address|0xF000)>>24
            hashtable_address = address&0x0FFF
            if hashtable_id != 0:
                cnt = readRegister(S1, "%s_distribution_register%d" % (self.method_name, hashtable_id), hashtable_address)
            else:
                cnt = 0
            #print("%d: %d -> value is %d" % (hashtable_id, hashtable_address, cnt))
            cnts.append(cnt)
        
        values = [v for v in values if int(v) > 0]
        if len(values) > 0:
            print("target %s %s are: " % (self.target, self.method_name)),
        
        for value, cnt in sorted(zip(values, cnts), key=lambda item: item[1], reverse=True):
            if self.method_name == 'src':
                 value = int2ip(int(value))
            print("%s (%d), " % (value, cnt)),
        cnts_read = time()
        
        #if len(values) == 0:
            #print("No values"),
        print('')  # just to have a new line
        #print("read hitters: %.2fs, read cnts: %.2fs" % (hitters_read-start_time, cnts_read-hitters_read)),
        
"""
Activate a particular counter-based monitoring method for a specic number of observations periods
@param method_name - Monitoring method name (i.e.: 'total_traffic'')
@param periods - Number of observation periods (1,2,3, ...) or 'Infinite'
""" 	
class CounterMonitoring(MonitoringMethod):

    def perform_actions(self):
        self.display()
        resetCounter(S1, "%s_counter" % self.method_name, 0)
        
    def display(self):
        counters = readCounter(S1, "%s_counter" % self.method_name, 0)
        if "total_traffic_counter= 0, 0" not in counters:
            print("target %s %s" % (self.target, counters))

"""
Activate a set of monitoring methods running all for a specic number of observations periods
@param method_name - Composed monitoring method name (i.e.: 'all_monitors')
@param monitors - List of MonitoringMethod objects
@param periods - Number of observation periods (1,2,3, ...) or 'Infinite'
""" 
class ComposedMonitor(MonitoringMethod):

    def __init__(self, method_name, target, monitors, periods="Infinite"):
        self.monitors = monitors
        MonitoringMethod.__init__(self, method_name, target, periods)

    def perform_actions(self):
        for monitor in self.monitors:
            monitor.perform_actions()

def AllMonitors(target):
    monitors = [
        SketchMonitoring(method_name='src', target=target),
        SketchMonitoring(method_name='src_port', target=target),
        SketchMonitoring(method_name='dst_port', target=target),
        SketchMonitoring(method_name='ip_protocols', target=target),
	SketchMonitoring(method_name='packet_length', target=target),
        CounterMonitoring(method_name='total_traffic', target=target),
	CounterMonitoring(method_name='fragmented_packets', target=target),
    ]

    return ComposedMonitor(method_name='all_distribution_monitor', target=target, monitors=monitors)


def all_sequenctially(target):
    while True:
        #SketchMonitoring(method_name='src', target=target, periods=1).start()
        #SketchMonitoring(method_name='src_port', target=target, periods=1).start()  
        #SketchMonitoring(method_name='dst_port', target=target, periods=1).start()  
        SketchMonitoring(method_name='ip_protocols', target=target, periods="Infinite").start()
	#SketchMonitoring(method_name='packet_length', target=target, periods=1).start()
        #CounterMonitoring(method_name='total_traffic', target=target, periods=1).start()
	#CounterMonitoring(method_name='fragmented_packets', target=target, periods=1).start()
        
###########################################################

def control_process_thread():
    for i in range(130):
        set_crc32_parameters(S1,i)
    print("custorm crc32 parameters are set")
    for i in range(110):
        set_crc16_parameters(S1,i)
    print("custorm crc16 parameters are set") 
    #SketchMonitoring(method_name='src', target="10.0.2.2").start()
    #SketchMonitoring(method_name='src_port', target="10.0.2.2").start()  
    #SketchMonitoring(method_name='dst_port', target="10.0.2.2").start()  
    #SketchMonitoring(method_name='ip_protocols', target="10.0.2.2").start() 
    #SketchMonitoring(method_name='packet_length', target="10.0.2.2").start()
    #CounterMonitoring(method_name='total_traffic', target="10.0.2.2").start() 
    #AllMonitors(target="10.0.2.2").start()
    all_sequenctially(target="10.0.2.2")

def control_process():
    thread = threading.Thread(target=control_process_thread)
    thread.daemon = True
    thread.start()

if __name__ == "__main__":
    control_process_thread()

