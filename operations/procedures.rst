..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

General Procedures
==================

Edge shutdown procedure
-----------------------

To gracefully shutdown an Aether Edge Pod, follow the following steps:

1. Shutdown the fabric switches using ``shutdown -h now``

2. Shutdown the compute servers using ``shutdown -h now``

3. Shutdown the management server using ``shutdown -h now``

4. The management switch and eNB aren't capable of a graceful shutdown, so no
   steps need to be taken for that hardware.

5. Remove power from the pod.

.. note::

   The shutdown steps can be automated with an :doc:`ad-hoc ansible command
   <ansible:user_guide/intro_adhoc>` and you have an ansible inventory of all
   the systems::

      ansible -i inventory/sitename.ini -b -m shutdown -a "delay=60" all

   The ``delay=60`` argument is to allow hosts behind the management server to
   be reached before the management server shuts down.

Edge power up procedure
-----------------------

1. Restore power to the pod equipment.  The fabric and management switches will
   power on automatically.

2. Turn on the management server using the front panel power button

3. Turn on the compute servers using the front panel power buttons
