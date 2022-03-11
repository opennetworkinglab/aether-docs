..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Runtime Deployment
==================

This section describes how to install and configure Aether Edge Runtime including Kubernetes
and system level applications listed below.

* `sealed-secrets`
* `rancher-monitoring`
* `fluent-bit`
* `opendistro-es`
* `hostpath-provisioner`
* `edge-maintenance-agent`
* `sriov-device-plugin`
* `uedns`

For this, we will be using Aether's GitOps based CI/CD systems and what you will need to do is
create patches in Aether GitOps repositories, **aether-pod-configs** and **aether-app-configs**,
to provide cluster and application configurations to the CI/CD systems.

.. attention::

   If you skipped VPN bootstrap step and didn't add the deployment jobs for the new edge,
   go to :ref:`Add deployment jobs <add_deployment_jobs>` step and finish it first
   before proceeding.

Prepare System Application Configuration
----------------------------------------

In this step, you will create system application configurations for the new
cluster so that the new cluster can start with proper configurations as soon as
it is deployed. For the K8S application configuration and deployment, Aether leverages
Rancher's built-in GitOps tool, **Fleet**, and **aether-app-configs** is the
repository where all Aether applications are defined.

Most of the Aether system applications listed above do not require cluster
specific configurations except **uedns**.
For **uedns**, you will have to manually create custom configurations and
commit them to aether-app-configs.

First, download ``aether-app-configs`` if you don't have it already in your development machine.

.. code-block:: shell

   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-app-configs"

Configure ``ue-dns``
""""""""""""""""""""

For UE-DNS, it is required to create a Helm value override file for the new
cluster.  To do this, you'll need the ``cluster_name`` (starts with ``ace-``),
``cluster_domain`` and ``kube_dns_cluster_ip``, all of which can be found in
``aether-pod-configs/[ release train ]/cluster_map.tfvars``.

Be sure to replace ``[ ]`` in the example configuration below to the actual
edge name and cluster values.

.. code-block:: yaml

   $ cd aether-app-configs/aether-[ environment ]/infra/coredns/overlays
   $ mkdir [ cluster_name ]
   $ vi [ cluster_name ]/values.yaml
   # SPDX-FileCopyrightText: 2022-present Open Networking Foundation <info@opennetworking.org>

   serviceType: ClusterIP
   service:
     clusterIP: [ next IP address after kube_dns_cluster_ip ]
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
         - zone: aetherproject.net
       port: 53
       plugins:
         - name: errors
         - name: rewrite continue
           configBlock: |-
             name regex (.*)\.aetherproject.net {1}.svc.[ cluster_domain ]
             answer name (.*)\.svc\.[ cluster_domain ] {1}.aetherproject.net
         - name: forward
           parameters: . [ kube_dns_cluster_ip ]
           configBlock: |-
             except kube-system.svc.[ cluster_domain ] aether-sdcore.svc.[cluster domain] tost.svc.[ cluster_domain ]
         - name: cache
           parameters: 30


Next, update ``fleet.yaml`` under ``infra/coredns`` so that Fleet can use the custom configuration
you just created when deploying UE-DNS to the cluster.

.. code-block:: yaml

   $ cd aether-app-configs/aether-[ environment ]/infra/coredns
   $ vi fleet.yaml
   # add following block at the end
   - name: [ cluster_name ]
     clusterSelector:
       matchLabels:
         management.cattle.io/cluster-display-name: [ cluster_name ]
     helm:
       valuesFiles:
         - overlays/[ cluster_name ]/values.yaml


Submit your changes.

.. code-block:: shell

   $ git status
   $ git add .
   $ git commit -m "Add [ cluster_name ] ACE application configs"
   $ git review

Now, it's ready to deploy K8S.

K8S cluster deployment
----------------------

Download ``aether-pod-configs`` repository if you don't have it already in
your development machine.

.. code-block:: shell

   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

.. attention::

   If you skipped VPN bootstrap step and didn't update global resource maps for the new edge,
   go to :ref:`Update global resource maps <update_global_resource>` step and
   finish ``cluster_map.tfvars`` update first before proceeding.

Run the following commands to automatically generate Terraform configurations needed to
create a new cluster in `Rancher <https://rancher.aetherproject.org>`_ and add the servers
and switches to the cluster.

.. code-block:: shell

   # Create ace_cofig.yaml file if you haven't yet
   $ cd aether-pod-configs/tools
   $ cp ace_config.yaml.example ace_config.yaml
   $ vi ace_config.yaml
   # Set all values

   $ make runtime
   Created ../production/[ cluster_name ]/provider.tf
   Created ../production/[ cluster_name ]/cluster.tf
   Created ../production/[ cluster_name ]/rke-bare-metal.tf
   Created ../production/[ cluster_name ]/addon-manifests.yml.tpl
   Created ../production/[ cluster_name ]/project.tf
   Created ../production/[ cluster_name ]/backend.tf
   Created ../production/[ cluster_name ]/cluster_val.tfvars

.. attention::

  If the cluster has an even number of compute nodes, edit ``cluster_val.tfvars``
  file so that only the odd number of nodes have ``etcd`` and ``controlplane``
  roles.

Create a review request.

.. code-block:: shell

   $ git add .
   $ git commit -m "Add [ cluster_name ] ACE runtime configs"
   $ git review

Once your review request is accepted and merged, Aether CI/CD system starts to deploy K8S.
Wait until the cluster status changes to **Active** in `Rancher <https://rancher.aetherproject.org>`_.
It normally takes 10 - 15 minutes depending on the speed of the container images
download at the edge.

It is also a good idea to check the system pod status after successful K8S deployment.
To do so, login to Rancher, open the cluster that you just deployed in the **Global** view, and click
**Launch kubectl** button. You can interact with the cluster using the window that opens.
Run the following commands and make sure all pods are ``Running``.

.. code-block:: shell

  # Run kubectl commands inside here
  # e.g. kubectl get all
  > kubectl get po -A

.. attention::

   Ignore BESS UPF failure at this point if BESS UPF is enabled.
   We'll fix it in :doc:`BESS UPF </edge_deployment/bess_upf_deployment>` step.

Disable deployment jobs
-----------------------
After confirming the K8S cluster is ready, disable the deployment job.

.. code-block:: diff

   $ cd aether-ci-management
   $ vi jjb/repos/cd-pipeline-terraform.yaml

   # Add jobs for the new cluster
   diff jjb/repos/cd-pipeline-terraform.yamll
   --- a/jjb/repos/cd-pipeline-terraform.yaml
   +++ b/jjb/repos/cd-pipeline-terraform.yaml
   @@ -227,3 +227,9 @@
          - 'cd-pipeline-terraform-postmerge-cluster':
              cluster: 'ace-eks'
          - 'cd-pipeline-terraform-premerge-cluster':
              cluster: '[ cluster_name ]'
   -          disable-job: false
          - 'cd-pipeline-terraform-postmerge-cluster':
              cluster: '[ cluster_name ]'
   -          disable-job: false

Submit your change and wait for the job is updated.
