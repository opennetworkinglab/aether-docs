..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Site Planning
=============

Site Design in Netbox
---------------------

The Aether project uses Netbox as source of truth, and the automation script uses
it's API to create input files for Ansible Playbooks which are used to configure
each site.

Once the hardware has been ordered, the installation can be planned.  The
following information needs to be added to `NetBox
<https://netbox.readthedocs.io/en/stable>`_ to describe each edge site:

.. note::
   The **bold** words represent the models in Netbox.

1. Add a **Site** for the edge (if one doesn't already exist), which has the
   physical location and contact information for the Aether Edge.

2. Add equipment Racks to the Site (if they don't already exist).

3. Add a **Tenant** for the edge (who owns/manages it), assigned to the ``Pronto``
   or ``Aether`` Tenant Group.

4. Add a **VRF** (Routing Table) for the edge site. This is usually just the name
   of the site.  Make sure that ``Enforce unique space`` is checked, so that IP
   addresses within the VRF are forced to be unique, and that the Tenant Group
   and Tenant are set.

5. Add a **VLAN Group** to the edge site, which groups the site's VLANs and
   requires that they have a unique VLAN number.

6. Add **VLANs** for the edge site.  These VLAN objects should be assigned a VLAN
   Group, a Site, and a Tenant.

   There can be multiple of the same VLAN in NetBox (VLANs are layer 2, and
   local to the site), but not within the VLAN group.

   The minimal list of VLANs:

     * ADMIN 1
     * UPLINK 10
     * MGMT 800
     * FAB 801

   If you have multiple deployments at a site using the same management server,
   add additional VLANs incremented by 10 for the MGMT/FAB - for example, you
   can create the VLANs for development server as follows:

     * DEVMGMT 810
     * DEVFAB 801

7. Add IP **Prefixes** for the site. This should have the Tenant and VRF assigned.

   All IP prefixes of Aether Edge will fit into a ``/22`` sized block.

   The Prefix description field is used to create DNS names for IP addresses in the Prefix.
   The DNS A records for each IP address start with the name of the Device, and end with
   the Prefix description.

   For example, if we have a management server named ``mgmtserver`` in **Prefix**
   ``prod1.menlo.aetherproject.net``, and the management server's DNS name will be
   ``mgmtserver.prod1.menlo.aetherproject.net``.

   Here is an example using the ``10.0.0.0/22`` block. Let's name our deployment
   as "prod1", and name our site as "menlo". Then we define 4 **Prefixes**
   with different purposes.

.. note::
   NOTE: You should replace the **prod1** and **menlo** to your deployment name and
   site name.
..

     * ADMIN Prefix - ``10.0.0.0/25`` (for Lights-out management)

        * Has the Server BMC/LOM and Management Switch
        * Assign with the ADMIN 1 VLAN
        * Set the description to ``admin.prod1.menlo.aetherproject.net`` (or
          ``prontoproject.net``).

     * MGMT Prefix -  ``10.0.0.128/25`` (for infrastructure control plane)

        * Has the Server Management plane, Fabric Switch Management/BMC
        * Assign with MGMT 800 VLAN
        * Set the description to ``prod1.menlo.aetherproject.net`` (or
          ``prontoproject.net``).

     * FABRIC1 Prefix - ``10.0.1.0/25``

        * Compute Nodes' qsfp0 port which connects to Fabric switches,
          and other devices (eNB, ...) connect to the Fabric switches.
        * Assign with FAB 801 VLAN
        * Set the description to ``fab1.prod1.menlo.aetherproject.net`` (or
          ``prontoproject.net``).

     * FABRIC2 Prefix - ``10.0.1.128/25``

        * Compute Nodes' qsfp1 port which connects to Fabric switches
        * Assign FAB 801 VLAN
        * Set the description to ``fab2.prod1.menlo.aetherproject.net`` (or
          ``prontoproject.net``).

   And we will have an additional parent prefix includes 2 FABRIC Prefix.

     * ``10.0.1.0/24``

        * This is used to configure the correct routes, DNS, and TFTP servers
          provided by DHCP to the equipment that is connected to the fabric
          leaf switch that the management server (which provides those
          services) is not connected to.

   Additionally, these edge prefixes are used for Kubernetes but don't need to
   be created in NetBox:

     * ``10.0.2.0/24``

        * Kubernetes Pod IP's

     * ``10.0.3.0/24``

        * Kubernetes Cluster IP's

8. Add **Devices** to the site, for each piece of equipment. These are named with a
   scheme similar to the DNS names used for the pod, given in this format::

     <devname>.<deployment>.<site>

   Examples::

     mgmtserver1.ops1.tucson
     node1.stage1.menlo

   Note that these names are transformed into DNS names using the Prefixes, and
   may have additional components - ``admin`` or ``fabric`` may be added after
   the ``<devname>`` for devices on those networks.

   Set the following fields when creating a device:

     * Site
     * Tenant
     * Rack & Rack Position
     * Serial number

   If a specific Device Type doesn't exist for the device, it must be created,
   which is detailed in the NetBox documentation, or ask the OPs team for help.

   See `Rackmount of Equipment`_ below for guidance on how equipment should be
   mounted in the Rack.

9. Add **Service** to the management server:

    * name: ``dns``
      protocol: UDP
      port: 53

    * name: ``tftp``
      protocol: UDP
      port: 69

   These are used by the DHCP and DNS config to know which servers offer
   DNS or TFTP service.

10. Set the MAC address for the physical interfaces on the device.

   You may also need to add physical network interfaces if they aren't already
   created by the Device Type.  An example would be if additional add-in
   network cards were installed.

11. Add any virtual interfaces to the **Devices**. When creating a virtual
    interface, it should have it's ``label`` field set to the name of the
    physical interface that it is assigned

    These are needed for two cases of the Pronto deployment:

     1. On the Management Server, there should bet (at least) two VLAN
        interfaces created attached to the ``eno2`` network port, which
        are used to provide connectivity to the management plane and fabric.
        These interfaces should be named ``<name of vlan><vlan ID>``, so the
        MGMT 800 VLAN would become a virtual interface named ``mgmt800``, with
        the label ``eno2``.

     2. On the Fabric switches, the ``eth0`` port is shared between the OpenBMC
        interface and the ONIE/ONL installation.  Add a ``bmc`` virtual
        interface with a label of ``eth0`` on each fabric switch, and have the
        ``OOB Management`` checkbox checked.

12. Create **IP addresses** for the physical and virtual interfaces.  These should
    have the Tenant and VRF set.

    The Management Server should always have the first IP address in each
    range, and they should be incremental, in this order. Examples are given as
    if there was a single instance of each device - adding additional devices
    would increment the later IP addresses.

      * Management Server

          * ``eno1`` - site provided public IP address, or blank if DHCP
            provided

          * ``eno2`` - 10.0.0.1/25 (first of ADMIN) - set as primary IP
          * ``bmc`` - 10.0.0.2/25 (next of ADMIN)
          * ``mgmt800`` - 10.0.0.129/25 (first of MGMT)
          * ``fab801`` - 10.0.1.1/25 (first of FAB)

      * Management Switch

          * ``gbe1`` - 10.0.0.3/25 (next of ADMIN) - set as primary IP

      * Fabric Switch

          * ``eth0`` - 10.0.0.130/25 (next of MGMT), set as primary IP
          * ``bmc`` - 10.0.0.131/25

      * Compute Server

          * ``eth0`` - 10.0.0.132/25 (next of MGMT), set as primary IP
          * ``bmc`` - 10.0.0.4/25 (next of ADMIN)
          * ``qsfp0`` - 10.0.1.2/25 (next of FAB)
          * ``qsfp1`` - 10.0.1.3/25

      * Other Fabric devices (eNB, etc.)

          * ``eth0`` or other primary interface - 10.0.1.4/25 (next of FAB)

13. Add **IP address** to the **Prefix** to represent reserved DHCP ranges.
    We use a single IP address which ``Status`` is set to ``DHCP``  to stand
    for the DHCP range, the DHCP server will consume the entire range of IP
    address in the CIDR mask (includes first and last IP addresses).

    For example, IP ``10.0.0.32/27`` with ``DHCP`` status in Prefix
    ``10.0.0.0/25``, the IP will be a DHCP block, and allocate IP address from
    ``10.0.0.32`` to ``10.0.0.63``.

14. Add **IP address** to the **Prefix** to represent route IP reservations for
    both Fabric prefixes.  These are IP addresses used by ONOS to route traffic
    to the other leaf, and have the following attributes:

    - Have the last usable address in range (in the ``/25`` fabric examples
      above, these would be ``10.0.1.126/25`` and ``10.0.1.254/25``)

    - Have a ``Status`` of ``Reserved``, and the VRF, Tenant Group, and Tenant
      set.

    - The Description must start with the word ``router``, such as: ``router
      for leaf1 Fabric``

    - A custom field named ``RFC3442 Routes`` is set to the CIDR IP address of
      the opposite leaf - if the leaf's prefix is ``10.0.1.0/25`` and the
      router IP is ``10.0.1.126/25`` then ``RFC3442 Routes`` should be set to
      ``10.0.1.128\25`` (and the reverse - on ``10.0.1.254/25`` the ``RFC3442
      Routes`` would be set to be ``10.0.1.0/25``).  This creates an `RFC3442
      Classless Static Route Option <https://tools.ietf.org/html/rfc3442>`_
      for the subnet in DHCP.

15. Add Cables between physical interfaces on the devices

    The topology needs to match the logical diagram presented in the
    :ref:`network_cable_plan`.  Note that many of the management interfaces
    need to be located either on the MGMT or ADMIN VLANs, and the management
    switch is
    used to provide that separation.

Rackmount of Equipment
----------------------

Most of the Pronto equipment has a 19" rackmount form factor.

Guidelines for mounting this equipment:

- The EdgeCore Wedge Switches have a front-to-back (aka "port-to-power") fan
  configuration, so hot air exhaust is out the back of the switch near the
  power inlets, away from the 32 QSFP network ports on the front of the switch.

- The full-depth 1U and 2U Supermicro servers also have front-to-back airflow
  but have most of their ports on the rear of the device.

- Airflow through the rack should be in one direction to avoid heat being
  pulled from one device into another.  This means that to connect the QSFP
  network ports from the servers to the switches, cabling should be routed
  through the rack from front (switch) to back (server).  Empty rack spaces
  should be reserved for this purpose.

- The short-depth management HP Switch and 1U Supermicro servers should be
  mounted on the rear of the rack.  They both don't generate an appreciable
  amount of heat, so the airflow direction isn't a significant factor in
  racking them.

Inventory
---------

Once equipment arrives, any device needs to be recorded in inventory if it:

1. Connects to the network (has a MAC address)
2. Has a serial number
3. Isn't a subcomponent (disk, add-in card, linecard, etc.) of a larger device.

The following information should be recorded for every device:

- Manufacturer
- Model
- Serial Number
- MAC address (for the primary and any management/BMC/IPMI interfaces)

This information should be be added to the corresponding Devices within the ONF
NetBox instance.  The accuracy of this information is very important as it is
used in bootstrapping the compute systems, which is currently done by Serial
Number, as reported to iPXE by SMBIOS.

Once inventory has been completed, let the Infra team know, and the pxeboot
configuration will be generated to have the OS preseed files corresponding to the
new servers based on their serial numbers.
