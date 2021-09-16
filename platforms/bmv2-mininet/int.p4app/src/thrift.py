import subprocess
import re


def connect(thrift_port):
    return subprocess.Popen(['simple_switch_CLI', '--thrift-port', str(thrift_port)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  

def readRegister(register, thrift_port, idx=None):
        p = connect(thrift_port)
        if idx is not None:
            stdout, stderr = p.communicate(input="register_read %s %d" % (register, idx))
            reg_val = filter(lambda l: ' %s[%d]' % (register, idx) in l, stdout.split('\n'))[0].split('= ', 1)[1]
            return long(reg_val)
        else:
            stdout, stderr = p.communicate(input="register_read %s" % (register))
            return stdout
           
            
def writeRegister(thrift_port, register, idx, value):
    p = connect(thrift_port)
    entry = "register_write %s %d %d" % (register, idx, value)
    print(entry)
    stdout, stderr = p.communicate(input=entry)
    # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
    for line in stdout.splitlines():
        #line = line.decode()
        print(line)