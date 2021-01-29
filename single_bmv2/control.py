from time import sleep, time
import os
import subprocess

THRIFT_PORT = 9090

def connect(thrift_port):
    return subprocess.Popen(['simple_switch_CLI', '--thrift-port', str(thrift_port)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  
def readRegister(thrift_port, register, idx=None):
    thrift_client = connect(thrift_port=thrift_port)
    if idx is not None:
        stdout, stderr = thrift_client.communicate(input="register_read %s %d" % (register, idx))
        reg_val = filter(lambda l: ' %s[%d]' % (register, idx) in l, stdout.split('\n'))[0].split('= ', 1)[1]
        return long(reg_val)
    else:
        stdout, stderr = thrift_client.communicate(input="register_read %s" % (register))
        return stdout
            
def writeRegister(thrift_port, register, idx, value):
    thrift_client = connect(thrift_port=thrift_port)
    entry = "register_write %s %d %d" % (register, idx, value)
    print(entry)
    stdout, stderr = thrift_client.communicate(input=entry)
    # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
    for line in stdout.splitlines():
        print("  " + line)
        
def setup_start_time(thrift_port):
    offset = int(time()*1e9)
    offset -= 1000 * 1e6 # substract 1000 ms  to compesate a little earlier bmv2 start
    print("Setting time offset %d", offset)
    writeRegister(thrift_port=thrift_port, register='start_timestamp', idx=0, value=offset)
        
def apply_commands(thrift_port, filename):
    with open(filename, 'r') as f:
        for line in f.readlines():
            if len(line)>0 and line[0] != '#':
                print('Sending by Thrift: ', line)
                thrift_client = connect(thrift_port=thrift_port)
                stdout, stderr = thrift_client.communicate(input=line)
                for line in stdout.splitlines():
                    print("   " + line)
                if len(stderr) > 0:
                    print("   " + stderr)
                

sleep(1)
setup_start_time(THRIFT_PORT)
apply_commands(THRIFT_PORT, "/examples/single_bmv2/commands.txt")