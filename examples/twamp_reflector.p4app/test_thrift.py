
import logging
logging.basicConfig(level="DEBUG")

import thrift_utils as dp
CLIENT_IP = 0x0a000101;
CLIENT_PORT = 20001;
reflector_ip = "10.0.0.254"
reflector_port = 8975;
match_fields = "1 %s %d %s %d" % (CLIENT_IP,  CLIENT_PORT, reflector_ip, reflector_port)
session_handle_id = dp.addTableEntry(thrift_port=22222, table_name='ingress.TwampReflector.tb_twamp_reflector', action_name='twamp_reflect', 
                          match_fields=match_fields)

