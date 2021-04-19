INT configuration guide
===========================================================================

The INT functionality for bmv2 switches is configured by command files located in ./int.p4app/commands/. 
For each bmv2 switch a single command file is required. Each command file contains a set of commands applied for `simple_switch_CLI` utility
(https://github.com/p4lang/behavioral-model/blob/main/docs/runtime_CLI.md)

Enabling INT source for an ingress port
------

INT source functionality is enabled per a switch port. Without this command, it is not possible to perform INT monitoring for the incoming traffic flow even 
it will be added to the INT watchlist. In general it should be done for each switch port where incoming traffic is entering our network. 

```
table_add tb_activate_source activate_source {ingress-port} =>
```
where:
* `ingress-port` - ingress port for which INT source functionality is enabled

Here is example of this command:
```
table_add tb_activate_source activate_source 1 =>
```
This command must be repeated for each ingress port of the switch.

Adding 4-tuple flow to the INT watchlist
------
In order to activate INT monitoring of the traffic flow a INT watch table must contain entry for a given flow. 
The following commands allows us to configure an entry in this table:

```
table_add tb_int_source configure_source {source-ip}&&&(source-ip-bitmask) {destination-ip}&&&(destination-ip-bitmask) 
                                         {source-port}&&&(source-port-bitmask) {destination-port}&&&(destination-port-bitmask) 
                                         => {int-max-hops} {int-hop-metadata-len} {int-hop-instruction-cnt} {int-instruction-bitmap} {table-entry-priority}
```
where:
* `source-ip`, `source-port`, `destination-ip`, `destination-port` defines 4-tuple flow which will be monitored using INT functionality
* `int-max-hops` - how many INT nodes can add their INT node metadata to packets of this flow
* `int-hop-metadata-len` - INT metadata words are added by a single INT node
* `int-hop-instruction-cnt` - how many INT headers must be added by a single INT node
* `int-instruction-bitmap` - instruction_mask defining which information (INT headers types) must added to the packet
* `table-entry-priority` - general priority of entry in match table (not related to INT)

`int-instruction-bitmap` example values:
* 0xFF - all defined INT metadata headers should be added to a flow frame
* 0xCC - INT node must add node id, ingress and egress L1 port ids, ingress and egress timestamps
* 0x0C - INT node must add node id, ingress and egress L1 port ids

Example of command activating INT monitoring for a traffic flow 10.0.1.1:4607 --> 10.0.2.2:8959
```
table_add tb_int_source configure_source 10.0.1.1&&&0xFFFFFFFF 10.0.2.2&&&0xFFFFFFFF 0x11FF&&&0x0000 0x22FF&&&0x0000 => 4 10 8 0xFF 0
```

Enabling INT transit functionality within a switch
------
In order to allow P4 node to perform role of INT transit, INT switch identifier and MTU size must be provided.
The following command enables INT transit functionality for a switch:
```
table_add tb_int_transit configure_transit => {int-node-identifier} {allowed-mtu}
```
where:
* `int-node-identifier` - switch id which is used within INT node metadata
* `allowed-mtu` - layer 3 packet MTU size which must be not exceeded when adding INT metadata to a frame

INT transit functionality must be also configured for switches performing role of INT source and/or INT sink for some their ports. 
To be precise, INT transit functionality is responsible for addition of INT node metadata to a monitored frame.

Here is example of this command:
```
table_add tb_int_transit configure_transit => 1 1500
```

Enabling INT sink for an egress port
------
INT sink functionality is enabled per a switch port. Without this command, it is not possible to perform INT metadata extraction 
and INT reporting for the monitored traffic flow. In general it should be done for each switch port where network traffic is exiting our network. 
```
table_add tb_int_sink configure_sink {egress-port} => {int-reporting-port}
```
where:
* `egress-port` - egress port for which INT sink functionality is enabled
* `int-reporting-port` - switch port number where INT reports should be send out from a switch

Here is example of this command enabling INT sink functionality for egress port 4.
```
table_add tb_int_sink configure_sink 1 => 4
```

Additionally, in order to allow proper working of INT reporting a proper traffic mirroring must be configured:

```
mirroring_add 1 {int-reporting-port}
```
where:
* `int-reporting-port` - switch port number where INT reports should be send out from a switch

Here is example of this command allowing INT reporting using switch port 4.
```
mirroring_add 1 4
```

