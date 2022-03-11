..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Troubleshooting
===============


Firewalls and other host network issues
---------------------------------------

Unable to access a system
"""""""""""""""""""""""""

If it's a system behind another system (ex: the compute nodes behind a
management router) and you're trying to interactively login to it, make sure
that you've enabled SSH Agent Forwarding in your ``~/.ssh/config`` file::

  Host mgmtserver1.prod.site.aetherproject.net
    ForwardAgent yes

If you still have problems after verifying that this is set up, run ssh with
the ``-v`` option, which will print out all the connection details and
whether an agent is used on the second ssh::

  onfadmin@mgmtserver1:~$ ssh onfadmin@node2.mgmt.prod.site.aetherproject.net
  debug1: client_input_channel_open: ctype auth-agent@openssh.com rchan 2 win 65536 max 16384
  debug1: channel 1: new [authentication agent connection]
  debug1: confirm auth-agent@openssh.com
  Welcome to Ubuntu 18.04.5 LTS (GNU/Linux 5.4.0-56-generic x86_64)
  ...
  onfadmin@node2:~$

Root/Public DNS port is blocked
"""""""""""""""""""""""""""""""

In some cases access to the public DNS root and other servers is blocked, which
prevents DNS queries from working within the pod.

To resolve this, forwarding addresses on the local network can be provided in
the Ansible YAML ``host_vars`` file, using the ``unbound_forward_zones`` list
to configure the Unbound recursive nameserver. An example::

  unbound_forward_zones:
  - name: "."
    servers:
      - "8.8.8.8"
      - "8.8.4.4"


The items in the ``servers`` list should be locally accessible nameservers.

Problems with OS installation
-----------------------------

iPXE doesn't load a Menu when started
"""""""""""""""""""""""""""""""""""""

The URLs that iPXE provides if there is an error take you into it's
documentation, which is of high quality and should explain the error in much
greater detail - for example `https://ipxe.org/3e11623b
<https://ipxe.org/3e11623b>`_ explains that the DNS server address provided by
DHCP is not functional.

The most common failures would be in network settings being incorrect, which
should be shown when the menu loads in step 4. If the menu does not load, and
you get an `iPXE>` Shell prompt, type::

   config

And you should get the iPXE configuration screen, which lists all of the
configuration parameters discovered:

   .. image:: images/mgmtsrv-007.png
       :alt: iPXE config menu
       :scale: 50%

Most likely there's something wrong with the network configuration provided by
DHCP - you can scroll this menu with arrow keys to find all the settings
provided by the DHCP server, and SMBIOS information provided by the hardware.

OS installs, but doesn't boot
"""""""""""""""""""""""""""""

If you've completed the installation but the system won't start the OS, check
these BIOS settings:

- If the startup disk is nVME, under ``Advanced -> PCIe/PCI/PnP Configuration``
  the option ``NVMe Firmware Source`` should be set to ``AMI Native Support``,
  per `Supermicro FAQ entry 28248
  <https://www.supermicro.com/support/faqs/faq.cfm?faq=28248>`_.

Unknown MAC addresses
---------------------

Sometimes it's hard to find out all the MAC addresses assigned to network
cards. These can be found in a variety of ways:

1. On servers, the BMC webpage will list the built-in network card MAC
   addresses.

2. If you login to a server, ``ip link`` or ``ip addr`` will show the MAC
   address of each interface, including on add-in cards.

3. If you can login to a server but don't know the BMC IP or MAC address for
   that server, you can find it with ``sudo ipmitool lan print``.

4. If you don't have a login to the server, but can get to the management
   server, ``ip neighbor`` will show the arp table of MAC addresses known to
   that system.  It's output is unsorted  - ``ip neigh | sort`` is easier to
   read.  This can be useful for determining if there's a cabling problem -
   a device plugged into the wrong port of the management switch could show up
   in the DHCP pool range for a different segment.

Cabling issues
--------------

The system may not come up correctly if cabling isn't connected properly.
If you don't have hands-on with the cabling, here are some ways to check on the
cabling remotely:

1. On servers you can check which ports are connected with ``ip link show``::

    $ ip link show
    ...
    3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
        link/ether 3c:ec:ef:4d:55:a8 brd ff:ff:ff:ff:ff:ff
    ...
    5: eno2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
        link/ether 3c:ec:ef:4d:55:a9 brd ff:ff:ff:ff:ff:ff

  Ports that are up will show ``state UP``

2. You can determine which remote ports are connected with LLDP, assuming that
   the remote switch supports LLDP and has it enabled. This can be done with
   ``networkctl lldp``, which shows both the name and the MAC address of the
   connected switch on a per-link basis::

      $ networkctl lldp
      LINK             CHASSIS ID        SYSTEM NAME      CAPS        PORT ID           PORT DESCRIPTION
      eno1             10:4f:58:e7:d5:60 Aruba-2540-24…PP ..b........ 10                10
      eno2             10:4f:58:e7:d5:60 Aruba-2540-24…PP ..b........ 1                 1


Problems with SD-Fabric
-----------------------
Refer to :ref:`SD-Fabric Troubleshooting Guide <sdfabric:troubleshooting:Troubleshooting Guide>`
for SD-Fabric related issues.

Management Network Issues
-------------------------

Cycling PoE port power on a HP/Aruba Management switch
""""""""""""""""""""""""""""""""""""""""""""""""""""""

You may need to cycle the power on a port if an eNB or monitoring device that
is powered the PoE switch is not responding or misbehaving.

To do this, login to the switch and check which ports are receiving power::

  Aruba-2540-24G-PoEP-4SFPP# show power-over-ethernet brief

  Status and Configuration Information

   Available: 370 W  Used: 11 W  Remaining: 359 W

  PoE    Pwr  Pwr      Pre-std Alloc Alloc  PSE Pwr PD Pwr  PoE Port     PLC PLC
  Port   Enab Priority Detect  Cfg   Actual Rsrvd   Draw    Status       Cls Type
  ------ ---- -------- ------- ----- ------ ------- ------- ------------ --- ----
  1      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  2      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  3      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  4      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  5      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  6      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  7      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  8      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  9      Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  10     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  11     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  12     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  13     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  14     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  15     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  16     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  17     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  18     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  19     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  20     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  21     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -
  22     Yes  low      off     usage usage  4.9 W   4.7 W   Delivering    3   1
  23     Yes  low      off     usage usage  6.0 W   5.7 W   Delivering    3   1
  24     Yes  low      off     usage usage  0.0 W   0.0 W   Searching     0   -

For this example, if we want to reset port 23, run these commands to disable
the PoE power on the port::

  Aruba-2540-24G-PoEP-4SFPP# config
  Aruba-2540-24G-PoEP-4SFPP(config)# interface 23
  Aruba-2540-24G-PoEP-4SFPP(eth-23)# no power-over-ethernet
  Aruba-2540-24G-PoEP-4SFPP(eth-23)# show power-over-ethernet ethernet 23

   Status and Configuration Information for port 23

    Power Enable      : No                    PoE Port Status    : Disabled
    PLC Class/Type    : 0/-                   Priority Config    : low
    DLC Class/Type    : 0/-                   Pre-std Detect     : off
    Alloc By Config   : usage                 Configured Type    :
    Alloc By Actual   : usage                 PoE Value Config   : n/a


    PoE Counter Information

    Over Current Cnt  : 0                     MPS Absent Cnt     : 0
    Power Denied Cnt  : 0                     Short Cnt          : 0


    LLDP Information

    PSE Allocated Power Value : 0.0 W         PSE TLV Configured : dot3, MED
    PD Requested Power Value  : 0.0 W         PSE TLV Sent Type  : dot3
    MED LLDP Detect           : Disabled      PD TLV Sent Type   : n/a


    Power Information

    PSE Voltage       : 0.0 V                 PSE Reserved Power : 0.0 W
    PD Amperage Draw  : 0 mA                  PD Power Draw      : 0.0 W


At this point, the power has been removed from the device. To reenable it::

  Aruba-2540-24G-PoEP-4SFPP(eth-23)# power-over-ethernet
  Aruba-2540-24G-PoEP-4SFPP(eth-23)# show power-over-ethernet ethernet 23

   Status and Configuration Information for port 23

    Power Enable      : Yes                   PoE Port Status    : Delivering
    PLC Class/Type    : 3/1                   Priority Config    : low
    DLC Class/Type    : 0/-                   Pre-std Detect     : off
    Alloc By Config   : usage                 Configured Type    :
    Alloc By Actual   : usage                 PoE Value Config   : n/a


    PoE Counter Information

    Over Current Cnt  : 0                     MPS Absent Cnt     : 0
    Power Denied Cnt  : 0                     Short Cnt          : 0


    LLDP Information

    PSE Allocated Power Value : 0.0 W         PSE TLV Configured : dot3, MED
    PD Requested Power Value  : 0.0 W         PSE TLV Sent Type  : dot3
    MED LLDP Detect           : Disabled      PD TLV Sent Type   : n/a


    Power Information

    PSE Voltage       : 0.0 V                 PSE Reserved Power : 0.1 W
    PD Amperage Draw  : 18 mA                 PD Power Draw      : 0.0 W



   Refer to command's help option for field definitions

  Aruba-2540-24G-PoEP-4SFPP(eth-23)# exit
  Aruba-2540-24G-PoEP-4SFPP(config)# exit

