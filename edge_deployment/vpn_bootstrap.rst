..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

VPN Bootstrap
=============

This section guides you through setting up a VPN connection between Aether Central in GCP and ACE.
We will be using GitOps based Aether CI/CD system for this and what you need to do is
create a patch to Aether GitOps repository, **aether-pod-configs**, with the edge specific information.
Note that some of the steps described here are not directly related to setting up a VPN,
but rather are a prerequisite for adding a new ACE.

.. _add_deployment_jobs:

Add deployment jobs
-------------------
First, you need to add Jenkins jobs to Aether CI/CD system that build and apply infrastructure change
plans for the new edge. This can be done by creating a patch to **aether-ci-management** repository.

Download **aether-ci-management** repository.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-ci-management"

Add the jobs for the new cluster at the end of the `cd-pipeline-terraform-ace` project job list.
Make sure to add both pre-merge and post-merge jobs.
Note that the cluster name specified here will be used in the rest of the deployment procedure.

.. code-block:: diff

   $ cd $WORKDIR/aether-ci-management
   $ vi jjb/repos/cd-pipeline-terraform.yaml

   # Add jobs for the new cluster
   diff jjb/repos/cd-pipeline-terraform.yamll
   --- a/jjb/repos/cd-pipeline-terraform.yaml
   +++ b/jjb/repos/cd-pipeline-terraform.yaml
   @@ -227,3 +227,9 @@
          - 'cd-pipeline-terraform-postmerge-cluster':
              pod: 'production'
              cluster: 'ace-eks'
   +      - 'cd-pipeline-terraform-premerge-cluster':
   +          pod: 'production'
   +          cluster: 'ace-test'
   +      - 'cd-pipeline-terraform-postmerge-cluster':
   +          pod: 'production'
   +          cluster: 'ace-test'

Submit your change and wait for the jobs you just added available in Aether Jenkins.

.. code-block:: shell

   $ git status
   Changes not staged for commit:

     modified:   jjb/repos/cd-pipeline-terraform.yaml

   $ git add .
   $ git commit -m "Add test ACE deployment job"
   $ git review

Gather VPN information
----------------------

* Make sure firewall in front of ACE allows UDP port 500, UDP port 4500, and
  ESP packets from **gcpvpn1.infra.aetherproject.net(35.242.47.15)** and
  **gcpvpn2.infra.aetherproject.net(34.104.68.78)**

* Make sure that the external IP on ACE side is owned by or routed to the
  management node

To help your understanding, the following sample ACE environment will be used
in the rest of this section.  Make sure to replace the sample values when you
actually create a review request.

+-----------------------------+----------------------------------+
| Management node external IP | 66.201.42.222                    |
+-----------------------------+----------------------------------+
| ASN                         | 65003                            |
+-----------------------------+----------------------------------+
| GCP BGP IP address          | Tunnel 1: 169.254.0.9/30         |
|                             +----------------------------------+
|                             | Tunnel 2: 169.254.1.9/30         |
+-----------------------------+----------------------------------+
| ACE BGP IP address          | Tunnel 1: 169.254.0.10/30        |
|                             +----------------------------------+
|                             | Tunnel 2: 169.254.1.10/30        |
+-----------------------------+----------------------------------+
| PSK                         | UMAoZA7blv6gd3IaArDqgK2s0sDB8mlI |
+-----------------------------+----------------------------------+
| Management Subnet           | 10.32.4.0/24                     |
+-----------------------------+----------------------------------+
| K8S Subnet                  | Pod IP: 10.33.0.0/17             |
|                             +----------------------------------+
|                             | Cluster IP: 10.33.128.0/17       |
+-----------------------------+----------------------------------+

.. note::
   Use `this site <https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key/>`_ to generate a new strong pre-shared key.

.. attention::

   If you are adding another ACE to an existing VPN connection, go to
   :ref:`Add ACE to an existing VPN connection <add_ace_to_vpn>`

Get access to encrypted files in aether-pod-configs repository
--------------------------------------------------------------

`git-crypt <https://github.com/AGWA/git-crypt>`_ is used to securely store encrypted files
in the aether-pod-configs repository. Before proceeding, (1) install git-crypt and `gpg <https://gnupg.org/>`_,
(2) create a GPG keypair, and (3) ask a member of the Aether OPs team add your public key
to the aether-pod-configs keyring.  To create the keypair follow these steps:

.. code-block:: shell

   $ gpg --full-generate-key
   $ gpg --output <key-name>.gpg --armor --export <your-email-address>

.. _update_global_resource:

Update global resource maps
---------------------------

Download aether-pod-configs repository.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"
   $ git-crypt unlock

Add the new cluster information at the end of the following global resource maps.

* ``user_map.tfvars``
* ``cluster_map.tfvars``
* ``vpn_map.tfvars``

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi user_map.tfvars

   # Add the new cluster admin user at the end of the map
   $ git diff user_map.tfvars
   --- a/production/user_map.tfvars
   +++ b/production/user_map.tfvars
   @@ user_map = {
      username      = "menlo"
      password      = "changeme"
      global_roles  = ["user-base", "catalogs-use"]
   +  },
   +  test_admin = {
   +    username      = "test"
   +    password      = "changeme"
   +    global_roles  = ["user-base", "catalogs-use"]
      }
   }

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi cluster_map.tfvars

   # Add the new K8S cluster information at the end of the map
   $ git diff cluster_map.tfvars
   --- a/production/cluster_map.tfvars
   +++ b/production/cluster_map.tfvars
   @@ cluster_map = {
         kube_dns_cluster_ip     = "10.53.128.10"
         cluster_domain          = "prd.menlo.aetherproject.net"
         calico_ip_detect_method = "can-reach=www.google.com"
   +    },
   +    ace-test = {
   +      cluster_name            = "ace-test"
   +      management_subnets      = ["10.32.4.0/24"]
   +      k8s_version             = "v1.18.8-rancher1-1"
   +      k8s_pod_range           = "10.33.0.0/17"
   +      k8s_cluster_ip_range    = "10.33.128.0/17"
   +      kube_dns_cluster_ip     = "10.33.128.10"
   +      cluster_domain          = "prd.test.aetherproject.net"
   +      calico_ip_detect_method = "can-reach=www.google.com"
         }
      }
   }

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production
   $ vi vpn_map.tfvars

   # Add VPN and tunnel information at the end of the map
   $ git diff vpn_map.tfvars
   --- a/production/vpn_map.tfvars
   +++ b/production/vpn_map.tfvars
   @@ vpn_map = {
      bgp_peer_ip_address_1    = "169.254.0.6"
      bgp_peer_ip_range_2      = "169.254.1.5/30"
      bgp_peer_ip_address_2    = "169.254.1.6"
   +  },
   +  ace-test = {
   +    peer_name                = "production-ace-test"
   +    peer_vpn_gateway_address = "66.201.42.222"
   +    tunnel_shared_secret     = "UMAoZA7blv6gd3IaArDqgK2s0sDB8mlI"
   +    bgp_peer_asn             = "65003"
   +    bgp_peer_ip_range_1      = "169.254.0.9/30"
   +    bgp_peer_ip_address_1    = "169.254.0.10"
   +    bgp_peer_ip_range_2      = "169.254.1.9/30"
   +    bgp_peer_ip_address_2    = "169.254.1.10"
      }
   }

.. note::
   Unless you have a specific requirement, set ASN and BGP addresses to the next available values in the map.


Create Terraform and Ansible configurations
-------------------------------------------

In this step, we will create a directory under ``production`` with the same name
as the cluster, and add Terraform configurations and Ansible inventory needed
to configure a VPN in GCP and ACE accordingly.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/tools
   $ cp ace_config.yaml.example ace_config.yaml
   $ vi ace_config.yaml
   # Set all values

   $ make vpn
   Created ../production/ace-test
   Created ../production/ace-test/provider.tf
   Created ../production/ace-test/cluster.tf
   Created ../production/ace-test/gcp_ha_vpn.tf
   Created ../production/ace-test/gcp_fw.tf
   Created ../production/ace-test/backend.tf
   Created ../production/ace-test/cluster_val.tfvars
   Created ../production/ace-test/ansible
   Created ../production/ace-test/ansible/hosts.ini
   Created ../production/ace-test/ansible/extra_vars.yml


Submit your change
------------------

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production
   $ git status
   On branch tools
   Changes not staged for commit:

      modified:   cluster_map.tfvars
      modified:   user_map.tfvars
      modified:   vpn_map.tfvars

   Untracked files:
   (use "git add <file>..." to include in what will be committed)

      ace-test/

   $ git add .
   $ git commit -m "Add test ACE"
   $ git review

After the change is merged, wait for a while until the post-merge job finishes.

Verify VPN connection
---------------------

You can verify the VPN connections by checking
the routing table on the management node and trying to ping to one of the
central cluster VMs.

Be sure there are two tunnel interfaces, `gcp_tunnel1` and `gcp_tunnel2`,
and three routing entries via one of the tunnel interfaces.

.. code-block:: shell

   # Verify routings
   $ netstat -rn
   Kernel IP routing table
   Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
   0.0.0.0         66.201.42.209   0.0.0.0         UG        0 0          0 eno1
   10.32.4.0       0.0.0.0         255.255.255.128 U         0 0          0 eno2
   10.32.4.128     0.0.0.0         255.255.255.128 U         0 0          0 mgmt800
   10.45.128.0     169.254.0.9     255.255.128.0   UG        0 0          0 gcp_tunnel1
   10.52.128.0     169.254.0.9     255.255.128.0   UG        0 0          0 gcp_tunnel1
   10.33.128.0     10.32.4.138     255.255.128.0   UG        0 0          0 mgmt800
   10.168.0.0      169.254.0.9     255.255.240.0   UG        0 0          0 gcp_tunnel1
   66.201.42.208   0.0.0.0         255.255.252.0   U         0 0          0 eno1
   169.254.0.8     0.0.0.0         255.255.255.252 U         0 0          0 gcp_tunnel1
   169.254.1.8     0.0.0.0         255.255.255.252 U         0 0          0 gcp_tunnel2

   # Verify ACC VM access
   $ ping 10.168.0.6

   # Verify ACC K8S Service access
   $ nslookup kube-dns.kube-system.svc.prd.acc.gcp.aetherproject.net 10.52.128.10

You can also login to GCP console and check if the edge subnets exist in
**VPC Network > Routes > Dynamic**.


Post VPN setup
--------------

Once you verify the VPN connections, update ``ansible`` directory name to
``_ansible`` to prevent the ansible playbook from being rerun.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$ACE_NAME
   $ mv ansible _ansible
   $ git add .
   $ git commit -m "Ansible done for test ACE"
   $ git review

.. _add_ace_to_vpn:

Add another ACE to an existing VPN connection
"""""""""""""""""""""""""""""""""""""""""""""

VPN connections can be shared when there are multiple ACE clusters in a site.
In order to add another cluster to an existing VPN connection, you'll have to SSH into the
management node and manually update BIRD configuration.

.. note::

   This step needs improvements in the future.

.. code-block:: shell

   $ sudo vi /etc/bird/bird.conf
   protocol static {
      # Routings for the existing cluster
      ...
      route 10.33.128.0/17 via 10.32.4.138;

      # Add routings for the new ACE's K8S cluster IP range via cluster nodes
      # TODO: Configure iBGP peering with Calico nodes and dynamically learn these routings
      route <NEW-ACE-CLUSTER-IP> via <SERVER1>
      route <NEW-ACE-CLUSTER-IP> via <SERVER2>
      route <NEW-ACE-CLUSTER-IP> via <SERVER3>
   }

   filter gcp_tunnel_out {
      # Add the new ACE's K8S cluster IP range and the management subnet if required to the list
      if (net ~ [ 10.32.4.0/24, 10.33.128.0/17, <NEW-ACE-CLUSTER-MGMT-SUBNET>, <NEW-ACE-CLUSTER-IP-RANGE> ]) then accept;
      else reject;
   }
   # Save and exit

   $ sudo birdc configure

   # Confirm the static routes are added
   $ sudo birdc show route

