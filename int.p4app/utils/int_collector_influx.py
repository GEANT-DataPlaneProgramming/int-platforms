import argparse
import time
import socket
import struct
import binascii
import pprint
import logging
import io
from influxdb import InfluxDBClient

log_format = "[%(asctime)s] [%(levelname)s] - %(message)s"
logging.basicConfig(level=logging.INFO, format=log_format, filename="/tmp/p4app_logs/int_collector.log")
logger = logging.getLogger('int_collector')


def parse_params():
    parser = argparse.ArgumentParser(description='InfluxBD INTCollector client.')

    parser.add_argument("-i", "--int_port", default=54321, type=int,
        help="Destination port of INT Telemetry reports")

    parser.add_argument("-H", "--host", default="localhost",
        help="InfluxDB server address")

    parser.add_argument("-D", "--database", default="int_telemetry_db",
        help="Database name")

    parser.add_argument("-p", "--period", default=1, type=int,
        help="Time period to push data in normal condition")

    parser.add_argument("-d", "--debug_mode", default=0, type=int,
        help="Set to 1 to print debug information")

    return parser.parse_args()



class HopMetadata:
    def __init__(self, data, ins_map, int_version=1):
        self.data = data
        self.ins_map = ins_map
        
        self.__parse_switch_id()
        self.__parse_ports()
        self.__parse_hop_latency()
        self.__parse_queue_occupancy()
        
        self.__parse_ingress_timestamp()
        self.__parse_egress_timestamp()
        if int_version == 0:
            self.__parse_queue_congestion()
        elif int_version >= 1:
            self.__parse_l2_ports()
        self.__parse_egress_port_tx_util()
        
    def __parse_switch_id(self):
        if self.ins_map & 0x80:
            self.switch_id = int.from_bytes(self.data.read(4), byteorder='big')
            logger.debug('parse switch id: %d' % self.switch_id)
        
    def __parse_ports(self):
        if self.ins_map & 0x40:
            self.l1_ingress_port_id = int.from_bytes(self.data.read(2), byteorder='big')
            self.l1_egress_port_id = int.from_bytes(self.data.read(2), byteorder='big')
            logger.debug('parse ingress port: %d, egress_port: %d' % (self.l1_ingress_port_id , self.l1_egress_port_id))
        
    def __parse_hop_latency(self):
        if self.ins_map & 0x20:
            self.hop_latency  = int.from_bytes(self.data.read(4), byteorder='big')
            logger.debug('parse hop latency: %d' %  self.hop_latency)
    
    def __parse_queue_occupancy(self):
        if self.ins_map & 0x10:
            self.queue_occupancy_id = int.from_bytes(self.data.read(1), byteorder='big')
            self.queue_occupancy = int.from_bytes(self.data.read(3), byteorder='big')
            logger.debug('parse queue_occupancy_id: %d, queue_occupancy: %d' % (self.queue_occupancy_id, self.queue_occupancy))
            
    def __parse_ingress_timestamp(self):
        if self.ins_map & 0x08:
            self.ingress_timestamp  = int.from_bytes(self.data.read(8), byteorder='big')
            logger.debug('parse ingress_timestamp: %d' %  self.ingress_timestamp)
            
    def __parse_egress_timestamp(self):
        if self.ins_map & 0x04:
            self.egress_timestamp  = int.from_bytes(self.data.read(8), byteorder='big')
            logger.debug('parse egress_timestamp: %d' %  self.egress_timestamp)
     
    def  __parse_queue_congestion(self):
        if self.ins_map & 0x02:
            self.queue_congestion_id = int.from_bytes(self.data.read(1), byteorder='big')
            self.queue_congestion = int.from_bytes(self.data.read(3), byteorder='big')
            logger.debug('parse queue_congestion_id: %d, queue_congestion: %d' % (self.queue_congestion_id, self.queue_congestion))
            
    def  __parse_l2_ports(self):
        if self.ins_map & 0x02:
            self.l2_ingress_port_id = int.from_bytes(self.data.read(2), byteorder='big')
            self.l2_egress_port_id = int.from_bytes(self.data.read(2), byteorder='big')
            logger.debug('parse L2 ingress port: %d, egress_port: %d' % (self.l2_ingress_port_id , self.l2_egress_port_id))
            
    def  __parse_egress_port_tx_util(self):
        if self.ins_map & 0x01:
            self.egress_port_tx_util = int.from_bytes(self.data.read(4), byteorder='big')
            logger.debug('parse egress_port_tx_util: %d' % self.egress_port_tx_util)
            
    def unread_data(self):
        return self.data
            
    def __str__(self):
        attrs = vars(self)
        try:
            del attrs['data']
            del attrs['ins_map']
        except Exception as e: 
            logger.error(e)
        return pprint.pformat(attrs)



def ip2str(ip):
    return "{}.{}.{}.{}".format(ip[0],ip[1],ip[2],ip[3])



# ethernet(14B) + IP(20B) + UDP(8B)
UDP_OFFSET = 14 + 20 + 8
# ethernet(14B) + IP(20B) + TCP(20B)
TCP_OFFSET = 14 + 20 + 20



class IntReport():
    def __init__(self, data):
        orig_data = data
        #data = struct.unpack("!%dB" % len(data), data)
        '''
        header int_report_fixed_header_t {
            bit<4> ver;
            bit<4> len;
            bit<3> nprot;
            bit<6> rep_md_bits;
            bit<6> reserved;
            bit<1> d;
            bit<1> q;
            bit<1> f;
            bit<6> hw_id;
            bit<32> switch_id;
            bit<32> seq_num;
            bit<32> ingress_tstamp;
        }
        const bit<8> REPORT_FIXED_HEADER_LEN = 16;
        '''
        
        # report header
        self.int_report_hdr = data[:16]
        self.ver = self.int_report_hdr[0] >> 4
        
        if self.ver != 1:
            logger.error("Unsupported INT report version %s - skipping report" % self.int_version)
            raise Exception("Unsupported INT report version %s - skipping report" % self.int_version)
        
        self.len = self.int_report_hdr[0] & 0x0f
        self.nprot = self.int_report_hdr[1] >> 5
        self.rep_md_bits = (self.int_report_hdr[1] & 0x1f) + (self.int_report_hdr[2] >> 7)
        self.d = self.int_report_hdr[2] & 0x01
        self.q = self.int_report_hdr[3] >> 7
        self.f = (self.int_report_hdr[3] >> 6) & 0x01
        self.hw_id = self.int_report_hdr[3] & 0x3f
        self.switch_id, self.seq_num, self.ingress_tstamp = struct.unpack('!3I', orig_data[4:16])

        # flow id
        self.ip_hdr = data[30:50]
        self.udp_hdr = data[50:58]
        protocol = self.ip_hdr[9]
        self.flow_id = {
            'srcip': ip2str(self.ip_hdr[12:16]),
            'dstip': ip2str(self.ip_hdr[16:20]), 
            'scrp': struct.unpack('!H', self.udp_hdr[:2])[0],
            'dstp': struct.unpack('!H', self.udp_hdr[2:4])[0],
            'protocol': self.ip_hdr[9],       
        }

        # check next protocol
        # offset: udp/tcp + report header(16B)
        offset = 16
        if protocol == 17:
            offset = offset + UDP_OFFSET
        if protocol == 6:
            offset = offset + TCP_OFFSET

        '''
        header intl4_shim_t {
            bit<8> int_type;
            bit<8> rsvd1;
            bit<8> len;   // the length of all INT headers in 4-byte words
            bit<6> rsvd2;  // dscp not put here
            bit<2> rsvd3;
        }
        const bit<16> INT_SHIM_HEADER_LEN_BYTES = 4;
        '''
        # int shim
        self.int_shim = data[offset:offset + 4]
        self.int_type = self.int_shim[0]
        self.int_data_len = int(self.int_shim[2]) - 3
        
        if self.int_type != 1: 
            logger.error("Unsupported INT type %s - skipping report" % self.int_type)
            raise Exception("Unsupported INT type %s - skipping report" % self.int_type)
  
        '''  INT header version 0.4     
        header int_header_t {
            bit<2> ver;
            bit<2> rep;
            bit<1> c;
            bit<1> e;
            bit<5> rsvd1;
            bit<5> ins_cnt;  // the number of instructions that are set in the instruction mask
            bit<8> max_hops; // maximum number of hops inserting INT metadata
            bit<8> total_hops; // number of hops that inserted INT metadata
            bit<16> instruction_mask;
            bit<16> rsvd2;
        }'''
        
        '''  INT header version 1.0
        header int_header_t {
            bit<4>  ver;
            bit<2>  rep;
            bit<1>  c;
            bit<1>  e;
            bit<1>  m;
            bit<7>  rsvd1;
            bit<3>  rsvd2;
            bit<5>  hop_metadata_len;   // the length of the metadata added by a single INT node (4-byte words)
            bit<8>  remaining_hop_cnt;  // how many switches can still add INT metadata
            bit<16>  instruction_mask;   
            bit<16> rsvd3;
        }'''


        # int header
        self.int_hdr = data[offset + 4:offset + 12]
        self.int_version = self.int_hdr[0] >> 6
        if self.int_version == 0:
            self.hop_count = self.int_hdr[3]
        elif self.int_version == 1:
            self.hop_metadata_len = int(self.int_hdr[2] & 0x1f)
            self.remaining_hop_cnt = self.int_hdr[3]
            self.hop_count = int(self.int_data_len / self.hop_metadata_len)
        else:
            logger.error("Unsupported INT version %s - skipping report" % self.int_version)
            raise Exception("Unsupported INT version %s - skipping report" % self.int_version)

        self.ins_map = int.from_bytes(self.int_hdr[4:6], byteorder='big') 

        # int metadata
        self.int_meta = data[offset + 12:]
        logger.debug("Metadata (%d bytes) is: %s" % (len(self.int_meta), binascii.hexlify(self.int_meta)))
        self.hop_metadata = []
        self.int_meta = io.BytesIO(self.int_meta)
        for i in range(self.hop_count):
            try:
                hop = HopMetadata(self.int_meta, self.ins_map)
                self.int_meta = hop.unread_data()
                self.hop_metadata.append(hop)
            except Exception as e:
                logger.info("Metadata left (%s position) is: %s" % (self.int_meta.tell(), self.int_meta))
                logger.error(e)
                break
                
        logger.debug(vars(self))
            
    def __str__(self):
        hop_info = ''
        for hop in self.hop_metadata:
            hop_info += str(hop) + '\n'
        flow_tuple = "src_ip: %(srcip)s, dst_ip: %(dstip)s, src_port: %(scrp)s, dst_port: %(dstp)s, protocol: %(protocol)s" % self.flow_id 
        additional_info =  "sw: %s, seq: %s, int version: %s, ins_map: 0x%x, hops: %d" % (
            self.switch_id,
            self.seq_num,
            self.int_version,
            self.ins_map,
            self.hop_count,
        )
        return "\n".join([flow_tuple, additional_info, hop_info])
        


class IntCollector():
    
    def __init__(self, influx, period):
        self.influx = influx
        self.reports = []
        self.last_dstts = {} # save last `dstts` per each monitored flow
        self.last_reordering = {}  # save last `reordering` per each monitored flow
        self.period = period # maximum time delay of int report sending to influx
        self.last_send = time.time() # last time when reports were send to influx
        
    def add_report(self, report):
        self.reports.append(report)
        
        reports_cnt = len(self.reports)
        logger.debug('%d reports ready to sent' % reports_cnt)
        # send if many report ready to send or some time passed from last sending
        if reports_cnt > 100 or time.time() - self.last_send > self.period:
            logger.info("Sending %d reports to influx from last %s secs" % (reports_cnt, time.time() - self.last_send))
            self.__send_reports()
            self.last_send = time.time()
            
    def __prepare_report(self, report):
        flow_key = "%(srcip)s, %(dstip)s, %(scrp)s, %(dstp)s, %(protocol)s" % report.flow_id 
        
        try:
            origin_timestamp = report.hop_metadata[-1].ingress_timestamp
            # ingress_timestamp of sink node is crasy delayed - use ingress_timestamp instead
            destination_timestamp = report.hop_metadata[0].ingress_timestamp
        except Exception as e:
            origin_timestamp, destination_timestamp = 0, 0
            logger.error("ingress_timestamp in the INT hop is required, %s" % e)
        
        json_report = {
            "measurement": "int_telemetry",
            "tags": report.flow_id,
            'time': destination_timestamp,
            "fields": {
                "origts": 1.0*origin_timestamp,
                "dstts": 1.0*destination_timestamp,
                "seq": 1.0*report.seq_num,
                "delay": 1.0*(destination_timestamp-origin_timestamp),
                }
        }
        
        last_hop_delay = report.hop_metadata[-1].ingress_timestamp
        for index, hop in enumerate(reversed(report.hop_metadata)):
            if "hop_latency" in vars(hop):
                json_report["fields"]["latency_%d" % index] = hop.hop_latency
            if "ingress_timestamp" in vars(hop):
                json_report["fields"]["hop_delay_%d" % index] = hop.ingress_timestamp - last_hop_delay

        # add sink_jitter only if can be calculated (not first packet in the flow)  
        if flow_key in self.last_dstts:
            json_report["fields"]["sink_jitter"] = 1.0*destination_timestamp - self.last_dstts[flow_key]
        
        # add reordering only if can be calculated (not first packet in the flow)  
        if flow_key in self.last_reordering:
            json_report["fields"]["reordering"] = 1.0*report.seq_num - self.last_reordering[flow_key] - 1
                        
        # save dstts for purpose of sink_jitter calculation
        self.last_dstts[flow_key] = destination_timestamp
        
        # save dstts for purpose of sink_jitter calculation
        self.last_reordering[flow_key] = report.seq_num
        return json_report
        
    def __send_reports(self):
        json_body = []
        for report in self.reports:
            if report.hop_metadata:
                json_body.append(self.__prepare_report(report))
            else:
                logger.warning("Empty report metadata: %s" % str(report))
        logger.info("Json body for influx:\n %s" % pprint.pformat(json_body))
        if json_body:
            try:
                self.influx.write_points(json_body)
                self.last_send = time.time()
                logger.info(" %d int reports sent to the influx" % len(json_body))
            except Exception as e:
                logger.exception(e)
        self.reports = [] # clear reports sent

def unpack_int_report(packet):
    report = IntReport(packet)
    logger.info(report)
    return report
            

def influx_client(args):
    if ':' in args.host:
        host, port = args.host.split(':')
    else:
        host = args.host
        port = 8086
    user = 'int'
    password = 'gn4intp4'
    dbname = args.database

    client = InfluxDBClient(host, port, user, password, dbname)
    logger.info("Influx client ping response: %s" % client.ping())
    return client
    
    
def start_udp_server(args):
    bufferSize  = 65565
    port = args.int_port
    
    influx = influx_client(args)
    collector = IntCollector(influx, args.period)

    # Create a datagram socket
    sock = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    sock.bind(("0.0.0.0", port))
    logger.info("UDP server up and listening at UDP port: %d" % port)

    # Listen for incoming datagrams
    while(True):
        message, address = sock.recvfrom(bufferSize)
        logger.info("Received INT report (%d bytes) from: %s" % (len(message), str(address)))
        logger.debug(binascii.hexlify(message))
        try:
            report = unpack_int_report(message)
            if report:
                collector.add_report(report)
        except Exception as e:
            logger.exception("Exception during handling the INT report")


def test_hopmetadata():
    ins_map = 0b11001100 << 8
    data = struct.pack("!I", 1)
    data += struct.pack("!HH", 2, 3)
    data += struct.pack("!Q", 11)
    data += struct.pack("!Q", 12)
    meta = HopMetadata(data, ins_map)
    print(meta)


if __name__ == "__main__":
    args = parse_params()
    args.debug_mode = 1
    if args.debug_mode > 0:
        logger.setLevel(logging.DEBUG)
    start_udp_server(args)
