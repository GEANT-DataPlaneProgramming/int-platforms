# Copyright 2020-2021 PSNC
# Author: Damian Parniewicz
#
# Created in the GN4-3 project.
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
# limitations under the License

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
