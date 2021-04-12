..
   SPDX-FileCopyrightText: © 2021 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Fabric Testing
==============


Test Framework
--------------

We use `TestON`_ to connect to and manipulate different test components using CLI or REST
API. These tests use a common set of library functions for Segment Routing testing to
make writing new tests easier. For Aether, we are porting our existing set of Segment
Routing functionality tests written for Mininet to using Stratum hardware switches.

We use Jenkins to schedule and trigger our tests which run against either the QA Pod or
the Staging Pod.

Resources:
^^^^^^^^^^

#. `ONOS System Test Guide`_
#. `Segment Routing Funcationality Test Plan`_

Integration Testing
-------------------

We are in the process of moving existing functionality tests to written for OVS or BMv2
software switches running in Mininet to running on hardware switches, starting with
bridging and routing functionality. These tests will run nightly on the QA Pod.

Failure/Recovery Performance Testing
------------------------------------

We run several experiments every night on the Staging Pod and measure the performance of
Aether during the experiment.
The test job can be found in Aether Jenkins under `tost-teston-staging-nightly`.

#. Port Down/Up

    * **Summary**: Uses onos CLI `portstate` command to send gNMI request to disable/enable
      a port on a leaf leading to a spine. There are two versions of this test, one on the
      access leaf and one on the upstream leaf.

    * **Test code**:

       * `Access Leaf Port Failure/Recovery Test`_

       * `Upstream Leaf Port Failure/Recovery Test`_

#. Stratum Agent Stop/Start

    * **Summary**: Uses Kubernetes to delete/restart the stratum pod on a spine

    * **Test code**:

       * `Stratum Restart Test`_

#. ONL Shutdown/Startup

    * **Summary**: Restart ONL on a spine

    * **Test code**:

       * `ONL Reboot Test`_

#. ONOS Node Reboot

    * **Summary**: Restart each ONOS node in the cluster one by one

    * **Test code**: To be implemented

        * `Rolling ONOS Restart Test`_

.. _TestON: https://github.com/opennetworkinglab/OnosSystemTest
.. _ONOS System Test Guide: https://wiki.onosproject.org/display/ONOS/System+Testing+Guide
.. _Segment Routing Funcationality Test Plan: https://wiki.opencord.org/display/CORD/Test+Plan+-+Fabric+Control
.. _Access Leaf Port Failure/Recovery Test: https://github.com/opennetworkinglab/OnosSystemTest/tree/master/TestON/tests/USECASE/SegmentRouting/SRStaging/SReNBLeafSpinePortstateFailure
.. _Upstream Leaf Port Failure/Recovery Test: https://github.com/opennetworkinglab/OnosSystemTest/tree/master/TestON/tests/USECASE/SegmentRouting/SRStaging/SRupstreamLeafSpinePortstateFailure
.. _Stratum Restart Test: https://github.com/opennetworkinglab/OnosSystemTest/tree/master/TestON/tests/USECASE/SegmentRouting/SRStaging/SRstratumRestart
.. _ONL Reboot Test: https://github.com/opennetworkinglab/OnosSystemTest/tree/master/TestON/tests/USECASE/SegmentRouting/SRStaging/SRONLReboot
.. _Rolling ONOS Restart Test: https://github.com/opennetworkinglab/OnosSystemTest/tree/master/TestON/tests/USECASE/SegmentRouting/SRStaging/SRrollingRestart
