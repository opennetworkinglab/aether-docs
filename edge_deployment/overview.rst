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
found in the :doc:`Setting Up Aether-in-a-Box </developer/aiab>`.  AiaB
is only suitable for testing and developing software, and can't connect to
physical hardware, but is a good choice for learning about the different
software components within Aether.

Production Environments
"""""""""""""""""""""""

Deploying Aether on hardware is required for both production deployments and
hardware testing.  Before deploying Aether, a detailed plan including the
network topology, hardware, and all cabling needs to be created.

For redundancy of workloads running in Kubernetes, at least 3 compute nodes
must be available. A single or pair of compute nodes can be used, but software
would need to be configured without High Availability (HA) enabled.

The topologies below are *simplified physical topologies* to show the equipment
needed and the minimal connectivity between devices. Within these topologies,
multiple VLANs, routing, and other network-level configuration is required to
make a functional Aether edge.

There are also possible RAS improvements that can be done at a topology level -
for example, fabric switch connections can be made with two cables, and
configured to tolerate the failure or replacement of one cable or NIC port,
which is recommended especially for inter-switch links.

Edge Connectivity
-----------------

Aether's is a managed service, and Aether Edges require a constant connection
via VPN to the 4G and 5G core in Aether Central for managing subscriber
information.

The edge site must provide internet access to the Aether edge, specifically the
Management Server. The traffic required is:

* VPN connection (ESP protocol, Ports UDP/500 and UDP/4500) to Aether Central

* SSH (TCP/22). used for installation, troubleshooting, and updating the site.

* General outgoing internet access used for installation of software and other
  components from ONF and public (Ubuntu) software repositories.

The open ports can be restricted to specific internet addresses which are used
for Aether.

The Management Server needs to have an IP address assigned to it, which can be either:

* A public static IP address

* Behind NAT with port forwarding with the ports listed above forwarded to the
  Management Server

In either case, the Management Server's IP address should be assigned using
a reserved DHCP if possible, which eases the installation process.

BESS-based Network Topology
---------------------------

The :doc:`Software-only BESS UPF
</edge_deployment/bess_upf_deployment>`, which can be used for deployments that
do not have P4 switching hardware.

.. image:: images/edge_mgmt_only.svg
   :alt: BESS network topology


`BESS <https://github.com/NetSys/bess>`_ runs on an x86 compute server, and is
deployed using Kubernetes. In production it requires an SR-IOV capable network
card, and specific K8s CNIs to be used.

The Management Server and Switch must be configured with multiple VLANs and
subnets with routing required for the BESS UPF.

P4-based Network Topology
-------------------------

If only a single P4 switch is used, the :doc:`Simple
<trellis:supported-topology>` topology can be used, but provides no network
redundancy:

.. image:: images/edge_single.svg
   :alt: Single Switch Topology

If another switch is added, the "Paired Leaves" (aka :doc:`Paired Switches
<trellis:supported-topology>`) topology can be used, which can tolerate the
loss of a leaf switch and still retain connections for all dual-homed devices.
Single homed devices on the failed leaf would lose their connections (the
single-homed server is shown for reference, and not required). If HA is needed
for single-homed devices, one option would be to deploying multiple of those
devices in a way that provides that redundancy - for example, multiple eNBs
where some are connected to each leaf and have overlapping radio coverage:

.. image:: images/edge_paired_leaves.svg
   :alt: Paired Leaves Topology

For larger deployments, a 2x2 fabric can be configured (aka :doc:`Single-Stage
Leaf-Spine <trellis:supported-topology>`), which provide Spine redundancy, but
does not support dual-homing of devices.

.. image:: images/edge_2x2.svg
   :alt: 2x2 Fabric Topology

Other topologies as described in the :doc:`Trellis Documentation
<trellis:supported-topology>` can possibly be used, but are not actively being
tested at this time.

Additionally, the P4-based topologies can support running both the BESS UPF and
P4 UPF on the same hardware at the same time if desired (for testing, or
simultaneous 4G/5G support).

Hardware Descriptions
---------------------

Fabric Switch
"""""""""""""

To use the P4 UPF, you must use fabric switches based on the `Intel (previously
Barefoot) Tofino chipset
<https://www.intel.com/content/www/us/en/products/network-io/programmable-ethernet-switch/tofino-series.html>`_.
There are two variants of this switching chipset, with different resources and
capabilities.

Aether currently supports these P4 switch models:

* `EdgeCore Wedge100BF-32X
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=335>`_,
  a Dual Pipe Tofino ASIC

* `EdgeCore Wedge100BF-32QS
  <https://www.edge-core.com/productsInfo.php?cls=1&cls2=180&cls3=181&id=770>`_,
  a Quad Pipe Tofino ASIC, which has more chip resources and a faster embedded
  system with more memory and storage.

The P4 UPF and SD-Fabric features run within the constraints of the Dual Pipe
system for production deployments, but for development of features in P4, the
larger capacity of the Quad Pipe is desirable.

These switches feature 32 QSFP+ ports capable of running in 100GbE, 40GbE, or
4x 10GbE mode (using a split DAC or fiber cable) and have a 1GbE management
network interface.

See also the :ref:`Rackmount of Equipment
<edge_deployment/site_planning:rackmount of equipment>` for how the Fabric
switches should be rackmounted to ensure proper airflow within a rack.

Compute Server
""""""""""""""

These servers run Kubernetes, Aether connectivity apps, and edge applications.

Minimum hardware specifications:

* AMD64 (aka x86-64) architecture

* 8 CPU Cores (minimum), 16+ recommended

* 32GB of RAM (minimum), 128GB+ recommended

* 250 GB of storage (SSD preferred), 1TB+ recommended

* 2x 40GbE or 100GbE Ethernet network card to P4 switches, with DPDK support

* 1x 1GbE management network port, with PXE boot support.  2x required for BESS
  UPF.

Optional but highly recommended:

* Lights out management support, with either a shared or separate NIC and
  support for HTML5 console access.

Management Server
"""""""""""""""""

One management server is required, which must have at least two 1GbE network
ports, and runs a variety of network services to bootstrap and support the
edge.

In current Aether deployments, the Management Server also functions as a router
and VPN gateway back to Aether Central.

Minimum hardware specifications:

* AMD64 (aka x86-64) architecture

* 4 CPU cores, or more

* 8GB of RAM, or more

* 120GB of storage (SSD preferred), or more

* 2x 1GbE Network interfaces (one for WAN, one to the management switch) with
  PXE boot support.

Optional:

* 10GbE or 40GbE network card with DPDK support to connect to fabric switch

* Lights out management support, with either a shared or separate NIC and
  support for HTML5 console access.

Management Switch
"""""""""""""""""

A managed L2/L3 management switch is required to provide connectivity within
the cluster for bootstrapping equipment.  It is configured with multiple VLANs
to separate the management plane, fabric, and the out-of-band and lights out
management connections on the equipment.

Minimum requirements:

* 8x 1GbE Copper Ethernet ports (adjust to provide a sufficient number for
  every copper 1GbE port in the system)

* 2x 10GbE SFP+ or 40GbE QSFP interfaces (only required if management server
  does not have a network card with these ports)

* Managed via SSH or web interface

* LLDP protocol support, for debugging cabling issues

* Capable supporting VLANs on each port, with both tagged and untagged traffic
  sharing a port.


Optional:

* PoE+ support, which can power eNB and monitoring hardware, if using
  Management switch to host these devices.

eNB Radio
"""""""""

The LTE eNB used in most deployments is the `Sercomm P27-SCE4255W Indoor CBRS
Small Cell
<https://www.sercomm.com/contpage.aspx?langid=1&type=prod3&L1id=2&L2id=1&L3id=107&Prodid=751>`_.

While this unit ships with a separate power brick, it also supports PoE+ power
on the WAN port, which provides deployment location flexibility. Either a PoE+
capable switch or PoE+ power injector should be purchased.

If connecting directly to the fabric switch through a QSFP to 4x SFP+ split
cable, a 10GbE SFP+ to 1GbE Copper media converter should be purchased. The `FS
UMC-1S1T <https://www.fs.com/products/101476.html>`_ has been used for this
purpose successfully.

Alternatively, the Fabric's 10GbE SFP+ could be connected to another switch
(possibly the Management Switch) which would adapt the speed difference, and
provide PoE+ power, and power control for remote manageability.


Testing Hardware
----------------

The following hardware is used to test the network and determine uptime of
edges.  It is currently required, to properly validate that an edge site is
functioning properly.

Monitoring Raspberry Pi and CBRS dongle
"""""""""""""""""""""""""""""""""""""""

One pair of Raspberry Pi and CBRS band supported LTE dongle is required to
monitor the connectivity service at the edge.

The Raspberry Pi model used in Aether is a `Raspberry Pi 4 Model B/2GB
<https://www.pishop.us/product/raspberry-pi-4-model-b-2gb/>`_

Which is configured with:

* Raspberry Pi case (HiPi is recommended for PoE Hat)

* A power source, either one of:

  * PoE Hat used with a PoE switch (recommended, allows remote power control)

  * USB-C Power Supply

* MicroSD Card with Raspbian - 16GB

One LTE dongle model supported in Aether is the `Sercomm Adventure Wingle
<https://www.sercomm.com/contpage.aspx?langid=1&type=prod3&L1id=2&L2id=2&L3id=110&Prodid=767>`_.


Example BoMs
------------

To help provision a site, a few example Bill of Materials (BoM) are given
below, which reference the hardware descriptions given above.

Some quantities are dependent on other quantities - for example, the number of
DAC cables frequently depends on the number of servers in use.

These BOMs do not include UE devices.  It's recommended that the testing
hardware given above be added to every BoM for monitoring purposes.


BESS UPF Testing BOM
""""""""""""""""""""

The following is the minimum BoM required to run Aether with the BESS UPF.

============ ===================== ===============================================
Quantity     Type                  Purpose
============ ===================== ===============================================
1            Management Switch     Must be Layer 2/3 capable for BESS VLANs
1            Management Server
1-3          Compute Servers       Recommended at least 3 for Kubernetes HA
1 (or more)  eNB
1x #eNB      PoE+ Injector         Required unless using a PoE+ Switch
Sufficient   Cat6 Network Cabling  Between all equipment
============ ===================== ===============================================

P4 UPF Testing BOM
""""""""""""""""""

============ ===================== ===============================================
Quantity     Type                  Description/Use
============ ===================== ===============================================
1            P4 Fabric Switch
1            Management Switch     Must be Layer 2/3 capable
1            Management Server     At least 1x 40GbE QSFP ports recommended
1-3          Compute Servers       Recommended at least 3 for Kubernetes HA
2x #Server   40GbE QSFP DAC cable  Between Compute, Management, and Fabric Switch
1            QSFP to 4x SFP+ DAC   Split cable between Fabric and eNB
1 (or more)  eNB
1x #eNB      10GbE to 1GbE Media   Required unless using switch to convert from
             converter             fabric to eNB
1x #eNB      PoE+ Injector         Required unless using a PoE+ Switch
Sufficient   Cat6 Network Cabling  Between all equipment
============ ===================== ===============================================

P4 UPF Paired Leaves BOM
""""""""""""""""""""""""

============ ===================== ===============================================
Quantity     Type                  Description/Use
============ ===================== ===============================================
2            P4 Fabric Switch
1            Management Switch     Must be Layer 2/3 capable
1            Management Server     2x 40GbE QSFP ports recommended
3            Compute Servers
2            100GbE QSFP DAC cable Between Fabric switches
2x #Server   40GbE QSFP DAC cable  Between Compute, Management, and Fabric Switch
1 (or more)  QSFP to 4x SFP+ DAC   Split cable between Fabric and eNB
1 (or more)  eNB
1x #eNB      10GbE to 1GbE Media   Required unless using switch to convert from
             converter             fabric to eNB
1x #eNB      PoE+ Injector         Required unless using a PoE+ Switch
Sufficient   Cat6 Network Cabling  Between all equipment
============ ===================== ===============================================


P4 UPF 2x2 Leaf Spine Fabric BOM
""""""""""""""""""""""""""""""""

============ ===================== ===============================================
Quantity     Type                  Description/Use
============ ===================== ===============================================
4            P4 Fabric Switch
1            Management Switch     Must be Layer 2/3 capable
1            Management Server     2x 40GbE QSFP ports recommended
3            Compute Servers
8            100GbE QSFP DAC cable Between Fabric switches
2x #Server   40GbE QSFP DAC cable  Between Compute, Management, and Fabric Switch
1 (or more)  QSFP to 4x SFP+ DAC   Split cable between Fabric and eNB
1 (or more)  eNB
1x #eNB      10GbE to 1GbE Media   Required unless using switch to convert from
             converter             fabric to eNB
1x #eNB      PoE+ Injector         Required unless using a PoE+ Switch
Sufficient   Cat6 Network Cabling  Between all equipment
============ ===================== ===============================================

