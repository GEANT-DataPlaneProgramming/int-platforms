P4 INT implementation for Tofino switches
=========================================

This is P4 implementation of In-Band Network Telemetry (https://p4.org/specs/) suitable for Tofino switches, deployed and tested as part of the GEANT Data Plane Programmibilty activity (https://wiki.geant.org/display/NETDEV/INT).

Compiling this codebase for Tofino requires the Intel Tofino SDE, currently version 9.6.

All INT code  is under the Apache 2.0 licence.


In-Band Network Telemetry
------

In-Band Network Telemetry (INT) is specified by the P4 language community and can provide very detailed information on network behavior by inserting a small amount of data directly inside packets passing through network devices where INT functionality is enabled, essentially adding probing functionality to potentially every packet, including  and especially customer traffic. 
This makes INT a very powerful debugging tool, capable of measuring and recording the 'experience' of each tagged packet carried over a network.

![INT workflow](docs/int-workflow.png)


Installation
------------

1. Install the Intel Tofino SDE if you don't have it ready, and make sure that the `$SDE` and `SDE_INSTALL` environment variables are correctly set.

2. Run the provided `build_tofino.sh` script. It will compile the code for Tofino using the SDE's compiler as a new p4 program called `int`, and install it within the default SDE folder for compiled programs. You can then run it with e.g. `p4run -p int`.


Configuration
-------------

Coming soon.
