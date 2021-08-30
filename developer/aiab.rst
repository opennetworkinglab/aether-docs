.. vim: syntax=rst

Setting Up Aether-in-a-Box
==========================

Aether-in-a-Box (AiaB) provides an easy way to deploy the Aether software stack and
run basic tests.  This guide describes the steps to set up AiaB.

AiaB can be run on a bare metal machine or VM.  Prerequisites:

* Ubuntu 18.04
* Kernel 4.15 or later
* Haswell CPU or newer

Clone Repositories
------------------

Clone the following repositories, using your gerrit ids as necessary::

    mkdir -p ~/cord    # need to clone below 2 repos in this directory
    git clone "ssh://<username>@gerrit.opencord.org:29418/helm-charts"
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-helm-charts"

    cd ~  # go back to home directory
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-in-a-box"

Set up Authentication Tokens
----------------------------

Edit the file *aether-in-a-box/configs/authentication*.

Fill out REGISTRY_USERNAME and REGISTRY_CLI_SECRET as follows:

* Log into the `Aether Harbor Registry <https://registry.aetherproject.org>`_ using your Crowd credentials
* Select *User Profile* from the drop-down menu in the upper right corner
* For REGISTRY_USERNAME, use the *Username* in your profile
* Copy the *CLI secret* to the clipboard and paste to REGISTRY_CLI_SECRET

If you want to install using Aether's published Helm charts rather than the local charts
checked out in the previous step, fill out REPO_USERNAME and REPO_PASSWORD with the
information needed to authenticate with Aether's Helm chart repository.  This step is optional.

Start the 4G Core
-----------------

Deploy Aether-in-a-Box and start the 4G core::

    cd aether-in-a-box

    make test  # create K8s cluster, start 4G network functions, and run ping test

By default, the installation uses the local charts that were checked out earlier.  However the
files in the *configs/* directory can be used to install AiaB using charts published to the Aether Helm
chart repository.  For example, the file *configs/rc-1.5* can be used to install the Aether 1.5 release candidate.
To install AiaB using the chart versions specified in this file, set the *CHARTS* variable when invoking *make*::

    CHARTS=rc-1.5 make test

Once you are done with the test, stop the 4G Core as follows::

    make reset-test  # this does not destroy K8s cluster

Start the 5G Core
-----------------

Deploy Aether-in-a-Box and start the 5G core::

    cd aether-in-a-box

    make 5gc  # start all 5G network functions with default images

    kubectl get pods -n omec # verify that all 5g pods are started

Sample output::

    NAME                       READY   STATUS      RESTARTS   AGE
    amf-7d6f649b4f-jzd9r       1/1     Running     0          41s
    ausf-8dd5d7465-xrjdl       1/1     Running     0          41s
    gnbsim-0                   1/1     Running     0          25s
    mongodb-55555bc884-wqcrh   1/1     Running     0          41s
    nrf-ddd7d8d5b-vjv84        1/1     Running     0          41s
    nssf-7978bb74cc-zct9v      1/1     Running     0          41s
    pcf-5bbbff96d6-l54f6       1/1     Running     0          41s
    smf-86b6fd5674-tq8h9       1/1     Running     0          41s
    udm-5fdf9cf56d-76hlt       1/1     Running     0          41s
    udr-d8f855c6b-jj8lw        1/1     Running     0          41s
    upf-0                      4/4     Running     0          55s
    webui-79c8b7dfc7-wn6st     1/1     Running     0          41s

You can use *gnbsim* to test 5G functionality.  For example, to run the 5G user registration::

    kubectl -n omec exec gnbsim-0 -- /go/src/gnbsim/gnbsim register


SD-CORE Developer Loop
----------------------

Tips for SD-CORE developers:

Deploy custom images by editing `~/aether-in-a-box/aether-in-a-box-values.yaml`::

    images:
        tags:
            webui: registry.aetherproject.org/omecproject/5gc-webui:onf-release3.0.5-roc-935305f
        pullPolicy: IfNotPresent
        pullSecrets:
            - name: "aether.registry"

Stop the 5G Core and start it again::

    make reset-5g-test
    make 5gc
