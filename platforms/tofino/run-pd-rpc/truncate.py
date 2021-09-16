#
# Simple mirror session setup script
#
# It is required to truncate the packet length
# max_pkt_len: the maximum packet length
# mir_id: mirror session ID
# egr_port: egress port
clear_all()


print("Mirror destination 5 -- sending to CPU port") 
mirror.session_create(
    mirror.MirrorSessionInfo_t(
        mir_type=mirror.MirrorType_e.PD_MIRROR_TYPE_NORM,
        direction=mirror.Direction_e.PD_DIR_BOTH,
        mir_id=5,
        egr_port=64, egr_port_v=True,
        max_pkt_len=16384))

conn_mgr.complete_operations()
