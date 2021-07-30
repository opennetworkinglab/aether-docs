.. vim: syntax=rst

Aether ROC Developer Guide
==========================

Background / Development Environment
------------------------------------

This document assumes familiarity with Kubernetes and Helm, and that a Kubernetes/Helm development
environment has already been deployed in the developer’s work environment.
This development environment can use any of a number of potential mechanisms -- including KinD, Kubeadm, etc.
The Aether-in-a-Box script is one potential way to setup a development environment, but not the only way.
As an alternative to the developer’s local machine, a remote environment can be set up, for example on
cloud infrastructure such as cloudlab.

Installing Prerequisites
------------------------

Atomix and onos-operator must be installed::

   # create necessary namespaces
   kubectl create namespace micro-onos

   # install atomix
   helm -n kube-system install atomix-controller atomix/atomix-controller
   helm -n kube-system install atomix-raft-storage atomix/atomix-raft-storage

   # install the onos operator
   helm install -n kube-system onos-operator onosproject/onos-operator


Verify that these services were installed properly.
You should see pods for *atomix-controller*, *atomix-raft-storage-controller*,
*onos-operator-config*, and *onos-operator-topo*.
Execute these commands::

   kubectl -n kube-system get pods | grep -i atomix
   kubectl -n kube-system get pods | grep -i onos


Create a values-override.yaml
-----------------------------

You’ll want to override several of the defaults in the ROC helm charts::

   cat > values-override.yaml <<EOF
   import:
   onos-gui:
      enabled: true

   onos-gui:
   ingress:
      enabled: false

   sdcore-adapter-v3:
   prometheusEnabled: false

   sdcore-exporter:
   prometheusEnabled: false

   onos-exporter:
   prometheusEnabled: false

   aether-roc-gui-v3:
   ingress:
      enabled: false
   EOF

Installing the Aether-Roc-Umbrella Helm chart
---------------------------------------------

Add the necessary helm repositories::

   # obtain username and password from Michelle and/or ONF infra team
   export repo_user=<username>
   export repo_password=<password>
   helm repo add sdran --username "$repo_user" --password "$repo_password" https://sdrancharts.onosproject.org

Aether-Roc-Umbrella will bring up the ROC and its services::

   helm -n micro-onos install aether-roc-umbrella sdran/aether-roc-umbrella -f values-override.yaml

   kubectl wait pod -n micro-onos --for=condition=Ready -l type=config --timeout=300s


Posting the mega-patch
----------------------

The ROC usually comes up in a blank state -- there are no Enterprises, UEs, or other artifacts present in it.
The mega-patch is an example patch that populates the ROC with some sample enterprises, UEs, slices, etc.
Execute the following::

   # launch a port-forward for the API
   # this will continue to run in the background
   kubectl -n micro-onos port-forward service/aether-roc-api   --address 0.0.0.0 8181:8181 &

   git clone https://github.com/onosproject/aether-roc-api.git

   # execute the mega-patch (it will post via CURL to localhost:8181)
   bash ~/path/to/aether-roc-api/examples/MEGA_Patch.curl


You may wish to customize the mega patch.
For example, by default the patch configures the sdcore-adapter to push to sdcore-test-dummy.
You could configure it to push to a live aether-in-a-box core by doing something like this::

   sed -i 's^http://aether-roc-umbrella-sdcore-test-dummy/v1/config/5g^http://webui.omec.svc.cluster.local:9089/config^g' MEGA_Patch.curl

   #apply the patch
   ./MEGA_Patch.curl

(Note that if your Aether-in-a-Box was installed on a different machine that port-forwarding may be necessary)


Expected CURL output from a successful mega-patch post will be a UUID.
You can also verify that the mega-patch was successful by going into the aether-roc-gui in a browser
(see the section on useful port-forwards below). The GUI may open to a dashboard that is unpopulated -- you
can use the dropdown menu (upper-right hand corner of the screen) to select an object such as VCS and you
will see a list of VCS.

   |ROCGUI|

Uninstalling the Aether-Roc-Umbrella Helm chart
-----------------------------------------------

To tear things back down, usually as part of a developer loop prior to redeploying again, do the following::

   helm -n micro-onos del aether-roc-umbrella

If the uninstall hangs or if a subsequent reinstall hangs, it could be an issue with some of the CRDs
not getting cleaned up. The following may be useful::

   # fix stuck finalizers in operator CRDs

   kubectl -n micro-onos patch entities connectivity-service-v2 --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'

   kubectl -n micro-onos patch entities connectivity-service-v3 --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'

   kubectl -n micro-onos patch kind aether --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'

Useful port forwards
--------------------

Port forwarding is often necessary to allow access to ports inside of Kubernetes pods that use ClusterIP addressing.
Note that you typically need to leave a port-forward running (you can put it in the background).
Also, If you redeploy the ROC and/or if a pod crashes then you might have to restart a port-forward.
The following port-forwards may be useful::

   # aether-roc-api

   kubectl -n micro-onos port-forward service/aether-roc-api --address 0.0.0.0 8181:8181

   # aether-roc-gui

   kubectl -n micro-onos port-forward service/aether-roc-gui --address 0.0.0.0 8183:80

   # grafana

   kubectl -n micro-onos port-forward service/aether-roc-umbrella-grafana --address 0.0.0.0 8187:80

   # onos gui

   kubectl -n micro-onos port-forward service/onos-gui --address 0.0.0.0 8182:80

Aether-roc-api and aether-roc-gui are in our experience the most useful two port-forwards.
Aether-roc-api is useful to be able to POST REST API requests.
Aether-roc-gui is useful to be able to interactively browse the current configuration.

Deploying using custom images
-----------------------------

Custom images may be used by editing the values-override.yaml file.
For example, to deploy a custom sdcore-adapter::

   sdcore-adapter-v3:

   prometheusEnabled: false

   image:

   repository: my-private-repo/sdcore-adapter

   tag: my-tag

   pullPolicy: Always

The above example assumes you have published a docker images at my-private-repo/sdcore-adapter:my-tag.
My particular workflow is to deploy a local-docker registry and push my images to that.
Please do not publish ONF images to a public repository unless the image is intended to be public.
Several ONF repositories are private, and therefore their docker artifacts should also be private.

There are alternatives to using a private docker repository.
For example, if you are using kubadm, then you may be able to simply tag the image locally.
If you’re using KinD, then you can push a local image to into the kind cluster::

   kind load docker-image sdcore-adapter:my-tag

Inspecting logs
---------------

Most of the relevant Kubernetes pods are in the micro-onos namespace.
The names may change from deployment to deployment, so start by getting a list of pods::

   kubectl -n micro-onos get pods

Then you can inspect a specific pod/container::

   kubectl -n micro-onos logs sdcore-adapter-v3-7468cc58dc-ktctz sdcore-adapter-v3

Some exercises to get familiar
------------------------------

1) Deploy the ROC and POST the mega-patch, go into the aether-roc-GUI and click through the VCS, DeviceGroup, and
other objects to see that they were created as expected.

2) Examine the log of the sdcore-adapter-v3 container.
It should be attempting to push the mega-patch’s changes.
If you don’t have a core available, it may be failing the push, but you should see the attempts.

3) Change an object in the GUI.
Watch the sdcore-adapter-v3 log file and see that the adapter attempts to push the change.

4) Try POSTing a change via the API.
Observe the sdcore-adapter-v3 log file and see that the adapter attempts to push the change.

5) Deploy a 5G Aether-in-a-Box (See sd-core developer guide), modify the mega-patch to specify the URL for the
Aether-in-a-Box webui container, POST the mega-patch, and observe that the changes were correctly pushed via the
sdcore-adapter-v3 into the sd-core’s webui container (webui container log will show configuration as it is
received)

.. |ROCGUI| image:: images/rocgui.png
