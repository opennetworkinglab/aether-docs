..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Subscriber and Connectivity Management
======================================

Subscriber management includes workflows associated with provisioning new subscribers, removing
existing subscribers, and associating subscribers with virtual connectivity services.

Provisioning a new UE
---------------------

Before a UE can be granted connectivity service, it must first be provisioned. This step is normally
performed by Aether Operations.

Each UE is assigned a PLMN and a set of security keys. Depending on the deployment scenario, these
keys might be shared by several UEs, or they might be unique to each UE. The allocation of PLMNs and
keys is currently performed manually by the Aether Operations team. This subscriber-related
detail is configured via the SIM Management application, Simapp.

`simapp.yaml` needs to be adjusted to include the new UE IMSIs to the subscriber list. For example::

    # simapp.yaml
    # ...
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
          - ueId-start: 123456789123460
            ueId-end: 123456789123465
            plmnId: 20893
            opc: 8e27b6af0e692e750f32667a3b14605d
            key: 8baf473f2f8fd09487cccbd7097c6862
            sequenceNumber: 16f3b3f70fc2

TODO: This file will probably be placed under gitops control once the 5G ROC is deployed. Document
the new location of the file.

Configure Connectivity Service for a new UE
-------------------------------------------

To receive connectivity service, a UE must be added to a DeviceGroup. An enterprise is typically
organized into one or more sites, each site which may contain one or more DeviceGroups. Navigate
to the site you where the device will be deployed, find the appropriate device group, and add
the UE's IMSI to the DeviceGroup.

TODO: Describe GUI process and add Picture

Note: For 4G service, a UE may participate in at most one DeviceGroup, and that DeviceGroup may
participate in at most one VCS. For 5G service, a UE can participate in many DeviceGroups, and each
DeviceGroup may participate in many VCSes.

Remove Connectivity Service from an existing UE
-----------------------------------------------

Using the ROC GUI, navigate to the Device Group that contains the UE,
then remove that UE's IMSI from the list. If you are removing a single UE, and the
DeviceGroup is configured with a range specifier that includes several IMSIs,
then it might be necessary to split that range into multiple ranges.

TODO: Describe GUI process and add Picture

Note: The UE may continue to have connectivity until its next detach/attach cycle.

Create a new DeviceGroup
------------------------

DeviceGroups allow UEs to be grouped and configured together. Each site comes preconfigured with
a default DeviceGroup, but additional DeviceGroups may be created. For example, placing all IP
Cameras in an my-site-ip-cameras DeviceGroup would allow you to group IP Cameras together.

TODO: Describe GUI process and add Picture

Delete a DeviceGroup
--------------------

IF a DeviceGroup is no longer needed, it can be deleted. Deleting a DeviceGroup will not cause
the UEs participating in the group to automatically be moved elsewhere.

TODO: Describe GUI process and add Picture

Add a DeviceGroup to a Virtual Connectivity Service (VCS)
---------------------------------------------------------

In order to participate in the connectivity service, a DeviceGroup must be associated with
a Virtual Connectivity Service (VCS).

TODO: Describe GUI process and add Picture

Remove a DeviceGroup from a Virtual Connectivity Service (VCS)
--------------------------------------------------------------

TODO: Describe GUI process and add Picture

