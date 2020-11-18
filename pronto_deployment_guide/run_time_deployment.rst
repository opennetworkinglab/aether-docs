..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

==========================
Aether Run-Time Deployment
==========================
This section describes how to install Aether edge runtime and Aether managed applications.
We will be using GitOps based Aether CD pipeline for this,
so we just need to create a patch to **aether-pod-configs** repository.

Before you begin
================
Make sure :ref:`Update Global Resources Map <update_global_resource>` section is completed.

Download aether-pod-configs repository
======================================
Download aether-pod-configs repository if you don't have it already in your develop machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

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
   Created ../production/ace-test/main.tf
   Created ../production/ace-test/variables.tf
   Created ../production/ace-test/cluster.tf
   Created ../production/ace-test/alerts.tf
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
