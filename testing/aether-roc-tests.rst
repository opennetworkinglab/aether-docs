API Tests
===========

The REST API and GUI of Aether is tested with the Robot Framework.
The tests are located inside the ``aether-system-tests`` repository
and they are run nightly using a Jenkins job.

Development Prerequisites
-------------------------
To access the ROC from a local system, it is necessary to deploy the components of µONOS.
This can be done with the use of Helm (see instructions on
`this page <https://docs.onosproject.org/onos-docs/docs/content/developers/deploy_with_helm/>`_).

Additionally, it is necessary to add the SD-RAN chart repo with the following command:

.. code-block:: shell

    helm repo add sdran --username USER --password PASSWORD https://charts.aetherproject.org

where USER and PASSWORD can be obtained from the Aether Login Information file,
which is accessible to the ``onfstaff`` group.

Finally, the ROC GUI tests are running on the Firefox browser, so it is
necessary to have the Firefox browser and the Firefox web driver
(``geckodriver``) installed on the system in order to run these tests.

Running the ROC API Tests
-------------------------
Follow the steps below to access the ROC API:

1. Deploy the ``aether-roc-umbrella`` chart from the Aether repo with the following command:

.. code-block:: shell

    helm -n micro-onos install aether-roc-umbrella aether/aether-roc-umbrella

2. Check if all pods are in a Running state:

.. code-block:: shell

    kubectl -n micro-onos get pods

3. Once all pods are in a Running state, port-forward aether-roc-api to port 8181 with the following command:

.. code-block:: shell

    kubectl -n micro-onos port-forward service/aether-roc-api 8181 &

4. Port-forward onos-config to port 5150 with the following command:

.. code-block:: shell

    kubectl -n micro-onos port-forward service/onos-config 5150 &

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
    --models=variables/2_0_0_model_list.json \
    --template=libraries/api/codegen/templates/class_template.py.tmpl \
    --common_files_directory=libraries/api/codegen/common \
    --target_directory=libraries/api/
    python tests/api/codegen/tests_generator.py \
    --models=variables/2_0_0_model_list.json \
    --template=tests/api/codegen/templates/tests_template.robot.tmpl \
    --target_directory=tests/api

5. Go to the directory that contains the test files:

.. code-block:: shell

    cd tests/api/2_0_0

6. Create a folder for the logs and the output files from the tests:

.. code-block:: shell

    mkdir results

7. Run any Robot Framework test file from the ``2_0_0`` directory.
Each test file corresponds to one of the Aether 2.0.0 models.

.. code-block:: shell

    robot -d results <model-name>.robot

This will generate test reports and logs in the ``results`` directory.

Running the ROC GUI Tests
-------------------------

We test the ROC GUI by installing the ROC with keycloak-dev.onlab.us.
Currently, only v4 GUI automation tests are supported:

1. Deploy the ``aether-roc-umbrella`` chart from the Aether repo with the
   following command:

.. code-block:: shell

    helm -n micro-onos install aether-roc-umbrella aether/aether-roc-umbrella \
    --set import.sdcore-adapter.v4.enabled=true \
    --set import.aether-roc-gui.v4.enabled=true \
    --set onos-config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set aether-roc-api.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set aether-roc-gui-v4.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set prom-label-proxy-acc.config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set prom-label-proxy-amp.config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master

Alternatively, v2 GUI can be deployed with the following command:

.. code-block:: shell

    helm -n micro-onos install aether-roc-umbrella aether/aether-roc-umbrella \
    --set onos-config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set aether-roc-api.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set aether-roc-gui-v2.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set prom-label-proxy-acc.config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master \
    --set prom-label-proxy-amp.config.openidc.issuer=https://keycloak-dev.onlab.us/auth/realms/master

2. Check if all pods are in a Running state:

.. code-block:: shell

    kubectl -n micro-onos get pods

3. Once all pods are in a Running state, port-forward to port 8183 to access the ROC GUI:

.. code-block:: shell

    kubectl -n micro-onos port-forward service/aether-roc-gui-v4 8183:80 &

4. Port-forward to port 8181 to access the ROC API (which is necessary for some test cases):

.. code-block:: shell

    kubectl -n micro-onos port-forward service/aether-roc-api 8181 &

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
    --models=variables/4_0_0_model_list.json \
    --template=tests/gui/codegen/templates/tests_template.robot.tmpl \
    --target_directory=tests/gui

5. Go to the directory that contains the test files:

.. code-block:: shell

    cd tests/gui/4_0_0

6. Create a folder for the logs and the output files from the tests:

.. code-block:: shell

    mkdir results

7. Run any Robot Framework test file from the ``4_0_0`` directory.  Each test
   file corresponds to one of the Aether 4.0.0 models.

.. code-block:: shell

    robot -d results <model-name>.robot

This will generate test reports and logs in the ``results`` directory.
