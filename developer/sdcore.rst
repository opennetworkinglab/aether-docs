.. vim: syntax=rst

Aether SD-Core Developer Guide
==============================

Clone Repositories
------------------

Clone the following repositories, using your gerrit ids as necessary::

    mkdir -p ~/cord    #need to clone below 2 repos in this directory
    git clone "ssh://<username>@gerrit.opencord.org:29418/helm-charts"
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-helm-charts"

    cd ~  #go back to home directory
    git clone "ssh://<username>@gerrit.opencord.org:29418/aether-in-a-box"

Start the 4G Core
-----------------

Deploy Aether-in-a-Box and start the 4G core::

    cd aether-in-a-box

    #create K8s cluster for you and also start 4G network functions and carry out 1 ping test
    make test

Apply the necessary pull secrets
--------------------------------

The deployment may fail and leave pods in ImagePullBackoff status if the
necessary secrets are not applied.
Obtain the secret from ONF, and then execute the following::

    cat > ~/registry-secret.json
         ... paste the secret here ...
    kubectl apply -f ~/registry-secret.json



Transition from 4G Core to 5G Core
----------------------------------

Before starting the 5G core, the 4G Core must be stopped::

    make reset-test  #this does not destroy K8s cluster.

Now, start the 5G Core::

    make 5gc  #this will start all 5G network functions with default images.

    kubectl get pods -n omec #verify that all 5g pods are started.

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
    ue-setup-if-mftrm          0/1     Completed   0          23d
    ue-teardown-if-whbvm       0/1     Completed   0          23d
    upf-0                      4/4     Running     0          55s
    webui-79c8b7dfc7-wn6st     1/1     Running     0          41s

Developer Loop
--------------

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
