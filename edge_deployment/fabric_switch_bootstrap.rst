..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Fabric Switch Bootstrap
=======================

The installation of the ONL OS image on the fabric switches uses the DHCP and
HTTP server set up on the management server.

The default image is downloaded during that installation process by the
``onieboot`` role. Make changes to that roll and rerun the management playbook
to download a newer switch image.

Preparation
-----------

The switches have a single ethernet port that is shared between OpenBMC and
ONL. Find out the MAC addresses for both of these ports and enter it into
NetBox.

Change boot mode to ONIE Rescue mode
------------------------------------

In order to reinstall an ONL image, you must change the ONIE bootloader to
"Rescue Mode".

Once the switch is powered on, it should retrieve an IP address on the OpenBMC
interface with DHCP. OpenBMC uses these default credentials::

  username: root
  password: 0penBmc

Login to OpenBMC with SSH::

  $ ssh root@10.0.0.131
  The authenticity of host '10.0.0.131 (10.0.0.131)' can't be established.
  ECDSA key fingerprint is SHA256:...
  Are you sure you want to continue connecting (yes/no)? yes
  Warning: Permanently added '10.0.0.131' (ECDSA) to the list of known hosts.
  root@10.0.0.131's password:
  root@bmc:~#

Using the Serial-over-LAN Console, enter ONL::

  root@bmc:~# /usr/local/bin/sol.sh
  You are in SOL session.
  Use ctrl-x to quit.
  -----------------------

  root@onl:~#

.. note::
  If `sol.sh` is unresponsive, please try to restart the mainboard with::

    root@onl:~# wedge_power.sh reset


Change the boot mode to rescue mode with the command ``onl-onie-boot-mode
rescue``, and reboot::

  root@onl:~# onl-onie-boot-mode rescue
  [1053033.768512] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
  [1053033.936893] EXT4-fs (sda3): re-mounted. Opts: (null)
  [1053033.996727] EXT4-fs (sda3): re-mounted. Opts: (null)
  The system will boot into ONIE rescue mode at the next restart.
  root@onl:~# reboot

At this point, ONL will go through it's shutdown sequence and ONIE will start.
If it does not start right away, press the Enter/Return key a few times - it
may show you a boot selection screen. Pick ``ONIE`` and ``Rescue`` if given a
choice.

Installing an ONL image over HTTP
---------------------------------

Now that the switch is in Rescue mode

First, activate the Console by pressing Enter::

  discover: Rescue mode detected.  Installer disabled.

  Please press Enter to activate this console.
  To check the install status inspect /var/log/onie.log.
  Try this:  tail -f /var/log/onie.log

  ** Rescue Mode Enabled **
  ONIE:/ #

Then run the ``onie-nos-install`` command, with the URL of the management
server on the management network segment::

  ONIE:/ # onie-nos-install http://10.0.0.129/onie-installer
  discover: Rescue mode detected. No discover stopped.
  ONIE: Unable to find 'Serial Number' TLV in EEPROM data.
  Info: Fetching http://10.0.0.129/onie-installer ...
  Connecting to 10.0.0.129 (10.0.0.129:80)
  installer            100% |*******************************|   322M  0:00:00 ETA
  ONIE: Executing installer: http://10.0.0.129/onie-installer
  installer: computing checksum of original archive
  installer: checksum is OK
  ...

The installation will now start, and then ONL will boot culminating in::

  Open Network Linux OS ONL-wedge100bf-32qs, 2020-11-04.19:44-64100e9

  localhost login:

The default ONL login is::

  username: root
  password: onl

If you login, you can verify that the switch is getting it's IP address via
DHCP::

  root@localhost:~# ip addr
  ...
  3: ma1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
      link/ether 00:90:fb:5c:e1:97 brd ff:ff:ff:ff:ff:ff
      inet 10.0.0.130/25 brd 10.0.0.255 scope global ma1
  ...


Post-ONL Configuration
----------------------

A ``terraform`` user must be created on the switches to allow them to be
configured.

This is done using Ansible.  Verify that your inventory (Created earlier from the
``inventory/example-aether.ini`` file) includes an ``[aetherfabric]`` section
that has all the names and IP addresses of the compute nodes in it.

Then run a ping test::

  ansible -i inventory/sitename.ini -m ping aetherfabric

This may fail with the error::

  "msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."

Comment out the ``ansible_ssh_pass="onl"`` line, then rerun the ping test.  It
may ask you about authorized keys - answer ``yes`` for each host to trust the
keys::

  The authenticity of host '10.0.0.138 (<no hostip for proxy command>)' can't be established.
  ECDSA key fingerprint is SHA256:...
  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes

Once you've trusted the host keys, the ping test should succeed::

  spine1.role1.site | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }
  leaf1.role1.site | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }
  ...

Then run the playbook to create the ``terraform`` user::

  ansible-playbook -i inventory/sitename.ini playbooks/aetherfabric-playbook.yml

Once completed, the switch should now be ready for TOST runtime install.
