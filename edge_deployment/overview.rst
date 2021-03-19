..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Overview
========

A Pronto deployment must have a detailed plan of the network topology and
devices, and required cabling before being put assembled.

Once planning is complete, equipment should be ordered to match the plan. The
VAR we've used for most Pronto equipment is ASA (aka "RackLive").

.. _network_cable_plan:

Network Cable Plan
------------------

If a 2x2 TOST fabric is used it should be configured as a :doc:`Single-Stage
Leaf-Spine <trellis:supported-topology>`.

- The links between each leaf and spine switch must be made up of two separate
  cables.

- Each compute server is dual-homed via a separate cable to two different leaf
  switches (as in the "paired switches" diagrams).

If only a single P4 switch is used, the :doc:`Simple
<trellis:supported-topology>` topology is used, with two connections from each
compute server to the single switch

Additionally a non-fabric switch is required to provide a set of management
networks.  This management switch is configured with multiple VLANs to separate
the management plane, fabric, and the out-of-band and lights out management
connections on the equipment.


This diagram shows all the equipment used in a Pronto deployment.

.. image:: images/pronto_logical_diagram.svg
   :alt: Logical Network Diagram


Required Hardware
-----------------

Fabric Switches
"""""""""""""""

Pronto currently uses fabric switches based on the Intel (was Barefoot) Tofino
chipset.  There are multiple variants of this switching chipset, with different
speeds and capabilities.

The specific hardware models in use in Pronto:

* `EdgeCore Wedge100BF-32X
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=335>`_
  - a "Dual Pipe" chipset variant, used for the Spine switches

* `EdgeCore Wedge100BF-32QS
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=770>`_
  - a "Quad Pipe" chipset variant, used for the Leaf switches

Compute Servers
"""""""""""""""

These servers run Kubernetes and edge applications.

The requirements for these servers:

* AMD64 (aka x86-64) architecture
* Sufficient resources to run Kubernetes
* Two 40GbE or 100GbE Ethernet connections to the fabric switches
* One management 1GbE port

The specific hardware models in use in Pronto:

* `Supermicro 6019U-TRTP2
  <https://www.supermicro.com/en/products/system/1U/6019/SYS-6019U-TRTP2.cfm>`_
  1U server

* `Supermicro 6029U-TR4
  <https://www.supermicro.com/en/products/system/2U/6029/SYS-6029U-TR4.cfm>`_
  2U server

These servers are configured with:

* 2x `Intel Xeon 5220R CPUs
  <https://ark.intel.com/content/www/us/en/ark/products/199354/intel-xeon-gold-5220r-processor-35-75m-cache-2-20-ghz.html>`_,
  each with 24 cores, 48 threads
* 384GB of DDR4 Memory, made up with 12x 16GB ECC DIMMs
* 2TB of nVME Flash Storage
* 2x 6TB SATA Disk storage
* 2x 40GbE ports using an XL710QDA2 NIC

The 1U servers additionally have:

- 2x 1GbE copper network ports
- 2x 10GbE SFP+ network ports

The 2U servers have:

- 4x 1GbE copper network ports

Management Server
"""""""""""""""""

One management server is required, which must have at least two 1GbE network
ports, and runs a variety of network services to support the edge.

The model used in Pronto is a `Supermicro 5019D-FTN4
<https://www.supermicro.com/en/Aplus/system/Embedded/AS-5019D-FTN4.cfm>`_

Which is configured with:

* AMD Epyc 3251 CPU with 8 cores, 16 threads
* 32GB of DDR4 memory, in 2x 16GB ECC DIMMs
* 1TB of nVME Flash storage
* 4x 1GbE copper network ports

Management Switch
"""""""""""""""""

This switch connects the configuration interfaces and management networks on
all the servers and switches together.

In the Pronto deployment this hardware is a `HP/Aruba 2540 Series JL356A
<https://www.arubanetworks.com/products/switches/access/2540-series/>`_.

