..
   SPDX-FileCopyrightText: © 2021 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

BESS UPF Deployment
===================

This section describes how to configure and deploy BESS UPF.

Network Configuration
---------------------

BESS UPF enabled edge setup requires three additional user plane subnets
apart from the default K8S subnets.

* **enb**: Used to provide eNBs with connectivity to SD-Core and UPF.
* **access**: Used to provide UPF with connectivity to eNBs.
* **core**: Used to provide UPF with edge services as well as the Internet access.

To help your understanding, the following example ACE environment will be used in the rest of the guide.

.. image:: images/bess-upf-example-network.svg

.. note::

   Admin and out-of-band networks are not depicted in the diagram.

+-----------+-----------+------------------------------------+-------------------+---------------+
| Network   | VLAN ID   | Subnet                             | Interface         | IP address    |
+-----------+-----------+------------------------------------+-------------------+---------------+
| k8smgmt   | 1         | 192.168.1.0/24 (gw: 192.168.1.1)   | management server | 192.168.1.254 |
|           |           |                                    +-------------------+---------------+
|           |           |                                    | compute1          | 192.168.1.3   |
|           |           |                                    +-------------------+---------------+
|           |           |                                    | compute2          | 192.168.1.4   |
|           |           |                                    +-------------------+---------------+
|           |           |                                    | compute3          | 192.168.1.5   |
+-----------+-----------+------------------------------------+-------------------+---------------+
| enb       | 2         | 192.168.2.0/24 (gw: 192.168.2.1)   | enb1              | 192.168.2.10  |
+-----------+-----------+------------------------------------+-------------------+---------------+
| access    | 3         | 192.168.3.0/24 (gw: 192.168.3.1)   | upf1 access       | 192.168.3.10  |
+-----------+-----------+------------------------------------+-------------------+---------------+
| core      | 4         | 192.168.4.0/24 (gw: 192.168.4.1)   | management server | 192.168.4.254 |
|           |           |                                    +-------------------+---------------+
|           |           |                                    | upf1 core         | 192.168.4.10  |
+-----------+-----------+------------------------------------+-------------------+---------------+

It is assumed that the management server has the only external routable address and acts
as a router connecting the Aether pod to the outside.
This means that all uplink packets leaving the Aether pod needs to be masqueraded with the
external address of the management server or the k8smgmt address if the destination
is Aether central.
Also, in order for downlink traffic to UE to be delivered to its destination,
it must be forwarded to the UPF's core interface.
This adds additional routes to the management server and L3 switch.


Check Cluster Resources
-----------------------

Before proceeding with the deployment, make sure the cluster has enough resources
to run BESS UPF by running the command below.

.. code-block:: shell

   $ kubectl get nodes -o json | jq '.items[].status.allocatable'
   {
     "cpu": "95",
     "ephemeral-storage": "1770223432846",
     "hugepages-1Gi": "32Gi",
     "intel.com/intel_sriov_netdevice": "32",
     "intel.com/intel_sriov_vfio": "32",
     "memory": "360749956Ki",
     "pods": "110"
   }

For best performance, BESS UPF requires the following resources:

* 2 dedicated cores (``"cpu"``)
* 2 1GiB HugePages (``"hugepages-1Gi"``)
* 2 SRIOV Virtual Functions bound to **vfio-pci** driver (``"intel.com/intel_sriov_vfio"``)

For environments where these resources are not available, contact Ops team for
advanced configuration.

Configure and Deploy
--------------------

Download ``aether-app-configs`` if you don't have it already in your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-app-configs"

Move the directory to ``apps/bess-upf/upf1`` and create a Helm values file for the new cluster as shown below.
Don't forget to replace the IP addresses in the example configuration with the addresses of the actual cluster.

.. code-block:: yaml

   $ cd $WORKDIR/aether-app-configs/apps/bess-upf/upf1
   $ mkdir overlays/prd-ace-test
   $ vi overlays/prd-ace-test/values.yaml
   # SPDX-FileCopyrightText: 2021-present Open Networking Foundation <info@opennetworking.org>

   config:
     upf:
       enb:
         subnet: "192.168.2.0/24"
       access:
         ip: "192.168.3.10/24"
         gateway: "192.168.3.1"
         vlan: 3
       core:
         ip: "192.168.4.10/24"
         gateway: "192.168.4.1"
         vlan: 4
     # Add below when connecting to 5G core
     #cfgFiles:
     #  upf.json:
     #    cpiface:
     #      dnn: "8internet"
     #      hostname: "upf"


Update ``fleet.yaml`` in the same directory to let Fleet use the custom configuration when deploying
BESS UPF to the new cluster.

.. code-block:: yaml

   $ vi fleet.yaml
   # add following block at the end
   - name: prd-ace-test
     clusterSelector:
       matchLabels:
         management.cattle.io/cluster-display-name: ace-test
     helm:
       valuesFiles:
         - overlays/prd-ace-test/values.yaml


Submit your changes.

.. code-block:: shell

   $ cd $WORKDIR/aether-app-configs
   $ git status
   $ git add .
   $ git commit -m "Add BESS UPF configs for test ACE"
   $ git review


Go to Fleet dashboard and wait until the cluster status becomes **Active**.
It can take up to 1 min for Fleet to fetch the configuration updates.
