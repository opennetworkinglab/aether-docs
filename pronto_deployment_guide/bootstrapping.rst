..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

=============
Bootstrapping
=============

OS Installation - Switches
==========================

.. note::

   This part will be done automatically once we have a DHCP and HTTP server set up in the infrastructure.
   For now, we need to download and install the ONL image manually.

Install ONL with Docker
-----------------------
First, enter **ONIE rescue mode**.

Set up IP and route
^^^^^^^^^^^^^^^^^^^
.. code-block:: console

   # ip addr add 10.92.1.81/24 dev eth0
   # ip route add default via 10.92.1.1

- `10.92.1.81/24` should be replaced by the actual IP and subnet of the ONL.
- `10.92.1.1` should be replaced by the actual default gateway.

Download and install ONL
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

   # wget https://github.com/opennetworkinglab/OpenNetworkLinux/releases/download/v1.3.2/ONL-onf-ONLPv2_ONL-OS_2020-10-09.1741-f7428f2_AMD64_INSTALLED_INSTALLER
   # sh ONL-onf-ONLPv2_ONL-OS_2020-10-09.1741-f7428f2_AMD64_INSTALLED_INSTALLER

The switch will reboot automatically once the installer is done.

.. note::

   Alternatively, we can `scp` the ONL installer into ONIE manually.

Setup BMC for remote console access
-----------------------------------
Log in to the BMC from ONL by

.. code-block:: console

   # ssh root@192.168.0.1 # pass: 0penBmc

on `usb0` interface.

Once you are in the BMC, run the following commands to setup IP and route (or offer a fixed IP with DHCP)

.. code-block:: console

   # ip addr add 10.92.1.85/24 dev eth0
   # ip route add default via 10.92.1.1

- `10.92.1.85/24` should be replaced by the actual IP and subnet of the BMC.
  Note that it should be different from the ONL IP.
- `10.92.1.1` should be replaced by the actual default gateway.

BMC uses the same ethernet port as ONL management so you should give it an IP address in the same subnet.
BMC address will preserve during ONL reboot, but won’t be preserved during power outage.

To log in to ONL console from BMC, run

.. code-block:: console

   # /usr/local/bin/sol.sh

If `sol.sh` is unresponsive, please try to restart the mainboard with

.. code-block:: console

   # wedge_power.sh restart

Setup network and host name for ONL
-----------------------------------

.. code-block:: console

   # hostnamectl set-hostname <host-name>

   # vim.tiny /etc/hosts # update accordingly
   # cat /etc/hosts # example
   127.0.0.1 localhost
   10.92.1.81 menlo-staging-spine-1

   # vim.tiny /etc/network/interfaces.d/ma1 # update accordingly
   # cat /etc/network/interfaces.d/ma1 # example
   auto ma1
   iface ma1 inet static
   address 10.92.1.81
   netmask 255.255.255.0
   gateway 10.92.1.1
   dns-nameservers 8.8.8.8
