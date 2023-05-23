..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0


Pronto Deployment
=================

One of the earliest structured deployments of Aether was as a part of `Pronto
<https://prontoproject.org/>`_ project.

The topology used in Pronto is a 2x2 :ref:`Leaf-Spine (without pairing)
<sdfabric:specification:topology>`, which provide Spine redundancy, but does
not support dual-homing of devices.

.. image:: images/edge_2x2.svg
   :alt: 2x2 Leaf-Spine (without pairing) topology

The specific deployment includes a production
cluster with multiple servers and a 2x2 leaf-spine fabric, along with a
secondary development cluster with it's own servers and fabric switch, as
shown in this diagram:

.. image:: images/pronto_logical_diagram.svg
   :alt: Logical Network Diagram

5x Fabric Switches (4 in a 2x2 fabric for production, 1 for development)

* `EdgeCore Wedge100BF-32X
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=335>`_
  - a "Dual Pipe" chipset variant, used for the Spine switches

* `EdgeCore Wedge100BF-32QS
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=770>`_
  - a "Quad Pipe" chipset variant, used for the Leaf switches

7x Compute Servers (5 for production, 2 for development):

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

1x Management Switch: `HP/Aruba 2540 Series JL356A`
*https://www.arubanetworks.com/assets/ds/DS_2540SwitchSeries.pdf*.

1x Management Server: `Supermicro 5019D-FTN4
<https://www.supermicro.com/en/Aplus/system/Embedded/AS-5019D-FTN4.cfm>`_,
configured with:

* AMD Epyc 3251 CPU with 8 cores, 16 threads
* 32GB of DDR4 memory, in 2x 16GB ECC DIMMs
* 1TB of nVME Flash storage
* 4x 1GbE copper network ports

For Pronto, the primary reseller ONF and Stanford used was `ASA (aka
"RackLive") <https://www.asacomputers.com/>`_. for servers and switches, with
radio equipment purchased directly from `Sercomm <https://www.sercomm.com>`_.


Pronto BoM Table
""""""""""""""""

============ ===================== ===============================================
Quantity     Type                  Description/Use
============ ===================== ===============================================
5            P4 Fabric Switch      2x2 topology, plus 1 development switch
1            Management Switch     Must be Layer 2/3 capable
1            Management Server     2x 40GbE QSFP ports recommended
5            1U Compute Servers
2            2U Compute Servers
6            100GbE QSFP DAC cable Between Fabric switches
14           40GbE QSFP DAC cable  Between Compute, Management, and Fabric Switch
2            QSFP to 4x SFP+ DAC   Split cable between Fabric and eNB
2            eNB
2            10GbE to 1GbE Media   Required unless using switch to convert from
             converter             fabric to eNB
2            PoE+ Injector         Required unless using a PoE+ Switch
Sufficient   Cat6 Network Cabling  Between all equipment, for management network
============ ===================== ===============================================
