..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Bootstrapping
=============

.. _switch-install:

OS Installation - Switches
--------------------------

The installation of the ONL OS image on the fabric switches uses the DHCP and
HTTP server set up on the management server.

The default image is downloaded during that installation process by the
``onieboot`` role. Make changes to that roll and rerun the management playbook
to download a newer switch image.

Preparation
"""""""""""

The switches have a single ethernet port that is shared between OpenBMC and
ONL. Find out the MAC addresses for both of these ports and enter it into
NetBox.

Change boot mode to ONIE Rescue mode
""""""""""""""""""""""""""""""""""""

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

    root@onl:~# wedge_power.sh restart


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
"""""""""""""""""""""""""""""""""

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
""""""""""""""""""""""

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

VPN
---

This section walks you through how to set up a VPN between ACE and Aether Central in GCP.
We will be using GitOps based Aether CD pipeline for this,
so we just need to create a patch to **aether-pod-configs** repository.
Note that some of the steps described here are not directly related to setting up a VPN,
but rather are a prerequisite for adding a new ACE.

.. attention::

   If you are adding another ACE to an existing VPN connection, go to
   :ref:`Add ACE to an existing VPN connection <add_ace_to_vpn>`

Before you begin
""""""""""""""""

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
""""""""""""""""""""""""""""""""""""""

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

.. _update_global_resource:

Update global resource maps
"""""""""""""""""""""""""""

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
""""""""""""""""""""""""""""""""""

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
"""""""""""""""""""""""

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
"""""""""""""""""""""

You can verify the VPN connections after successful post-merge job
by checking the routing table on the management node and trying to ping to one of the central cluster VMs.
Make sure two tunnel interfaces, `gcp_tunnel1` and `gcp_tunnel2`, exist
and three additional routing entries via one of the tunnel interfaces.

.. code-block:: shell

   # Verify routings
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

   # Verify ACC VM access
   $ ping 10.168.0.6

   # Verify ACC K8S cluster access
   $ nslookup kube-dns.kube-system.svc.prd.acc.gcp.aetherproject.net 10.52.128.10

You can further verify whether the ACE routes are propagated well to GCP
by checking GCP dashboard **VPC Network > Routes > Dynamic**.


Post VPN setup
""""""""""""""

Once you verify the VPN connections, please update `ansible` directory name to `_ansible` to prevent
the ansible playbook from running again.
Note that it is no harm to re-run the ansible playbook but not recommended.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/production/$ACE_NAME
   $ mv ansible _ansible
   $ git add .
   $ git commit -m "Mark ansible done for test ACE"
   $ git review

.. _add_ace_to_vpn:

Add another ACE to an existing VPN connection
"""""""""""""""""""""""""""""""""""""""""""""

VPN connections can be shared when there are multiple ACE clusters in a site.
In order to add ACE to an existing VPN connection,
you'll have to SSH into the management node and manually update BIRD configuration.

.. note::

   This step needs improvements in the future.

.. code-block:: shell

   $ sudo vi /etc/bird/bird.conf
   protocol static {
      ...
      route 10.66.128.0/17 via 10.91.0.10;

      # Add routings for the new ACE's K8S cluster IP range via cluster nodes
      # TODO: Configure iBGP peering with Calico nodes and dynamically learn these routings
      route <NEW-ACE-CLUSTER-IP> via <SERVER1>
      route <NEW-ACE-CLUSTER-IP> via <SERVER2>
      route <NEW-ACE-CLUSTER-IP> via <SERVER3>
   }

   filter gcp_tunnel_out {
      # Add the new ACE's K8S cluster IP range and the management subnet if required to the list
      if (net ~ [ 10.91.0.0/24, 10.66.128.0/17, <NEW-ACE-CLUSTER-IP-RANGE> ]) then accept;
      else reject;
   }
   # Save and exit

   $ sudo birdc configure

   # Confirm the static routes are added
   $ sudo birdc show route

