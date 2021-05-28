..
   SPDX-FileCopyrightText: © 2021 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

PDP Testing
==============


Test Framework
--------------

We use `TestVectors`_ to connect to Stratum hardware switches using gRPC and execute gNMI and P4Runtime tests.
For Aether, we convert existing ptf unit tests written for fabric-tna to TestVectors and execute them on Stratum
hardware switches in loopback mode using `TestVectors-Runner`_.

We use Jenkins to schedule and trigger our tests which run against a set of hardware switches.

Test Scenarios
-------------------

fabric-tna is a P4 program based on the Tofino Native Architecture(TNA). Currently 4 profiles are supported for
compiling the fabric-tna P4 program.

1. fabric
2. fabric-spgw
3. fabric-int
4. fabric-spgw-int

Based on the ptf unit tests for fabric-tna, we generate TestVectors for each profile to run on Stratum hardware
switches. The names of generated tests can be found in `Test List`_.

Prerequisites to Generate, Run Tests
--------------------------------------
1. Stratum running on a hardware switch with 4 ports running in loopback mode.
2. Create a port-map similar to `port-map`_. The three fields are ptf_port, p4_port and iface_name.
   ptf_port is the port id used in the test, p4_port is a valid port id from Stratum hardware.
   iface_name is ignored in TestVector generation, this can be any value.

How to Generate TestVectors
--------------------------------------
1. Checkout fabric-tna repo.

.. code-block:: shell

   $git clone https://github.com/stratum/fabric-tna.git
   $cd fabric-tna

2. Compile the P4 program for specific profile.

.. code-block:: shell

   $make <profile>

Supported profiles are: fabric, fabric-spgw, fabric-int, fabric-spgw-int.

3. Generate TestVectors.

.. code-block:: shell

   $cd ptf
   $run/tv/run <profile> PORTMAP=port_map.json GRPCADDR=<switch_ip>:<switch_port> CPUPORT=<cpu_port>

switch_ip and switch_port are IP and port where Stratum is running.
cpu_port is 192 for dual pipe switch and 320 for quad pipe switch.
Generated TestVectors are stored under 'fabric-tna/ptf/TestVectors'.

How to Run TestVectors
--------------------------------------
1. Checkout `TestVectors-Runner`_ repo.

.. code-block:: shell

   $git clone https://github.com/stratum/testvectors-runner -b support-fabric-tna
   $cd testvectors-runner

2. Build tv-runner docker image.

.. code-block:: shell

   $docker build -t tvrunner:fabric-tna-binary -f build/test/Dockerfile .

3. Push PipelineConfig.

.. code-block:: shell

   $IMAGE_NAME=tvrunner:fabric-tna-binary ./tvrunner.sh --target ${tv_dir}/target.pb.txt --portmap ${tv_dir}/portmap.pb.txt --tv-dir ${tv_dir} --dp-mode loopback --tv-name PipelineConfig

4. Run Setup.

.. code-block:: shell

   $IMAGE_NAME=tvrunner:fabric-tna-binary ./tvrunner.sh --dp-mode loopback --match-type in --target ${tv_dir}/target.pb.txt --portmap ${tv_dir}/portmap.pb.txt --tv-dir ${tv_dir}/${test_name}/setup

5. Run TestVector.

.. code-block:: shell

   $IMAGE_NAME=tvrunner:fabric-tna-binary ./tvrunner.sh --dp-mode loopback --match-type in --target ${tv_dir}/target.pb.txt --portmap ${tv_dir}/portmap.pb.txt --tv-dir ${tv_dir}/${test_name} --tv-name ${test_name}.* --result-dir ./results --result-file ${test_name}

6. Run Teardown.

.. code-block:: shell

   $IMAGE_NAME=tvrunner:fabric-tna-binary ./tvrunner.sh --dp-mode loopback --match-type in --target ${tv_dir}/target.pb.txt --portmap ${tv_dir}/portmap.pb.txt --tv-dir ${tv_dir}/${test_name}/teardown

tv_dir is the directory where TestVectors are stored. In this case, tv_dir is 'fabric-tna/ptf/TestVectors'.
tv_name is the name of the test case. It's also the directory name of the test under 'fabric-tna/ptf/TestVectors'.

Results for each test are generated under 'testvectors-runner/results' directory in csv format.

.. _TestVectors: https://github.com/stratum/testvectors
.. _TestVectors-Runner: https://github.com/stratum/testvectors-runner/tree/support-fabric-tna
.. _Test List: https://github.com/stratum/stratum-ci/blob/master/ptf_tv_resources/converted-tests.yaml
.. _port-map: https://github.com/stratum/stratum-ci/blob/master/ptf_configs/x86-64-stordis-bf2556x-1t-r0/port_map.json
