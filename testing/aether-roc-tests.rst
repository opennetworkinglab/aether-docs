Instructions For Running The ROC Tests
======================================

The REST API and the GUI of the Aether ROC is tested utilizing the Robot Framework.
The tests are located inside the aether-system-tests repository and they are run nightly using
a Jenkins job.

Development Prerequisites
-------------------------
To access the ROC from a local system, it is necessary to deploy the components of µONOS.
This can be done with the use of Helm (see instructions on
`this page <https://docs.onosproject.org/onos-docs/docs/content/developers/deploy_with_helm/>`_).

Additionally, it is necessary to add the sdran chart repo with the following command:

.. code-block:: shell

    helm repo add sdran --username USER --password PASSWORD https://sdrancharts.onosproject.org

where USER and PASSWORD can be obtained from the Aether Login Information file, which is
accessibble to the ``onfstaff`` group.

Finally, the ROC GUI tests are running on the Firefox browser, so it is nesessary to have the Firefox browser and the
Firefox web driver (geckodriver) installed on the system in order to run these tests.

Running the ROC API tests
-------------------------
Follow the steps below to access the ROC API:

1. Deploy the aether-roc-umbrella chart from the sdran repo with the following command:

.. code-block:: shell

    helm -n micro-onos install aether-roc-umbrella sdran/aether-roc-umbrella

2. Check if all pods are in a Running state:

.. code-block:: shell

    kubectl -n micro-onos get pods

This should print a table like the one below:

.. code-block:: shell

    NAME                                                           READY   STATUS    RESTARTS   AGE
    aether-roc-api-df499d585-7xmt5                                 2/2     Running   0          2m52s
    aether-roc-gui-56bfb5fc67-sgxh7                                1/1     Running   0          2m52s
    aether-roc-umbrella-grafana-6b4d4b55c-4mdww                    1/1     Running   0          2m52s
    aether-roc-umbrella-prometheus-alertmanager-694c449885-8fsbs   2/2     Running   0          2m52s
    aether-roc-umbrella-prometheus-server-59c974f84-d56td          2/2     Running   0          2m52s
    aether-roc-umbrella-sdcore-test-dummy-7f4895c59c-4pvdg         1/1     Running   0          2m52s
    onos-cli-846d9c8df6-njqgs                                      1/1     Running   0          2m52s
    onos-config-759fff55f-k9fzr                                    5/5     Running   0          2m52s
    onos-consensus-store-1-0                                       1/1     Running   0          2m50s
    onos-topo-56b687f77b-9l8ns                                     3/3     Running   0          2m52s
    sdcore-adapter-v21-5688b8d458-5sn67                            1/1     Running   0          2m52s
    sdcore-adapter-v3-56667fd848-9szt5                             2/2     Running   0          2m52s


3. Once all pods are in a Running state, port-forward to port 8181 with the following command:

.. code-block:: shell

    kubectl -n micro-onos port-forward $(kubectl -n micro-onos get pods -l type=api -o name) 8181


Now that we have access to the ROC API, we can proceed with running the ROC API tests from the ``aether-system-tests``
repository:

1. Checkout the aether-system-tests repo:

.. code-block:: shell

    git clone "ssh://$GIT_USER@gerrit.opencord.org:29418/aether-system-tests"

2. Go to the repo directory:

.. code-block:: shell

    cd aether-system-tests

3. Install the requirements and create a virtual environment:

.. code-block:: shell

    make ast-venv
    source ast-venv/bin/activate

4. Go to the ``roc`` folder and generate the ROC API test framework and test files:

.. code-block:: shell

    cd roc
    python libraries/api/codegen/class_generator.py \
    --models=variables/3_0_0_model_list.json \
    --template=libraries/api/codegen/templates/class_template.py.tmpl \
    --common_files_directory=libraries/api/codegen/common \
    --target_directory=libraries/api/
    python tests/api/codegen/tests_generator.py \
    --models=variables/3_0_0_model_list.json \
    --template=tests/api/codegen/templates/tests_template.robot.tmpl \
    --target_directory=tests/api

5. Go to the directory that contains the test files:

.. code-block:: shell

    cd tests/api/3_0_0

6. Create a folder for the logs and the output files from the tests:

.. code-block:: shell

    mkdir results

7. Run any Robot Framework test file from the ``3_0_0`` directory.
Each test file corresponds to one of the Aether 3.0.0 models.

.. code-block:: shell

    robot -d results <model-name>.robot

This will generate test reports and logs in the ``results`` directory.

Running the ROC GUI tests
-------------------------
We are testing the ROC GUI by installing the ROC on a local dex server. To install the dex server, please follow
the steps under the "Helm install" section of the Readme file in `this repository <https://github.com/onosproject/onos-helm-charts/tree/master/dex-ldap-umbrella>`_.

Once that you have installed the ``dex-ldap-umbrella`` chart, follow the steps below to install the ROC
on a local dex server:

1. Deploy the aether-roc-umbrella chart from the sdran repo with the following command:

.. code-block:: shell

    helm -n micro-onos install aether-roc-umbrella sdran/aether-roc-umbrella --set onos-config.openidc.issuer=http://dex-ldap-umbrella:5556 --set aether-roc-gui-v3.openidc.issuer=http://dex-ldap-umbrella:5556 --set import.sdcore-adapter.v2_1.enabled=false

2. Check if all pods are in a Running state:

.. code-block:: shell

    kubectl -n micro-onos get pods

This should print a table like the one below:

.. code-block:: shell

    NAME                                                           READY   STATUS    RESTARTS   AGE
    aether-roc-api-df499d585-srf4c                                 2/2     Running   0          3m36s
    aether-roc-gui-799d57456-smx6r                                 1/1     Running   0          3m36s
    aether-roc-umbrella-grafana-55cccb986c-t47gz                   1/1     Running   0          3m37s
    aether-roc-umbrella-prometheus-alertmanager-694c449885-rk47g   2/2     Running   0          3m36s
    aether-roc-umbrella-prometheus-server-59c974f84-97z5t          2/2     Running   0          3m36s
    aether-roc-umbrella-sdcore-test-dummy-7f4895c59c-cv6j7         1/1     Running   0          3m36s
    dex-ldap-umbrella-75bbc9d676-wfvcb                             1/1     Running   0          8m36s
    dex-ldap-umbrella-openldap-fc47667c8-9s7q4                     1/1     Running   0          8m36s
    dex-ldap-umbrella-phpldapadmin-b899f9966-rzwkr                 1/1     Running   0          8m36s
    onos-cli-846d9c8df6-kf2xk                                      1/1     Running   0          3m37s
    onos-config-5568487f84-dwfs8                                   5/5     Running   0          3m37s
    onos-consensus-store-1-0                                       1/1     Running   0          3m35s
    onos-topo-56b687f77b-vb2sx                                     3/3     Running   0          3m36s
    sdcore-adapter-v3-56667fd848-g7dh2                             2/2     Running   0          3m37s


3. Once all pods are in a Running state, port-forward to port 8183 to access the ROC GUI:

.. code-block:: shell

    kubectl -n micro-onos port-forward $(kubectl -n micro-onos get pods -l type=arg -o name) 8183:80

3. Port-forward to port 8181 to access the ROC API (which is necessary for some test cases):

.. code-block:: shell

    kubectl -n micro-onos port-forward $(kubectl -n micro-onos get pods -l type=api -o name) 8181

3. Finalluy, port-forward the dex service to port 5556:

.. code-block:: shell

    DEX_POD_NAME=$(kubectl -n micro-onos get pods -l "app.kubernetes.io/name=dex,app.kubernetes.io/instance=dex-ldap-umbrella" -o jsonpath="{.items[0].metadata.name}") &&
    kubectl -n micro-onos port-forward $DEX_POD_NAME 5556:5556

Now that we have access to the ROC API and GUI, we can proceed with running the ROC GUI tests from the
``aether-system-tests`` repository:

1. Checkout the aether-system-tests repo:

.. code-block:: shell

    git clone "ssh://$GIT_USER@gerrit.opencord.org:29418/aether-system-tests"

2. Go to the repo directory:

.. code-block:: shell

    cd aether-system-tests

3. Install the requirements and create a virtual environment:

.. code-block:: shell

    make ast-venv
    source ast-venv/bin/activate

4. Go to the ``roc`` folder and generate the ROC GUI test files:

.. code-block:: shell

    cd roc
    python tests/gui/codegen/tests_generator.py \
    --models=variables/3_0_0_model_list.json \
    --template=tests/gui/codegen/templates/tests_template.robot.tmpl \
    --target_directory=tests/gui

5. Go to the directory that contains the test files:

.. code-block:: shell

    cd tests/gui/3_0_0

6. Create a folder for the logs and the output files from the tests:

.. code-block:: shell

    mkdir results

7. Run any Robot Framework test file from the ``3_0_0`` directory.
Each test file corresponds to one of the Aether 3.0.0 models.

.. code-block:: shell

    robot -d results <model-name>.robot

| This will generate test reports and logs in the ``results`` directory.
