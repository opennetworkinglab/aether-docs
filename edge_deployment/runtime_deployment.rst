..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Aether Runtime Deployment
=========================

This section describes how to install Aether edge runtime and Aether managed applications
including monitoring and logging system, as well as User Plane Function(UPF).
We will be using GitOps based Aether CI/CD system for this and all you need to do is to
create several patches to Aether GitOps repositories.

Download aether-pod-configs repository
--------------------------------------

Download the ``aether-pod-configs`` repository if you don't have it already in
your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

Update global resource maps
---------------------------

.. attention::

   Skip this section and go to :ref:`Create runtime configurations <create_runtime_configs>`
   if you have already done the same in the
   :ref:`Update Global Resources Map for VPN <update_global_resource>` section.

Add a new ACE information at the end of the following global resource maps.

* user_map.tfvars
* cluster_map.tfvars

As a note, you can find several other global resource maps under the
`production` directory.  Resource definitions that need to be shared among
clusters or are better managed in a single file to avoid configuration
conflicts are maintained in this way.

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

You'll have to get this change merged before proceeding.

.. code-block:: shell

   $ git status
   On branch tools
   Changes not staged for commit:

      modified:   cluster_map.tfvars
      modified:   user_map.tfvars

   $ git add .
   $ git commit -m "Add test ACE"
   $ git review

.. _create_runtime_configs:

Create runtime configurations
-----------------------------

Run the following commands to auto-generate Terraform configurations needed to
create K8S cluster in Rancher and add servers and switches to the cluster.

.. code-block:: shell

   # Create ace_cofig.yaml file if you haven't yet
   $ cd $WORKDIR/aether-pod-configs/tools
   $ cp ace_config.yaml.example ace_config.yaml
   $ vi ace_config.yaml
   # Set all values

   $ make runtime
   Created ../production/ace-test/provider.tf
   Created ../production/ace-test/member.tf
   Created ../production/ace-test/rke-bare-metal.tf
   Created ../production/ace-test/addon-manifests.yml.tpl
   Created ../production/ace-test/project.tf


Create a review request
-----------------------

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs
   $ git status
   $ git add .
   $ git commit -m "Add test ACE runtime configs"
   $ git review

Once the review request is accepted and merged, the post-merge job will start to deploy K8S.
Wait until the cluster is **Active** status in Rancher.
