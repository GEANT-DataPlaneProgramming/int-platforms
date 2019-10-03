p4app
=====

p4app is a tool that can build, run, debug, and test P4 programs. The
philosophy behind p4app is "easy things should be easy" - p4app is designed to
make small, simple P4 programs easy to write and easy to share with others.

Installation
------------

1. Install [docker](https://docs.docker.com/engine/installation/) if you don't
   already have it.

2. If you want, put the `p4app` script somewhere in your path. For example:

    ```
    cp p4app /usr/local/bin
    ```
I have already modified the default docker image to **dingdamu/p4app-ddos**, so `p4app` script can be used directly.

Usage
-----

p4app runs p4app packages. p4app packages are just directories with a `.p4app`
extension - for example, if you wrote a router in P4, you might place it in
`router.p4app`. Inside the directory, you'd place your P4 program, any
supporting files, and a `p4app.json` file that tells p4app how to run it.

Here's how you can run it:

```
p4app run examples/hh.p4app
```

If you run this command, you'll find yourself at a Mininet command prompt. p4app
will automatically download a Docker image containing the P4 compiler and tools,
compile `countmin.p4`, and set up a container with a simulated network you
can use to experiment. In addition to Mininet itself, you can use `tshark`,
`scapy`, and the net-tools and nmap suites right out of the box.


That's pretty much it! There's one more useful command, though. p4app caches the
P4 compiler and tools locally, so you don't have to redownload them every time,
but from time to time you may want to update to the latest versions. When that
time comes, run:

```
p4app update
```

Creating a p4app package
------------------------

Our p4app package has a directory structure that looks like this:

```
  hh.p4app
    |
    |- p4app.json
    |
    |- p4src/countmin.p4
    |
    |- read_registers1.sh
    |
    |- read_registers2.sh
    |
    |- read_registers3.sh
    |
    |- debug_switch1.sh
    |
    |- debug_switch2.sh
    |
    |- debug_switch3.sh
    |
    |- xterm_h1.sh
    |
    |- xterm_h2.sh
    |
    |- xterm_h3.sh





```

The `p4app.json` file is a package manifest that tells p4app how to build and
run a P4 program; it's comparable to a Makefile. Here's how our p4app looks:

```
{
  "program": "p4src/countmin.p4",
  "language": "p4-14",
  "targets": {
      "custom": {
	       "program": "topo.py"
      }
  }
}
```
It is possible to define the topology, P4-switch and host properties in `topo.py`

Testbed and implementation details
----------------------------------
Our emulation environment is composed by three switches emulated with Mininet. The adopted triangular topology is shown below. Each switch connects to a host, and the flows in the network are identified by {srcIP, dstIP} pairs.
![](https://raw.githubusercontent.com/p4lang/tutorials/master/exercises/basic_tunnel/topo.png)

To implement Count-min Sketch, we used four one-dimensional 30-slots registers. We chose `xxhash` to implement the needed pairwise-independent hash functions, and each register uses a different `xxhash` function depending on the index of registers.

To perform the query operation on the sketch, we set a `count_min` variable to the queried value for the first register (associated to the index of the first hashed value). Consequently, the queried value for the remaining registers is compared with `count_min`. If  the queried value for a register is smaller than current `count_min` value, then `count_min` value is updated accordingly. The final `count_min` value is thus the packet count estimation for the queried flow.

Additionally, all registers in the switch can be read by using the `./read_registers.sh` script: registers 1 to 4 represent the rows of Count-min Sketch.

```
    ./read_registers1.sh
    ./read_registers2.sh
    ./read_registers3.sh
```

The debug mode for each switch can be enabled by using:

``` 
    ./debug_switch1.sh
    ./debug_switch2.sh
    ./debug_switch3.sh
```    

The  terminal for each host are available by using:

``` 
    ./xterm_h1.sh
    ./xterm_h2.sh
    ./xterm_h3.sh
```    

The resulted logs and pcap files are in `/tmp/p4app_logs`
