..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Fabric Switch Bootstrap
=======================

The installation of the ONL OS image on the fabric switches uses the DHCP and
HTTP server set up on the management router.

The default image is downloaded during that installation process by the
``onieboot`` role. Make changes to that role and rerun the management playbook
to download a newer switch image.

Preparation
-----------

The switches have a single ethernet port that is shared between OpenBMC and
ONL. Find out the MAC addresses for both of these ports and enter it into
NetBox.

Installing Open Network Linux
-----------------------------
See :ref:`Provision Switches <sdfabric:deployment:step 1: provision switches>`
to learn about how to enter ONIE Rescue mode and install Open Network Linux on the switches.

Please return here and continue the rest of the step once you finish ONL installation.

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

Once completed, the switch should now be ready for SD-Fabric runtime install.
