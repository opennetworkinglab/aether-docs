..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Management Network Bootstrap
============================

The current Pronto deployment uses an HP/Aruba 2540 24G PoE+ 4SFP+ JL356A
switch to run the management network and other VLAN's that are used internally.

By default the switch will pull an IP address via DHCP and ``http://<switch IP>``
will display a management webpage for the switch. You need to be able to access
this webpage before you can update the configuration.

Loading the Management Switch Configuration
-------------------------------------------

1. Obtain a copy of the Management switch configuration file (this ends in ``.pcc``).

2.  Open the switch web interface at ``http://<switch IP>``. You may be
    prompted to login - the default credentials are both ``admin``:

    .. image:: images/pswi-000.png
       :alt: User Login for switch
       :scale: 50%

3. Go to the "Management" section at bottom left:

   .. image:: images/pswi-001.png
       :alt: Update upload
       :scale: 50%

   In the "Update" section at left, drag the configuration file into the upload
   area, or click Browse and select it.

4. In the "Select switch configuration file to update" section, select
   "config1", so it overwrites the default configuration.

5. In the "Select switch configuration file to update" section, select
   "config1", so it overwrites the default configuration. Click "Update".
   You'll be prompted to reboot the switch, which you can do with the power
   symbol at top right. You may be prompted to select an image used to reboot -
   the "Previously Selected" is the correct one to use:

   .. image:: images/pswi-003.png
       :alt: Switch Image Select
       :scale: 30%

6. Wait for the switch to reboot:

   .. image:: images/pswi-004.png
       :alt: Switch Reboot
       :scale: 50%

   The switch is now configured with the correct VLANs for Pronto Use.  If you
   go to Interfaces > VLANs should see a list of VLANs configured on the
   switch:

   .. image:: images/pswi-005.png
       :alt: Mgmt VLANs
       :scale: 50%


