..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

==========================
Aether Run-Time Deployment
==========================
This section describes how to install Aether edge runtime and Aether managed applications.
We will be using GitOps based Aether CD pipeline for this,
so we just need to create a patch to **aether-pod-configs** repository.

Download aether-pod-configs repository
======================================
Download aether-pod-configs repository if you don't have it already in your develop machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

Update global resource maps
===========================
.. attention::

   Skip this section if you have already done the same step in the
   :ref:`Update Global Resources Map for VPN <update_global_resource>` section.

Add a new ACE information at the end of the following global resource maps.

* user_map.tfvars
* cluster_map.tfvars

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

Create runtime configurations
=============================
In this step, we will add several Terraform configurations and overriding values for the managed applications.
Run the following commands to auto-generate necessary files under the target ACE directory.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs/tools
   $ cp ace_env /tmp/ace_env
   $ vi /tmp/ace_env
   # Set environment variables

   $ source /tmp/ace_env
   $ make runtime
   Created ../production/ace-test
   Created ../production/ace-test/main.tf
   Created ../production/ace-test/variables.tf
   Created ../production/ace-test/gcp_fw.tf
   Created ../production/ace-test/cluster.tf
   Created ../production/ace-test/alerts.tf
   Created ../production/ace-test/backend.tf
   Created ../production/ace-test/cluster_val.tfvars
   Created ../production/ace-test/app_values
   Created ../production/ace-test/app_values/ace-coredns.yml
   Created ../production/ace-test/app_values/omec-upf-pfcp-agent.yml

Create a review request
=======================
.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs
   $ git status

   Untracked files:
   (use "git add <file>..." to include in what will be committed)

      production/ace-test/alerts.tf
      production/ace-test/app_values/
      production/ace-test/cluster.tf

   $ git add .
   $ git commit -m "Add test ACE runtime configs"
   $ git review

Once the review request is accepted and merged,
CD pipeline will start to deploy K8S and Aether managed applications on it.
