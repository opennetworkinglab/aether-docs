..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Runtime Deployment
==================

This section describes how to configure and install Aether edge runtime including K8S
and system level resources.
We will be using GitOps based Aether CI/CD system for this and what you need to do is
create a patch to Aether GitOps repository, **aether-pod-configs**, with the edge
specific information.

.. attention::

   If you skipped VPN bootstap step and didn't add the deployment jobs for the new edge,
   go to :ref:`Add deployment jobs <add_deployment_jobs>` step and finish it first
   before proceeding.

Download aether-pod-configs repository
--------------------------------------

Download ``aether-pod-configs`` repository if you don't have it already in
your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

.. _create_cluster_configs:

Create cluster configurations
-----------------------------

.. attention::

   If you skipped VPN bootstap step and didn't update global resource maps for the new edge,
   go to :ref:`Update global resource maps <update_global_resource>` step and
   finish ``cluster_map.tfvars`` and ``user_map.tfvars`` update first before proceeding.

Run the following commands to auto-generate Terraform configurations needed to
create a new cluster in `Rancher <https://rancher.aetherproject.org>`_  and add servers and
switches to the cluster.

.. code-block:: shell

   # Create ace_cofig.yaml file if you haven't yet
   $ cd $WORKDIR/aether-pod-configs/tools
   $ cp ace_config.yaml.example ace_config.yaml
   $ vi ace_config.yaml
   # Set all values

   $ make runtime
   Created ../production/ace-test/provider.tf
   Created ../production/ace-test/cluster.tf
   Created ../production/ace-test/rke-bare-metal.tf
   Created ../production/ace-test/addon-manifests.yml.tpl
   Created ../production/ace-test/project.tf
   Created ../production/ace-test/member.tf
   Created ../production/ace-test/backend.tf
   Created ../production/ace-test/cluster_val.tfvars


Commit your change
------------------

Lastly, create a review request with the changes.
Once your review request is accepted and merged, the post-merge job will start to deploy K8S at the edge.
Wait until the cluster is **Active** status in `Rancher <https://rancher.aetherproject.org>`_.

.. code-block:: shell

   $ cd $WORKDIR/aether-pod-configs
   $ git status
   $ git add .
   $ git commit -m "Add test ACE runtime configs"
   $ git review
