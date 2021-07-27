..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Overview
========

There are many ways to deploy Aether, depending on the requirements of the edge
site. The Reliability, Availability, and Serviceability (RAS) of each set of
equipment will differ depending on the characteristics of each edge.

This document provides several hardware deployment options and explains the
differences between them.

Deployment Options
------------------

Development Environments
""""""""""""""""""""""""

For users looking for a development or fully software-simulated environment,
there is ``Aether-in-a-Box (AiaB)`` - instructions for running this can be
found in the :doc:`Aether SD-Core Developer Guide </developer/sdcore>`.  AiaB
is only suitable for testing and developing software, and can't connect to
physical hardware, but is a good choice for learning about the different
software components of Aether.

Production Environments
"""""""""""""""""""""""

Deploying Aether on hardware is required for both production deployments and
testing.

This document currently describes the P4-based UPF implementation of Aether.
There is also a :doc:`Software-only BESS UPF
</edge_deployment/bess_upf_deployment>`, which can be used for deployments that
do not have P4 switching hardware.

Before deploying Aether, a detailed plan including the network topology,
hardware, and all cabling needs to be created.

For redundancy of workloads running in Kubernetes, at least 3 compute nodes
must be available. A single or pair of compute nodes can be used, but software
would need to be configured without High Availability (HA) enabled.

Network Cable Plan
------------------

If only a single P4 switch is used, the :doc:`Simple
<trellis:supported-topology>` topology can be used, but provides no network
redundancy:

.. image:: images/edge_single.svg
   :alt: Single Switch

If another switch is added, and a "Paired Leaves"  (aka :doc:`Paired Switches
<trellis:supported-topology>`) topology is used, which can tolerate the loss of
a leaf switch and retain connections for all dual-homed devices. Single homed
devices on the failed leaf would need another form of HA, for example,
deploying multiple eNBs where some are connected to each leaf, and can provide
radio coverage.:

.. image:: images/edge_paired_leaves.svg
   :alt: Paired Leaves

For larger deployments, a 2x2 fabric can be configured (aka :doc:`Single-Stage
Leaf-Spine <trellis:supported-topology>`), which provide Spine redundancy, but
does not support dual-homing of devices.

.. image:: images/edge_2x2.svg
   :alt: 2x2 Fabric

.. note::

  Connections to the Fabric switches in these diagrams can be made up of two
  cables, and configured to tolerate the failure or replacement of one cable or
  NIC port.  This is recommended, especially for links between switches.


Required Hardware
-----------------

Fabric Switches
"""""""""""""""

Aether recommends the use of fabric switches based on the Intel (was Barefoot)
Tofino chipset, which are capable of running the P4 UPF.  There are multiple
variants of this switching chipset, with different resources and capabilities.

Currently supported P4 switches include:

* `EdgeCore Wedge100BF-32X
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=335>`_
  - a "Dual Pipe" chipset

* `EdgeCore Wedge100BF-32QS
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=770>`_
  - a "Quad Pipe" chipset

Compute Servers
"""""""""""""""
These servers run Kubernetes, Aether connectivity apps, and edge applications.

Minimum hardware specifications:

* AMD64 (aka x86-64) architecture
* 8 CPU Cores
* 32GB of RAM
* 250 GB of storage (SSD preferred)
* 2x 40GbE or 100GbE Ethernet connections to P4 switches
* 1x 1GbE management network port

Optional:

* Lights out management support, with either shared or separate NIC

Management Server
"""""""""""""""""

One management server is required, which must have at least two 1GbE network
ports, and runs a variety of network services to bootstrap and support the
edge.

In current Aether deployments, the Management Server also functions as a router
and VPN gateway back to Aether Central.

Minimum hardware specifications:

* AMD64 (aka x86-64) architecture
* 4 CPU cores
* 8GB of RAM
* 120GB of storage (SSD preferred)
* 2x 1GbE Network interfaces (one for WAN, one to the management switch)

Optional:

* 10GbE or 40GbE network card to connect to fabric switch

Management Switch
"""""""""""""""""

A managed L2/L3 management switch is required to provide connectivity within
the cluster for bootstrapping equipment.  It is configured with multiple VLANs
to separate the management plane, fabric, and the out-of-band and lights out
management connections on the equipment.

Minimum requirements:

* 16x 1GbE Copper ports

* 2x 10GbE SFP+ or 40GbE QSFP interfaces (only required if management server
  does not have a network card with these ports)

* Managed via SSH or web interface

* Capable supporting VLANs on each port, with both tagged and untagged traffic
  sharing a port.

Optional:

* PoE+ support, which can power eNB and monitoring hardware.


eNB Radio
"""""""""

The LTE eNB used in most deployments is the `Sercomm P27-SCE4255W Indoor CBRS
Small
Cell <https://www.sercomm.com/contpage.aspx?langid=1&type=prod3&L1id=2&L2id=1&L3id=107&Prodid=751>`_.

This supports PoE+ power on the WAN port, which provides deployment
flexibility.

Testing hardware
----------------

The following hardware is used to test the network and determine uptime of
edges.  It's currently required, to properly validate that an edge site is
functioning properly.

Monitoring Raspberry Pi and CBRS dongle
"""""""""""""""""""""""""""""""""""""""

One pair of Raspberry Pi and CBRS band supported LTE dongle is required to
monitor the connectivity service at the edge.

The Raspberry Pi model used in Pronto is a `Raspberry Pi 4 Model B/2GB
<https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/>`_

Which is configured with:

* HighPi Raspberry Pi case for P4
* USB-C Power Supply
* MicroSD Card with Raspbian - 16GB

One LTE dongle model supported in Aether is the `Sercomm Adventure Wingle
<https://www.sercomm.com/contpage.aspx?langid=1&type=prod3&L1id=2&L2id=2&L3id=110&Prodid=767>`_.
