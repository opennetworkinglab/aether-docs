..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

SD-Fabric Deployment
====================

Update aether-pod-configs
-------------------------

``aether-app-configs`` is a git project hosted on **gerrit.opencord.org** and
we placed the following materials in it.

- Rancher Fleet's configuration to install SD-Fabric applications on Rancher,
  including ONOS, Stratum, Telegraf and PFCP-Agent.
- Customized configuration for each application (helm values).
- Application specific configuration files, including ONOS network configuration and Stratum chassis config.

Here is an example folder structure:

.. code-block::  bash

   ╰─$ tree aether-dev/app/onos aether-dev/app/stratum aether-dev/app/pfcp-agent aether-dev/app/telegraf
   ├── fleet.yaml
   ├── kustomization.yaml
   ├── overlays
   │   ├── dev-pairedleaves-tucson
   │   │   └── values.yaml
   │   ├── dev-pdp-menlo
   │   │   └── values.yaml
   │   └── dev-sdfabric-menlo
   │       └── values.yaml
   └── registry-sealed-secret.yaml
   aether-dev/app/stratum
   ├── fleet.yaml
   └── overlays
      ├── dev-pairedleaves-tucson
      │   ├── kustomization.yaml
      │   ├── leaf1
      │   ├── leaf2
      │   ├── qos-config-leaf1.yaml
      │   ├── qos-config-leaf2.yaml
      │   └── values.yaml
      └── dev-sdfabric-menlo
         ├── kustomization.yaml
         ├── menlo-sdfabric-leaf1
         ├── menlo-sdfabric-leaf2
         └── values.yaml
   aether-dev/app/pfcp-agent
   ├── fleet.yaml
   └── overlays
      ├── dev-pairedleaves-tucson
      │   └── values.yaml
      └── dev-sdfabric-menlo
         └── values.yaml
   aether-dev/app/telegraf
   ├── fleet.yaml
   └── overlays
      ├── dev-pairedleaves-tucson
      │   └── values.yaml
      └── dev-sdfabric-menlo
         └── values.yaml


App folder
""""""""""

Rancher Fleet reads ``fleet.yaml`` to know where to download the Helm Chart manifest and
how to customize the deployment for each target clusters.

Here is the example of ``fleet.yaml`` which downloads SD-Fabric(1.0.18) Helm Chart from
**https://charts.aetherproject.org** and then use the **overlays/$cluster_name/values.yaml**
to customize each cluster.

.. code-block:: YAML

   # SPDX-FileCopyrightText: 2021-present Open Networking Foundation <info@opennetworking.org>

   defaultNamespace: tost
   helm:
   releaseName: sdfabric
   repo: https://charts.aetherproject.org
   chart: sdfabric
   version: 1.0.18
   helm:
      values:
         import:
         stratum:
            enabled: false
   targetCustomizations:
   - name: dev-sdfabric-menlo
      clusterSelector:
         matchLabels:
         management.cattle.io/cluster-display-name: dev-sdfabric-menlo
      helm:
         valuesFiles:
         - overlays/dev-sdfabric-menlo/values.yaml
   - name: dev-pairedleaves-tucson
      clusterSelector:
         matchLabels:
         management.cattle.io/cluster-display-name: dev-pairedleaves-tucson
      helm:
         valuesFiles:
         - overlays/dev-pairedleaves-tucson/values.yaml
   - name: dev-pdp-menlo
      clusterSelector:
         matchLabels:
         management.cattle.io/cluster-display-name: dev-pdp-menlo
      helm:
         valuesFiles:
         - overlays/dev-pdp-menlo/values.yaml



**values.yaml** used to custom your sdfabric Helm chart values and please check
`SD-Fabric Helm chart <https://gerrit.opencord.org/plugins/gitiles/sdfabric-helm-charts/+/HEAD/sdfabric/README.md>`_
to see how to configure it.

ONOS App
""""""""

For the ONOS application, the most import configuration is network configuration (netcfg)
which is environment-dependent configuration and you should configure it properly.

netcfg is configured in the Helm Value files and please check the following example.

.. code-block:: bash

   ╰─$ cat aether-app-configs/aether-dev/app/onos/overlays/dev-sdfabric-menlo/values.yaml                                                                                                                                                    130 ↵
   # SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>

   # Value file for SDFabric helm chart.
   ...
   onos-classic:
      config:
         componentConfig:
            "org.onosproject.net.host.impl.HostManager": >
            {
               "monitorHosts": "true",
               "probeRate": "10000"
            }
            "org.onosproject.provider.general.device.impl.GeneralDeviceProvider": >
            {
               "readPortId": true
            }
         netcfg: >
            {
               .....
            }



Please check
`SD-Fabric Configuration Guide <https://docs.sd-fabric.org/master/configuration/network.html>`_
to learn more about network configuration.


Stratum App
"""""""""""

Stratum reads the chassis config from the Kubernetes configmap resource but it doesn't support the function
to dynamically reload the chassis config, which means we have to restart the Stratum pod every time
when we update the chassis config.

In order to solve this problem without modifying Stratum's source code, we have introduced the Kustomize to
the deployment process. Kustomize supports the function called configMapGenerator which generates the configmap
with a hash suffix in its name and then inject this hash-based name to the spec section of Stratum YAML file.

See the following example, you can see the configmap name isn't fixed.

.. code-block: bash

   ╰─$ kc -n tost get daemonset stratum -o json
   | jq '.spec.template.spec.volumes | .[] | select(.name == "chassis-config")'
   {
   "configMap": {
      "defaultMode": 484,
      "name": "stratum-chassis-configs-7t6tt25654"
   },
   "name": "chassis-config"
   }


From the view of the Kubernetes, when it notices the spec of the YAML file is changed, it will redeploy whole
Stratum application, which means Stratum will read the updated chassis config eventually.

.. code-block:: bash

   ╰─$ tree aether-dev/app/stratum
   ├── fleet.yaml
   └── overlays
      ├── dev-pairedleaves-tucson
      │   ├── kustomization.yaml
      │   ├── leaf1
      │   ├── leaf2
      │   ├── qos-config-leaf1.yaml
      │   ├── qos-config-leaf2.yaml
      │   └── values.yaml
      └── dev-sdfabric-menlo
         ├── kustomization.yaml
         ├── menlo-sdfabric-leaf1
         ├── menlo-sdfabric-leaf2
         └── values.yaml

   ╰─$ cat aether-dev/app/stratum/overlays/dev-pairedleaves-tucson/kustomization.yaml
   # SPDX-FileCopyrightText: 2021-present Open Networking Foundation <info@opennetworking.org>

   configMapGenerator:
   - name: stratum-chassis-configs
      files:
         - leaf1
         - leaf2

..

Check `SD-Fabric Doc <https://gerrit.opencord.org/plugins/gitiles/sdfabric-helm-charts/+/HEAD/sdfabric/README.md>`_
to learn how to write the chassis config and don't forget to add the file name into the kustomization.yaml file
once you set up your chassis config.

.. attention::

   The switch-dependent config file should be named as **${hostname}**.
   For example, if the host name of your Tofino switch is **my-leaf**, please name config file **my-leaf**.

..
   TODO: Add an example based on the recommended topology

Telegraf App
""""""""""""

Below is the example directory structure of Telegraf application.

.. code-block::

   ╰─$ tree aether-dev/app/telegraf                                                                                                                                                                                                 255 ↵
   aether-dev/app/telegraf
   ├── fleet.yaml
   └── overlays
      ├── dev-pairedleaves-tucson
      │   └── values.yaml
      └── dev-sdfabric-menlo
         └── values.yaml


The **values.yaml** used to override the ONOS-Telegraf Helm Chart and its environment-dependent.
Please pay attention to the **inputs.addresses** section.
Telegraf will read data from stratum so we need to specify all Tofino switch’s IP addresses here.
Taking Menlo staging pod as example, there are four switches so we fill out 4 IP addresses.

.. code-block:: yaml

   config:
      outputs:
         - prometheus_client:
            metric_version: 2
            listen: ":9273"
   inputs:
      - cisco_telemetry_gnmi:
         addresses:
            - 10.92.1.81:9339
            - 10.92.1.82:9339
            - 10.92.1.83:9339
            - 10.92.1.84:9339
         redial: 10s
      - cisco_telemetry_gnmi.subscription:
         name: stratum_counters
         origin: openconfig-interfaces
         path: /interfaces/interface[name=*]/state/counters
         sample_interval: 5000ns
         subscription_mode: sample


Create Your Own Configs
"""""""""""""""""""""""

Assume we would like to deploy the SD-Fabric to the ace-example cluster in the development environment.

1. Modify the fleet.yaml to customize your cluster with specific value file.
2. Add your Helm Values into the overlays folder.
3. Have to add the chassis config file into the kustomization.yaml for Stratum application.

.. code-block:: console

   ╰─$ git st
   On branch master
   Your branch is up to date with 'origin/master'.

   Changes to be committed:
   (use "git restore --staged <file>..." to unstage)
         modified:   aether-dev/app/onos/fleet.yaml
         new file:   aether-dev/app/onos/overlays/dev-my-cluster/values.yaml
         modified:   aether-dev/app/stratum/fleet.yaml
         new file:   aether-dev/app/stratum/overlays/dev-my-cluster/kustomization.yaml
         new file:   aether-dev/app/stratum/overlays/dev-my-cluster/menlo-sdfabric-leaf1
         new file:   aether-dev/app/stratum/overlays/dev-my-cluster/menlo-sdfabric-leaf2
         new file:   aether-dev/app/stratum/overlays/dev-my-cluster/values.yaml
         modified:   aether-dev/app/telegraf/fleet.yaml
         new file:   aether-dev/app/telegraf/overlays/dev-my-cluster/values.yaml


Quick recap
"""""""""""

To recap, most of the files in **app** folder can be copied from existing examples.
However, there are a few files we need to pay extra attentions to.

- ``fleet.yaml`` in each app folder
- Chassis config in **app/stratum/overlays/$cluster_name/** folder
  There should be one chassis config for each switch. The file name needs to be
  **${hostname}**
- **values.yaml** in **telegraf** folder need to be updated with all switch
  IP addresses

Double check these files and make sure they have been updated accordingly.

Create a review request
"""""""""""""""""""""""

We also need to create a gerrit review request, similar to what we have done in
the **Aether Runtime Deployment**.

Please refer to :doc:`Aether Runtime Deployment <runtime_deployment>` to
create a review request.

Deploy to ACE cluster
"""""""""""""""""""""

SD-Fabric is environment dependent application and you have to prepare correct
configurations for both ONOS and Stratum to make it work.

Check below section to learn more about how we setup the Jenkins job and how it works

Create SD-Fabric deployment job in Jenkins
------------------------------------------

We have been using the Rancher Fleet to deploy SD-Fabric as the GitOps approach which means every change
we push to the Git repo will be synced to the target cluster automatically.

However, ONOS doesn't support the incremental upgrade which means we have to delete all ONOS instance and
then create all instance again every time we want to upgrade ONOS application.

Rancher Fleet doesn't support the full recreation during the Application upgrade and that's reason we have
created a Jenkins job to recreate the ONOSs application.

You have to add the Jenkins job for new cluster by modifying ``aether-ci-management``

Download the ``aether-ci-management`` repository.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-ci-management"


Create Your Own Jenkins Job
"""""""""""""""""""""""""""

Modify jjb/repos/sdfabric.yaml to add your cluster.

For example, we want to deploy the SD-Fabric to our new cluster **my-cluster** which is on the staging environment.
Add the following content into jjb/repo/sdfabric.yaml.


.. code-block:: yaml

   --- a/jjb/repos/sdfabric.yaml
   +++ b/jjb/repos/sdfabric.yaml
   @@ -50,6 +50,17 @@
         - "deploy-sdfabric-app":
         - "deploy-debug"

   +- project:
   +    name: my-cluster
   +    disable-job: false
   +    fleet-workspace: 'aether-dev'
   +    properties:
   +      - onf-infra-onfstaff-private
   +    jobs:
   +      - "deploy-sdfabric-app":
   +      - "deploy-debug"
   +
   +

If your cluster is on the production environment, you have to change both **terraform_env** and **fleet-workspace**

Trigger SD-Fabric deployment in Jenkins
---------------------------------------------------------------

Whenever a change is merged into **aether-app-config**,
the Jenkins job should be triggered automatically to (re)deploy SD-Fabric .

You can also manually trigger the job to redeploy SD-Fabric if needed and below
is an example of default parameters when you run the job.

.. image:: images/jenkins-sdfabric-params.png
   :width: 480px


If you want to capture all SD-Fabric related containers logs before redeploying them,
please enable ``POD_LOG`` option.
The Jenkins job helps to redeploy ONOS, Stratum and PFCP-Agent application and the default
options is ONOS and Stratum, you can redeploy what you want by click those ``REDEPLOY_XXXX``
options.


Verification
------------

Fabric connectivity should be fully ready at this point.
We should verify that **all servers**, including compute nodes and the management server,
have an IP address and are **able to reach each other via fabric interface** before continuing the next step.

This can be simply done by running a **ping** command from one server to another server's fabric IP.


Troubleshooting
---------------

The deployment process involves the following steps:

1. Jenkins Job (For ONOS Only)
2. Rancher Fleet upgrade application based on Git change
3. Applications be deployed into Kubernetes cluster
4. ONOS/Stratum will read the configuration (network config, chassis config)
5. Pod become running

Taking ONOS as an example, here's what you can do to troubleshoot.

You can see the log message of the first step in Jenkins console.
If something goes wrong, the status of the Jenkins job will be in red.
If Jenkins doesn't report any error message, the next step is going to Rancher Fleet's
portal to ensure Fleet works as expected.

Accessing the Stratum CLI
"""""""""""""""""""""""""

You can login to the Stratum container running on a switch using this script:

.. code-block:: sh

  #!/bin/bash
  echo 'Attaching to Stratum container. Ctrl-P Ctrl-Q to exit'
  echo 'Press Enter to continue...'
  DOCKER_ID=`docker ps | grep stratum-bf | awk '{print $1}'`
  docker attach $DOCKER_ID

You should then see the ``bf_sde`` prompt:

.. code-block:: sh

  bf_sde> pm
  bf_sde.pm> show -a

Accessing the ONOS CLI
""""""""""""""""""""""

After setting up kubectl to access the SD-Fabric pods, run:

.. code-block:: sh

  $ kubectl get pods -n tost

Pick a SD-Fabric pod, and make a port forward to it, then login to it with the
``onos`` CLI tool:

.. code-block:: sh

  $ kubectl -n tost port-forward onos-tost-onos-classic-0 8181 8101
  $ onos karaf@localhost

In some rare cases, you may need to access the ONOS master instance CLI, in
which case you can run ``roles``:

.. code-block:: sh

  karaf@root > roles
  device:devswitch1: master=onos-tost-onos-classic-1, standbys=[ onos-tost-onos-classic-0 ]

Above lines show that ``onos-tost-onos-classic-1`` is the master. So switch to
that by killing the port forward, starting a new one pointing at the master,
then logging into that one:

.. code-block:: sh

  $ ps ax | grep -i kubectl
  # returns kubectl commands running, pick the port-forward one and kill it
  $ kill 0123
  $ kubectl -n tost port-forward onos-tost-onos-classic-1 8181 8101
  $ onos karaf@localhost
