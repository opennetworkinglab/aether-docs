..
   SPDX-FileCopyrightText: © 2022 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Site Removal
============

This section describes how to remove an existing Aether Edge site.

Remove cluster and GCP resources
--------------------------------

Clone ``aether-pod-configs`` repository.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

Move the directory to the site you want to delete, ``ace-test`` in this example,
and remove all files under the directory except for the following three:

* `backend.tf`
* `cluster_val.tf`
* `provider.tf`

.. code-block:: shell

    $ cd $WORKDIR/aether-pod-configs/production/ace-test
    $ rm <files>
    $ ls
    backend.tf  cluster_val.tfvars  provider.tf
    $ cd ../

Next, in the parent directory edit ``cluster_map.tfvars`` and
``vpn_map.tfvars`` to remove the configurations related to the site.

.. code-block:: diff

    $ git diff cluster_map.tfvars
    diff --git a/production/cluster_map.tfvars b/production/cluster_map.tfvars
    --- a/production/cluster_map.tfvars
    +++ b/production/cluster_map.tfvars
    @@ -43,16 +43,6 @@ cluster_map = {
             cluster_domain          = "prd.tucson.aetherproject.net"
             calico_ip_detect_method = "can-reach=www.google.com"
           },
    -      ace-test = {
    -        cluster_name            = "ace-test"
    -        management_subnets      = ["10.32.4.0/24"]
    -        k8s_version             = "v1.18.8-rancher1-1"
    -        k8s_pod_range           = "10.33.0.0/17"
    -        k8s_cluster_ip_range    = "10.33.128.0/17"
    -        kube_dns_cluster_ip     = "10.33.128.10"
    -        cluster_domain          = "prd.test.aetherproject.net"
    -        calico_ip_detect_method = "can-reach=www.google.com"
    -      },
           ace-stanford1 = {
             cluster_name            = "ace-stanford1"

    $ git diff vpn_map.tfvars
    diff --git a/production/vpn_map.tfvars b/production/vpn_map.tfvars
    --- a/production/vpn_map.tfvars
    +++ b/production/vpn_map.tfvars
    @@ -16,16 +16,6 @@ vpn_map = {
         bgp_peer_ip_range_2      = "169.254.1.1/30"
         bgp_peer_ip_address_2    = "169.254.1.2"
       },
    -  ace-test = {
    -    peer_name                = "production-ace-test"
    -    peer_vpn_gateway_address = "66.201.42.222"
    -    tunnel_shared_secret     = "<Secret text here>"
    -    bgp_peer_asn             = "65003"
    -    bgp_peer_ip_range_1      = "169.254.0.9/30"
    -    bgp_peer_ip_address_1    = "169.254.0.10"
    -    bgp_peer_ip_range_2      = "169.254.1.9/30"
    -    bgp_peer_ip_address_2    = "169.254.1.10"
    -  },
       ace-stanford1 = {
         peer_name                = "production-ace-stanford1"
         peer_vpn_gateway_address = "171.64.74.233"

Create a review request with the above changes.

.. code-block:: shell

    $ git status
    Changes not staged for commit:

        deleted:    ace-test/_ansible/extra_vars.yml
        deleted:    ace-test/ansible/hosts.ini
        deleted:    ace-test/ddon-manifests.yml.tpl
        deleted:    ace-test/luster.tf
        deleted:    ace-test/cp_classic_vpn.tf
        deleted:    ace-test/cp_fw.tf
        deleted:    ace-test/ember.tf
        deleted:    ace-test/roject.tf
        deleted:    ace-test/ke-bare-metal.tf
        modified:   cluster_map.tfvars
        modified:   vpn_map.tfvars

   $ git add .
   $ git commit -m "Remove test ACE runtime and VPN configs"
   $ git review

Once your review request is accepted and merged, Aether CI/CD system starts to
destroy K8S cluster in Rancher and VPN, router, and FW resources in GCP.

.. attention::

    Destroying K8S cluster does not clean up the nodes.

Delete deployment jobs
----------------------

Clone ``aether-ci-management`` repository.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-ci-management"

Edit ``cd-pipeline-terraform.yaml`` and delete both pre-merge and post-merge jobs.

.. code-block:: diff

   $ cd $WORKDIR/aether-ci-management
   $ vi jjb/repos/cd-pipeline-terraform.yaml

    diff --git a/jjb/repos/cd-pipeline-terraform.yaml b/jjb/repos/cd-pipeline-terraform.yaml
    --- a/jjb/repos/cd-pipeline-terraform.yaml
    +++ b/jjb/repos/cd-pipeline-terraform.yaml
    @@ -206,10 +206,6 @@
               cluster: 'ace-tucson'
    -      - 'cd-pipeline-terraform-premerge-cluster':
    -          cluster: 'ace-test'
    -      - 'cd-pipeline-terraform-postmerge-cluster':
    -          cluster: 'ace-test'
           - 'cd-pipeline-terraform-premerge-cluster':
               cluster: 'ace-stanford1'

Submit your change and wait for the post-merge job completes.

.. code-block:: shell

   $ git add .
   $ git commit -m "Remove test ACE deployment jobs"
   $ git review

Delete site directory
---------------------

Finally, delete the remaining site directory from ``aether-pod-configs``.

.. code-block:: shell

    $ cd $WORKDIR/aether-pod-configs/production
    $ rm -rf ace-test

Create a review request.

.. code-block:: shell

   $ git status
   Changes not staged for commit:

       deleted:    ace-test/backend.tf
       deleted:    ace-test/cluster_val.tf
       deleted:    ace-test/provider.tf

   $ git add .
   $ git commit -m "Clean up test ACE configs"
   $ git review

.. note::

    Terraform state file may still exist in the cloud storage. A new job is
    required to clean up the state file.
