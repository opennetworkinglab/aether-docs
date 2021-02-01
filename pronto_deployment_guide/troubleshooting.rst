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
management server) and you're trying to interactively login to it, make sure
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
prevents DNS lookups from working within the pod.

To resolve this, forwarding addresses on the local network can be provided in
the Ansible YAML ``host_vars`` file, using the ``unbound_forward_zones`` list
to configure the Unbound recursive nameserver. An example::

  unbound_forward_zones:
  - name: "."
    servers:
      - "8.8.8.8"
      - "8.8.4.4"


The items in the ``servers`` list would be the locally accessible nameservers.

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
