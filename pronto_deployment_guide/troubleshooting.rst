..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Troubleshooting
===============

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
   read.

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
