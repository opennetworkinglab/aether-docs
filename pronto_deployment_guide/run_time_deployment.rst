..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

==========================
Aether Run-Time Deployment
==========================
This section describes how to install Aether edge runtime and connectivity edge applications.
Aether provides GitOps based automated deployment,
so we just need to create a couple of patches to aether-pod-configs repository.

Before you begin
================
Make sure you have the edge pod checklist ready. Specifically, the following information is required in this section.

* Management network subnet
* K8S pod and service IP ranges
* List of servers and switches, and their management IP addresses

Download aether-pod-configs repository
======================================
First, download the aether-pod-configs repository to your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

Create first patch to add ACE admin user
========================================
The first patch is to add a new ACE admin with full access to `EdgeApps` project.
Here is an example review request https://gerrit.opencord.org/c/aether-pod-configs/+/21393 you can refer to with the commands below.
Please replace "new" keyword with the name of the new ACE.

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi user_map.tfvars
   # Add the new cluster admin user to the end of the list

   $ git diff
   diff --git a/production/user_map.tfvars b/production/user_map.tfvars
   index c0ec3a3..6b9ffb4 100644
   --- a/production/user_map.tfvars
   +++ b/production/user_map.tfvars
   @@ -40,5 +40,10 @@ user_map = {
      username      = "menlo"
      password      = "changeme"
      global_roles  = ["user-base", "catalogs-use"]
   +  },
   +  new_admin = {
   +    username      = "new"
   +    password      = "changeme"
   +    global_roles  = ["user-base", "catalogs-use"]
      }
   }

   $ git add production/user_map.tfvars
   $ git commit -m "Add admin user for new ACE"
   $ git review

The second patch has dependency on the first patch, so please make sure the first patch is merged before proceeding.

Create second patch to install edge runtime and apps
====================================================
Now create another patch that will eventually install K8S and edge applications
including monitoring and logging stacks as well as Aether connected edge.
Unlike the first patch, this patch requires creating and editing multiple files.
Here is an example of the patch https://gerrit.opencord.org/c/aether-pod-configs/+/21395.
Please replace cluster names and IP addresses in this example accordingly.

Update cluster_map.tfvars
^^^^^^^^^^^^^^^^^^^^^^^^^
The first file to edit is `cluster_map.tfvars`.
Move the directory to `aether-pod-configs/production`, open `cluster_map.tfvars` file, and add the new ACE cluster information at the end of the map.
This change is required to register a new K8S cluster to Rancher, and update ACC and AMP clusters for inter-cluster service discovery.

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi cluster_map.tfvars
   # Edit the file and add the new cluster information to the end of the map

   $ git diff cluster_map.tfvars
   diff --git a/production/cluster_map.tfvars b/production/cluster_map.tfvars
   index c944352..a6d05a8 100644
   --- a/production/cluster_map.tfvars
   +++ b/production/cluster_map.tfvars
   @@ -89,6 +89,16 @@ cluster_map = {
         kube_dns_cluster_ip     = "10.53.128.10"
         cluster_domain          = "prd.menlo.aetherproject.net"
         calico_ip_detect_method = "can-reach=www.google.com"
   +    },
   +    ace-new = {
   +      cluster_name            = "ace-new"
   +      management_subnets      = ["10.94.1.0/24"]
   +      k8s_version             = "v1.18.8-rancher1-1"
   +      k8s_pod_range           = "10.54.0.0/17"
   +      k8s_cluster_ip_range    = "10.54.128.0/17"
   +      kube_dns_cluster_ip     = "10.54.128.10"
   +      cluster_domain          = "prd.new.aetherproject.net"
   +      calico_ip_detect_method = "can-reach=www.google.com"
         }
      }
   }

Update vpn_map.tfvars
^^^^^^^^^^^^^^^^^^^^^
The second file to edit is `vpn_map.tfvars`.
Move the directory to `aether-pod-configs/production`, open `vpn_map.tfvars` file, and add VPN tunnel information at the end of the map.
Unless you have specific preference, set ASN and BGP peer addresses to the next available vales in the map.
This change is required to add tunnels and router interfaces to Aether central.

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi vpn_map.tfvars
   # Edit the file and add VPN tunnel information to the end of the map

   $ git diff vpn_map.tfvars
   diff --git a/production/vpn_map.tfvars b/production/vpn_map.tfvars
   index 3c1f9b9..dd62fce 100644
   --- a/production/vpn_map.tfvars
   +++ b/production/vpn_map.tfvars
   @@ -24,5 +24,15 @@ vpn_map = {
      bgp_peer_ip_address_1    = "169.254.0.6"
      bgp_peer_ip_range_2      = "169.254.1.5/30"
      bgp_peer_ip_address_2    = "169.254.1.6"
   +  },
   +  ace-new = {
   +    peer_name                = "production-ace-new"
   +    peer_vpn_gateway_address = "111.222.333.444"
   +    tunnel_shared_secret     = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   +    bgp_peer_asn             = "65003"
   +    bgp_peer_ip_range_1      = "169.254.0.9/30"
   +    bgp_peer_ip_address_1    = "169.254.0.10"
   +    bgp_peer_ip_range_2      = "169.254.1.9/30"
   +    bgp_peer_ip_address_2    = "169.254.1.10"
      }
   }

Create ACE specific state directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Next step is to create a directory containing Terraform configs
that define desired state of Rancher and GCP resources for the new ACE cluster,
and ACE specific configurations such as IP addresses of the ACE cluster nodes.


Let's create a new directory under `aether-pod-configs/production` and
symbolic links to predefined Terraform configs(`*.tf` files) that will add
cluster, projects and applications in Rancher and VPN tunnels and firewall rules in GCP for the new ACE.
And note that Aether maintains a separate Terraform state per ACE.
So we will create a remote Terraform state definition for the new ACE, too.

.. code-block:: shell

   # Create symbolic links to pre-defined Terraform configs
   $ cd $WORKDIR/aether-pod-configs/production
   $ mkdir ace-new && cd ace-new
   $ ln -s ../../common/ace-custom/* .

   $ export CLUSTER_NAME=ace-new
   $ export CLUSTER_DOMAIN=prd.new.aetherproject.net

   # Create Terraform state definition file
   $ cat >> backend.tf << EOF
   # SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>

   terraform {
   backend "gcs" {
      bucket  = "aether-terraform-bucket"
      prefix  = "product/${CLUSTER_NAME}"
   }
   }
   EOF

   # Confirm the changes
   $ tree .
   .
   ├── alerts.tf -> ../../common/ace-custom/alerts.tf
   ├── backend.tf
   ├── cluster.tf -> ../../common/ace-custom/cluster.tf
   ├── gcp_fw.tf -> ../../common/ace-custom/gcp_fw.tf
   ├── gcp_ha_vpn.tf -> ../../common/ace-custom/gcp_ha_vpn.tf
   ├── main.tf -> ../../common/ace-custom/main.tf
   └── variables.tf -> ../../common/ace-custom/variables.tf


Now create another file called `cluster_val.tfvars` that defines all cluster nodes including switches and servers.
ACE can have various number of servers and switches but note that an odd number of *servers* can have `etcd` and `controlplane` roles.
Also, switches are not allowed to play a K8S master or normal worker role.
So don’t forget to add `node-role.aetherproject.org=switch` to labels and `node-role.aetherproject.org=switch:NoSchedule` to taints.


If the ACE requires any special settings, different set of projects for example,
please take a closer look at `variables.tf` file and override the default values specified there to `cluster_val.tfvars`, too.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$CLUSTER_NAME
   $ vi cluster_val.tfvars
   # SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>

   cluster_name  = "ace-new"
   cluster_admin = "new_admin"
   cluster_nodes = {
   new-prd-leaf1 = {
      user        = "root"
      private_key = "~/.ssh/id_rsa_terraform"
      host        = "10.94.1.3"
      roles       = ["worker"]
      labels      = ["node-role.aetherproject.org=switch"]
      taints      = ["node-role.aetherproject.org=switch:NoSchedule"]
   },
   new-server-1 = {
      user        = "terraform"
      private_key = "~/.ssh/id_rsa_terraform"
      host        = "10.94.1.3"
      roles       = ["etcd", "controlplane", "worker"]
      labels      = []
      taints      = []
   },
   new-server-2 = {
      user        = "terraform"
      private_key = "~/.ssh/id_rsa_terraform"
      host        = "10.94.1.4"
      roles       = ["etcd", "controlplane", "worker"]
      labels      = []
      taints      = []
   },
   new-server-3 = {
      user        = "terraform"
      private_key = "~/.ssh/id_rsa_terraform"
      host        = "10.94.1.5"
      roles       = ["etcd", "controlplane", "worker"]
      labels      = []
      taints      = []
   }
   }

   projects = [
   "system_apps",
   "connectivity_edge_up4",
   "edge_apps"
   ]

Lastly, we will create a couple of overriding values files for the managed applications,
one for DNS server for UEs and the other for the connectivity edge application, omec-upf-pfcp-agent.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$CLUSTER_NAME
   $ mkdir app_values && cd app_values

   $ export CLUSTER_NAME=ace-new
   $ export CLUSTER_DOMAIN=prd.new.aetherproject.net
   $ export K8S_DNS=10.54.128.10 # same address as kube_dns_cluster_ip
   $ export UE_DNS=10.54.128.11  # next address of kube_dns_cluster_ip

   # Create ace-coredns overriding values file
   $ cat >> ace-coredns.yml << EOF
   # SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>

   serviceType: ClusterIP
   service:
   clusterIP: ${UE_DNS}
   servers:
   - zones:
   - zone: .
   port: 53
   plugins:
   - name: errors
   - name: health
      configBlock: |-
         lameduck 5s
   - name: ready
   - name: prometheus
      parameters: 0.0.0.0:9153
   - name: forward
      parameters: . /etc/resolv.conf
   - name: cache
      parameters: 30
   - name: loop
   - name: reload
   - name: loadbalance
   - zones:
   - zone: apps.svc.${CLUSTER_DOMAIN}
   port: 53
   plugins:
   - name: errors
   - name: forward
      parameters: . ${K8S_DNS}
   - name: cache
      parameters: 30
   EOF

   # Create PFCP agent overriding values file
   $ cat >> omec-upf-pfcp-agent.yml << EOF
   # SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>

   config:
   pfcp:
      cfgFiles:
         upf.json:
         p4rtciface:
            p4rtc_server: "onos-tost-onos-classic-hs.tost.svc.${CLUSTER_DOMAIN}"
   EOF

Make sure the ace-new directory has all necessary files and before a review request.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$CLUSTER_NAME
   $ tree .
   .
   ├── alerts.tf -> ../../common/ace-custom/alerts.tf
   ├── app_values
   │   ├── ace-coredns.yml
   │   └── omec-upf-pfcp-agent.yml
   ├── backend.tf
   ├── cluster.tf -> ../../common/ace-custom/cluster.tf
   ├── cluster_val.tfvars
   ├── gcp_fw.tf -> ../../common/ace-custom/gcp_fw.tf
   ├── gcp_ha_vpn.tf -> ../../common/ace-custom/gcp_ha_vpn.tf
   ├── main.tf -> ../../common/ace-custom/main.tf
   └── variables.tf -> ../../common/ace-custom/variables.tf

Create a review request
^^^^^^^^^^^^^^^^^^^^^^^
Now the patch is ready to review. The final step is to create a pull request!
Once the patch is accepted and merged, CD pipeline will install ACE runtime based on the patch.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production
   $ git status
   On branch ace-new
   Changes not staged for commit:
   (use "git add <file>..." to update what will be committed)
   (use "git checkout -- <file>..." to discard changes in working directory)

      modified:   cluster_map.tfvars
      modified:   vpn_map.tfvars

   Untracked files:
   (use "git add <file>..." to include in what will be committed)

      ace-new/

   $ git add .
   $ git commit -m "Add new ACE"
   $ git review
