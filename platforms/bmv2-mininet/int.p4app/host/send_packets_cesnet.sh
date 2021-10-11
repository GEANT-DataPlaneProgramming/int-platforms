while true 
do
        sleep 60;
        process_id=`h1_cesnet_udp_flow`
        if [ -z "$process_id" ];
                then
                echo "UDP Flow is starting"
            python /tmp/host/h1_cesnet_udp_flow.py
        fi
done
