..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

=============
Bootstrapping
=============

VPN
===
This section walks you through how to set up a VPN between ACE and Aether Central in GCP.
We will be using GitOps based Aether CD pipeline for this,
so we just need to create a patch to **aether-pod-configs** repository.
Note that some of the steps described here are not directly related to setting up a VPN,
but rather are a prerequisite for adding a new ACE.

Before you begin
----------------
* Make sure firewall in front of ACE allows UDP port 500, UDP port 4500, and ESP packets
  from **gcpvpn1.infra.aetherproject.net(35.242.47.15)** and **gcpvpn2.infra.aetherproject.net(34.104.68.78)**
* Make sure that the external IP on ACE side is owned by or routed to the management node

To help your understanding, the following sample ACE environment will be used in the rest of this section.
Make sure to replace the sample values when you actually create a review request.

+-----------------------------+----------------------------------+
| Management node external IP | 128.105.144.189                  |
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
| Management Subnet           | 10.91.0.0/24                     |
+-----------------------------+----------------------------------+
| K8S Subnet                  | Pod IP: 10.66.0.0/17             |
|                             +----------------------------------+
|                             | Cluster IP: 10.66.128.0/17       |
+-----------------------------+----------------------------------+


Download aether-pod-configs repository
--------------------------------------
.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

.. _update_global_resource:

Update global resource maps
---------------------------
Add a new ACE information at the end of the following global resource maps.

* user_map.tfvars
* cluster_map.tfvars
* vpn_map.tfvars

As a note, you can find several other global resource maps under the `production` directory.
Resource definitions that need to be shared among clusters or are better managed in a
single file to avoid configuration conflicts are maintained in this way.

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
   +      management_subnets      = ["10.91.0.0/24"]
   +      k8s_version             = "v1.18.8-rancher1-1"
   +      k8s_pod_range           = "10.66.0.0/17"
   +      k8s_cluster_ip_range    = "10.66.128.0/17"
   +      kube_dns_cluster_ip     = "10.66.128.10"
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
   +    peer_vpn_gateway_address = "128.105.144.189"
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


Create ACE specific configurations
----------------------------------
In this step, we will create a directory under `production` with the same name as ACE,
and add several Terraform configurations and Ansible inventory needed to configure a VPN connection.
Throughout the deployment procedure, this directory will contain all ACE specific configurations.

Run the following commands to auto-generate necessary files under the target ACE directory.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/tools
   $ cp ace_env /tmp/ace_env
   $ vi /tmp/ace_env
   # Set environment variables

   $ source /tmp/ace_env
   $ make vpn
   Created ../production/ace-test
   Created ../production/ace-test/main.tf
   Created ../production/ace-test/variables.tf
   Created ../production/ace-test/gcp_fw.tf
   Created ../production/ace-test/gcp_ha_vpn.tf
   Created ../production/ace-test/ansible
   Created ../production/ace-test/backend.tf
   Created ../production/ace-test/cluster_val.tfvars
   Created ../production/ace-test/ansible/hosts.ini
   Created ../production/ace-test/ansible/extra_vars.yml

.. attention::
   The predefined templates are tailored to Pronto BOM. You'll need to fix `cluster_val.tfvars` and `ansible/extra_vars.yml`
   when using a different BOM.

Create a review request
-----------------------
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

Once the review request is accepted and merged,
CD pipeline will create VPN tunnels on both GCP and the management node.

Verify VPN connection
---------------------
You can verify the VPN connections after successful post-merge job
by checking the routing table on the management node and trying to ping to one of the central cluster VMs.
Make sure two tunnel interfaces, `gcp_tunnel1` and `gcp_tunnel2`, exist
and three additional routing entries via one of the tunnel interfaces.

.. code-block:: shell

   $ netstat -rn
   Kernel IP routing table
   Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
   0.0.0.0         128.105.144.1   0.0.0.0         UG        0 0          0 eno1
   10.45.128.0     169.254.0.9     255.255.128.0   UG        0 0          0 gcp_tunnel1
   10.52.128.0     169.254.0.9     255.255.128.0   UG        0 0          0 gcp_tunnel1
   10.66.128.0     10.91.0.8       255.255.128.0   UG        0 0          0 eno1
   10.91.0.0       0.0.0.0         255.255.255.0   U         0 0          0 eno1
   10.168.0.0      169.254.0.9     255.255.240.0   UG        0 0          0 gcp_tunnel1
   128.105.144.0   0.0.0.0         255.255.252.0   U         0 0          0 eno1
   169.254.0.8     0.0.0.0         255.255.255.252 U         0 0          0 gcp_tunnel1
   169.254.1.8     0.0.0.0         255.255.255.252 U         0 0          0 gcp_tunnel2

   $ ping 10.168.0.6 -c 3
   PING 10.168.0.6 (10.168.0.6) 56(84) bytes of data.
   64 bytes from 35.235.67.169: icmp_seq=1 ttl=56 time=67.9 ms
   64 bytes from 35.235.67.169: icmp_seq=2 ttl=56 time=67.4 ms
   64 bytes from 35.235.67.169: icmp_seq=3 ttl=56 time=67.1 ms

   --- 10.168.0.6 ping statistics ---
   3 packets transmitted, 3 received, 0% packet loss, time 2002ms
   rtt min/avg/max/mdev = 67.107/67.502/67.989/0.422 ms

Post VPN setup
--------------
Once you verify the VPN connections, please update `ansible` directory name to `_ansible` to prevent
the ansible playbook from running again.
Note that it is no harm to re-run the ansible playbook but not recommended.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$ACE_NAME
   $ mv ansible _ansible
   $ git add .
   $ git commit -m "Mark ansible done for test ACE"
   $ git review


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
