..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

===========================
Connectivity Control Update
===========================
At this point, the Aether runtime should be ready.
In order to make Aether connectivity control to serve the new ACE,
we need to provision the subscriber and configure the connectivity service.

Before you begin
================
Make sure you have the edge pod checklist ready.
Specifically, the following information is required in this section.

* `Enterprise Name`. Choose a concise text identifier for the enterprise.
* `MCC`. Mobile country code. Consult Aether PMFE for assignment.
* `MNC`. Mobile network code. Consult Aether PMFE for assignment.
* `Enterprise ID`. A numeric ID that uniquely identifies each enterprise
  within Aether. Consult Aether PMFE for assignment.
* List of small cell `addresses` and their `TAC` assignments.
* Address of `BESS UPF`. See the previous section on setting up the BESS UPF.
* Subscriber `IMSI list`. A list of IMSIs for SIMs that the Enterprise will
  be provided with. New IMSIs can always be added later.

Download aether-app-configs repository
======================================
First, download the aether-app-configs repository to your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-app-configs"

Update simapp settings
======================

Edit the simapp configuration and add the new IMSIs to sim management. The
file to edit depends on which Aether Connectivity Cluster serves the Enterprise
site. The appropriate file for standard Aether production is
`aether-app-configs/apps/sd-core-4g/overlays/prd-acc-gcp1/values.yaml`. Other
clusters will be located in similar directories.

The following example demonstrates adding IMSIs 123456789123460-123456789123465:

.. code-block:: diff

   simapp.yaml:
      info:
         version: 1.0.0
         description: SIMAPP initial local configuration
      logger:
         # network function
         APP:
         debugLevel: info
         ReportCaller: false
      configuration:
         provision-network-slice: false
         subscribers:
         - ueId-start: 123456789123458
           ueId-end: 123456789123458
           plmnId: 20893
           opc: 8e27b6af0e692e750f32667a3b14605d
           key: 8baf473f2f8fd09487cccbd7097c6862
           sequenceNumber: 16f3b3f70fc2
   +      - ueId-start: 123456789123460
   +        ueId-end: 123456789123465
   +        plmnId: 20893
   +        opc: 8e27b6af0e692e750f32667a3b14605d
   +        key: 8baf473f2f8fd09487cccbd7097c6862
   +        sequenceNumber: 16f3b3f70fc2

Commit your change back to the aether-app-configs repository when you are
finished.


Configure Connectivity
======================
Once the SIMs are provisioned in `simapp`, the next step is to provision the customer in the ROC.
All of these steps are done using the Portal.

#. Create a new Enterprise. Link a Connectivity Service to the Enterprise.

#. Create an AP-List. Enter all of the small cells and their TACs into the AP-List.

#. Create a Site for the Enterprise. Each site should represent one geographical
   point of presence where the Enterprise expects to have an Aether installation. Each site
   will need the `MNC`, `MCC`, and `Enterprise ID`. Enter these parameters into the
   `IMSI Format` together with a mask. Using a mask that is 15 "S" characters
   (`SSSSSSSSSSSSSSS`) would allow arbitrary IMSIs to be associated with the Site. Add the
   AP-List you created previously to the Site.

#. Create an IP-Domain for the Enterprise. The IP-Domain should contain the DNS servers
   and a subnet that can be assigned to the connected devices.

#. Create a UPF object. Populate the UPF object with the address and port of the UPF.

#. Create a Device-Group. Populate the Device-Group with the list of IMSIs that have
   been assigned to the Enterprise. Link in the IP-Domain that was created previously, and
   attach it to the site.

#. Create a VCS. Select an appropriate template for the VCS. Link in the Device-Group,
   AP-List, and UPF that was created previously.

#. Repeat the steps above as necessary for each VCS and for each Site that belongs to
   the enterprise.

.. note:: This workflow does not address creating applications, as application filtering is
   not part of the Aether-1.5 feature set.

.. note:: This workflow does not address creating default sites, default device groups, or
   default VCSes, as subscriber-proxy based subscriber-learning is not enabled at this time.
