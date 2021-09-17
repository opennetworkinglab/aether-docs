.. vim: syntax=rst

Setting Up Aether-in-a-Box
==========================

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

* Ubuntu 18.04
* Kernel 4.15 or later
* Haswell CPU or newer

Clone Repositories
------------------

To initialize the AiaB environment, first clone the following repository
using your Gerrit ID::

    cd ~
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-in-a-box"

If you are going to install AiaB using published Helm charts, you can proceed to the
next section.

If you wish to install SD-CORE from local Helm charts, clone these additional repositories::

    mkdir -p ~/cord
    cd ~/cord
    git clone "ssh://<username>@gerrit.opencord.org:29418/helm-charts"
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-helm-charts"

If you wish to install the ROC from local Helm charts, clone these::

    mkdir -p ~/cord
    cd ~/cord
    git clone https://github.com/atomix/atomix-helm-charts.git
    git clone https://github.com/onosproject/onos-helm-charts.git
    git clone https://github.com/onosproject/sdran-helm-charts.git  # Private repo

Now change to *~/aether-in-a-box* directory.

Set up Authentication Tokens
----------------------------

Edit the file *configs/authentication*.

Fill out REGISTRY_USERNAME and REGISTRY_CLI_SECRET as follows:

* Log into the `Aether Harbor Registry <https://registry.aetherproject.org>`_ using your Crowd credentials
* Select *User Profile* from the drop-down menu in the upper right corner
* For REGISTRY_USERNAME, use the *Username* in your profile
* Copy the *CLI secret* to the clipboard and paste to REGISTRY_CLI_SECRET

If you wish to install SD-CORE using Aether's published Helm charts, or if you are installing the ROC, also
fill out REPO_USERNAME and REPO_PASSWORD with the information needed to authenticate with Aether's Helm
chart repository.

If you have already set up AiaB but you used incorrect credentials, first clean up AiaB as described
in the `Cleanup`_ section, then edit *configs/authentication* and re-build AiaB.

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

To install the Aether 1.5 release candidate version, add *CHARTS=rc-1.5*::

    CHARTS=rc-1.5 make roc-4g-models

Start the 4G SD-CORE
--------------------

If you are installing the 5G SD-CORE, you can skip this step.

To deploy the 4G SD-CORE and run a simple ping test::

    make test

By default the above commands install the 4G SD-CORE from the local charts in the Git repos cloned
earlier.  In order to install the SD-CORE using the latest published charts, add *CHARTS=latest*
to the command, e.g.,::

    CHARTS=latest make test

To install the Aether 1.5 release candidate version, add *CHARTS=rc-1.5*::

    CHARTS=rc-1.5 make test

Start the 5G SD-CORE
--------------------

If you have already installed the 4G SD-CORE, you must skip this step.  Only one version of
the SD-CORE can be installed at a time.

To deploy the 5G SD-CORE::

    make 5gc

By default the above commands install the 5G SD-CORE from the local charts in the Git repos cloned
earlier.  In order to install the SD-CORE using the latest published charts, add *CHARTS=latest*
to the command, e.g.,::

    CHARTS=latest make 5gc

To install the Aether 1.5 release candidate version, add *CHARTS=rc-1.5*::

    CHARTS=rc-1.5 make 5gc

You can use *gnbsim* to test 5G functionality.  For example, to run the 5G user registration::

    kubectl -n omec exec gnbsim-0 -- /go/src/gnbsim/gnbsim register

Currently there is no ping test for the 5G SD-CORE.

Cleanup
-------

The first time you build AiaB, it takes a while because it sets up the Kubernetes cluster.
Subsequent builds will be much faster if you follow these steps to clean up the Helm charts without
destroying the Kubernetes cluster.

* Clean up the 4G SD-CORE: *make reset-test*
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
    CHARTS=latest make 5gc             # Install 5G SD-CORE
    make reset-5g-test
    make roc-clean

Developer Loop
--------------

Suppose you wish to test a new build of a 5G SD-CORE services. You can deploy custom images
by editing `~/aether-in-a-box/5g-core-values.yaml`, for example::

    images:
        tags:
            webui: registry.aetherproject.org/omecproject/5gc-webui:onf-release3.0.5-roc-935305f
        pullPolicy: IfNotPresent

To upgrade a running 5G SD-CORE with the new image, or to deploy the 5G SD-CORE with the image::

    make 5gc

Troubleshooting / Known Issues
------------------------------

If you suspect a problem, first verify that all pods are in Running state::

    kubectl -n omec get pods
    kubectl -n aether-roc get pods

If the pods are stuck in ImagePullBackOff state, then it's likely an issue with credentials.  See the
`Set up Authentication Tokens`_ section.

4G Test Fails
^^^^^^^^^^^^^
Occasionally *make test* (for 4G) fails for unknown reasons; this is true regardless of which Helm charts are used.
If this happens, first try cleaning up AiaB and re-running the test.  If *make test* fails consistently, check
whether the configuration has been pushed to the SD-CORE::

    kubectl -n omec logs config4g-0 | grep "Successfully"

You should see that a device group and slice has been pushed::

    [INFO][WebUI][CONFIG] Successfully posted message for device group 4g-oaisim-user to main config thread
    [INFO][WebUI][CONFIG] Successfully posted message for slice default to main config thread

Then tail the *config4g-0* log and make sure that the configuration has been successfully pushed to all
SD-CORE components.

5G Test Fails
^^^^^^^^^^^^^
Currently the 5G *gnbsim* does not support data packets, though the UE can successfully register.
For example the *gnbsim register* command gets stuck here::

    ip address in string  172.250.0.1
    err <nil>
    UE address -  172.250.0.1
    Assigned address to UE address  172.250.0.1
    sent message NGAP-PDU Session Resource Setup Response
    Failed to write gtpu packet
    Sent uplink gtpu packet
    Failed to write gtpu packet
    Sent uplink gtpu packet
    Failed to write gtpu packet
    Sent uplink gtpu packet

Fixing this is work-in-progress.
