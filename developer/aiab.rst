.. vim: syntax=rst

Aether-in-a-Box for Developers
==============================

Aether-in-a-Box (AiaB) provides an easy way to deploy Aether's SD-CORE and ROC
components, and then run basic tests to validate the installation.
This guide describes the steps to set up AiaB.

AiaB can be set up with a 4G or 5G SD-CORE.  In either case, SD-CORE configuration
can be done with or without the ROC.  The ROC
provides an interactive GUI for examining and changing the configuration, and is used to
manage the production Aether; it can be deployed to test the integration between
ROC and SD-CORE.  If the ROC is not deployed, a simple tool called SimApp
is used to configure the required state in SD-CORE for testing core functionality.

Helm charts are the primary method of installing the SD-CORE and ROC resources.
AiaB offers a great deal of flexibility regarding which Helm chart versions to install:

* Local definitions of charts (for testing Helm chart changes)
* Latest published charts (for deploying a development version of Aether)
* Specified versions of charts (for deploying a specific Aether release)

AiaB can be run on a bare metal machine or VM.  System prerequisites:

* Ubuntu 18.04 clean install
* Kernel 4.15 or later
* Haswell CPU or newer
* At least 4 CPUs and 12GB RAM
* Ability to run "sudo" without a password.  Due to this requirement, AiaB is most suited to disposable environments like a VM or a `CloudLab <https://cloudlab.us>`_ machine.

Clone Repositories
------------------

To initialize the AiaB environment, first clone the following repository::

    cd ~
    git clone "https://gerrit.opencord.org/aether-in-a-box"

If you are going to install AiaB using published Helm charts, you can proceed to the
next section.

If you wish to install from local Helm charts, clone these additional repositories::

    mkdir -p ~/cord
    cd ~/cord
    git clone "https://gerrit.opencord.org/sdcore-helm-charts"
    git clone "https://gerrit.opencord.org/roc-helm-charts"

Now change to *~/aether-in-a-box* directory.

RKE2 vs. Kubespray Install
--------------------------

The AiaB installer will bring up Kubernetes on the server where it is run.  By default it
uses `RKE2 <https://docs.rke2.io>`_ as the Kubernetes platform.  However, older versions of AiaB
used `Kubespray <https://kubernetes.io/docs/setup/production-environment/tools/kubespray/>`_
and that is still an option.  To switch to Kubespray as the Kubernetes platform, edit the
Makefile and replace *rke2* with *kubespray* on this line::

    K8S_INSTALL := rke2

Installing the ROC
------------------

Note that you must install the ROC *before* installing SD-CORE.
If you are not using the ROC to configure SD-CORE, you can skip this step.

First choose whether you will install the 4G or 5G SD-CORE.  To install the ROC to
configure the 4G SD-CORE::

    make roc-4g-models

To install the ROC to configure the 5G SD-CORE::

    make roc-5g-models

By default the above commands install the ROC from the local charts in the Git repos cloned
earlier.  In order to install the ROC using the latest published charts, add *CHARTS=latest*
to the command, e.g.,::

    CHARTS=latest make roc-4g-models

To install the Aether 2.0 release, add *CHARTS=release-2.0*::

    CHARTS=release-2.0 make roc-4g-models

The ROC has successfully initialized when you see output like this::

    echo "ONOS CLI pod: pod/onos-cli-5b947f8f6-4r5nm"
    ONOS CLI pod: pod/onos-cli-5b947f8f6-4r5nm
    until kubectl -n aether-roc exec pod/onos-cli-5b947f8f6-4r5nm -- \
        curl -s -f -L -X PATCH "http://aether-roc-api:8181/aether-roc-api" \
        --header 'Content-Type: application/json' \
        --data-raw "$(cat /root/aether-in-a-box//roc-5g-models.json)"; do sleep 5; done
    command terminated with exit code 22
    command terminated with exit code 22
    command terminated with exit code 22
    "9513ea10-883d-11ec-84bf-721e388172cd"

Don't worry if you see a few lines of *command terminated with exit code 22*; that command is trying to
load the ROC models, and the message appears if the ROC isn't ready yet.  However if you see that message
more than 10 times then something is probably wrong with the ROC or its models.

Start the 4G SD-CORE
--------------------

If you are installing the 5G SD-CORE, you can skip this step.

To deploy the 4G SD-CORE and run a simple ping test::

    make test

By default the above commands install the 4G SD-CORE from the local charts in the Git repos cloned
earlier.  In order to install the SD-CORE using the latest published charts, add *CHARTS=latest*
to the command, e.g.,::

    CHARTS=latest make test

To install the Aether 2.0 release, add *CHARTS=release-2.0*::

    CHARTS=release-2.0 make test

Start the 5G SD-CORE
--------------------

If you have already installed the 4G SD-CORE, you must skip this step.  Only one version of
the SD-CORE can be installed at a time.

To deploy the 5G SD-CORE and run a test with gNBSim that performs Registration + UE-initiated
PDU Session Establishment + sends User Data packets::

    make 5g-test

By default the above commands install the 5G SD-CORE from the local charts in the Git repos cloned
earlier.  In order to install the SD-CORE using the latest published charts, add *CHARTS=latest*
to the command, e.g.,::

    CHARTS=latest make 5g-test

To install the Aether 2.0 release, add *CHARTS=release-2.0*::

    CHARTS=release-2.0 make 5g-test

To change the behavior of the test run by gNBSim, change the contents of *gnb.conf*
in *sd-core-5g-values.yaml*.  Consult the
`gNBSim documentation <https://docs.sd-core.opennetworking.org/master/developer/gnbsim.html>`_ for more information.

Exploring AiaB
--------------

The *kubectl* tool is the best way to get familiar with the pods and other Kubernetes objects installed by AiaB.
The SD-CORE services, UPF, and simulated edge devices run in the *omec* namespace, while the ROC is running
in the *aether-roc* namespace.

The ROC GUI is available on port 31194 on the host running AiaB.

Cleanup
-------

The first time you build AiaB, it takes a while because it sets up the Kubernetes cluster.
Subsequent builds will be much faster if you follow these steps to clean up the Helm charts without
destroying the Kubernetes cluster.

* Clean up the 4G SD-CORE: *make reset-test*
* Reset the 4G UE / eNB in order to re-run the 4G test: *make reset-ue*
* Clean up the 5G SD-CORE: *make reset-5g-test*
* Clean up the ROC: *make roc-clean*

It's normal for the above commands to take a minute or two to complete.

As an example, suppose that you want to test the 4G SD-CORE with the ROC, and then the 5G SD-CORE
with the ROC.  You could run these commands::

    CHARTS=latest make roc-4g-models   # Install ROC with 4G configuration
    CHARTS=latest make test            # Install 4G SD-CORE and run ping test
    make reset-test
    make roc-clean
    CHARTS=latest make roc-5g-models   # Install ROC with 5G configuration
    CHARTS=latest make 5g-test         # Install 5G SD-CORE and run gNB Sim test
    make reset-5g-test
    make roc-clean

To completely remove AiaB by tearing down the Kubernetes cluster, run *make clean*.

Developer Loop
--------------

Suppose you wish to test a new build of a 5G SD-CORE services. You can deploy custom images
by editing `~/aether-in-a-box/sd-core-5g-values.yaml`, for example::

    omec-control-plane:
        images:
            tags:
                webui: registry.aetherproject.org/omecproject/5gc-webui:onf-release3.0.5-roc-935305f
            pullPolicy: IfNotPresent

To upgrade a running 5G SD-CORE with the new image, or to deploy the 5G SD-CORE with the image::

    make reset-5g-test; make 5g-test

Troubleshooting / Known Issues
------------------------------

If you suspect a problem, first verify that all pods are in Running state::

    kubectl -n omec get pods
    kubectl -n aether-roc get pods

4G Test Fails
^^^^^^^^^^^^^
Occasionally *make test* (for 4G) fails for unknown reasons; this is true regardless of which Helm charts are used.
If this happens, first try recreating the simulated UE / eNB and re-running the test as follows::

    make reset-ue
    make test

If that does not work, try cleaning up AiaB as described above and re-building it.

If *make test* fails consistently, check whether the configuration has been pushed to the SD-CORE::

    kubectl -n omec logs config4g-0 | grep "Successfully"

You should see that a device group and slice has been pushed::

    [INFO][WebUI][CONFIG] Successfully posted message for device group 4g-oaisim-user to main config thread
    [INFO][WebUI][CONFIG] Successfully posted message for slice default to main config thread

Then tail the *config4g-0* log and make sure that the configuration has been successfully pushed to all
SD-CORE components.

5G Test Fails
^^^^^^^^^^^^^

If the 5G test fails (*make 5g-test*) then you will see output like this::

    2022-04-21T17:59:12Z [INFO][GNBSIM][Summary] Profile Name: profile2 , Profile Type: pdusessest
    2022-04-21T17:59:12Z [INFO][GNBSIM][Summary] Ue's Passed: 2 , Ue's Failed: 3
    2022-04-21T17:59:12Z [INFO][GNBSIM][Summary] Profile Errors:
    2022-04-21T17:59:12Z [ERRO][GNBSIM][Summary] imsi:imsi-208930100007492, procedure:REGISTRATION-PROCEDURE, error:triggering event:REGESTRATION-REQUEST-EVENT, expected event:AUTHENTICATION-REQUEST-EVENT, received event:REGESTRATION-REJECT-EVENT
    2022-04-21T17:59:12Z [ERRO][GNBSIM][Summary] imsi:imsi-208930100007493, procedure:REGISTRATION-PROCEDURE, error:triggering event:REGESTRATION-REQUEST-EVENT, expected event:AUTHENTICATION-REQUEST-EVENT, received event:REGESTRATION-REJECT-EVENT
    2022-04-21T17:59:12Z [ERRO][GNBSIM][Summary] imsi:imsi-208930100007494, procedure:REGISTRATION-PROCEDURE, error:triggering event:REGESTRATION-REQUEST-EVENT, expected event:AUTHENTICATION-REQUEST-EVENT, received event:REGESTRATION-REJECT-EVENT
    2022-04-21T17:59:12Z [INFO][GNBSIM][Summary] Simulation Result: FAIL

In this case check whether the *webui* pod has restarted... this can happen if it times out waiting
for the database to come up::

    $ kubectl -n omec get pod -l app=webui
    NAME                     READY   STATUS    RESTARTS        AGE
    webui-6b9c957565-zjqls   1/1     Running   1 (6m55s ago)   7m56s

If the output shows any restarts, then restart the *simapp* pod to cause it to re-push its subscriber state::

    $ kubectl -n omec delete pod -l app=simapp
    pod "simapp-6c49b87c96-hpf82" deleted

Re-run the 5G test, it should now pass.
