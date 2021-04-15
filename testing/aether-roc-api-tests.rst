==========================================
Instructions For Running The ROC API Tests
==========================================

The REST API of the Aether ROC is tested utilizing the Robot Framework.
The tests are located inside the aether-system-tests repository and they are run nightly using
Jenkins job.

Development Prerequisites
^^^^^^^^^^^^^^^^^^^^^^^^^
To access the ROC API from a local system, it is necessary to deploy the components of µONOS.
This can be done with the use of Helm (see instructions on
`this page <https://docs.onosproject.org/onos-docs/docs/content/developers/deploy_with_helm/>`_).

| Additionally, it is necessary to add the sdran chart repo with the following command:
| ``helm repo add sdran --username USER --password PASSWORD https://sdrancharts.onosproject.org``
| , where USER and PASSWORD can be obtained from the Aether Login Information file, which is
| accessibble to the ``onfstaff`` group.

Access the ROC API
^^^^^^^^^^^^^^^^^^
Follow the steps below to access the ROC API:

| 1. Deploy the aether-roc-umbrella chart from the sdran repo with the following command:
| ``helm -n micro-onos install aether-roc-umbrella sdran/aether-roc-umbrella``
| 2. Check if all pods are in a Running state with the command ``kubectl -n micro-onos get pods``
| This should give a list like:


+---------------------------------+-------+---------+----------+-----+
| NAME                            | READY |  STATUS | RESTARTS | AGE |
+---------------------------------+-------+---------+----------+-----+
| aether-roc-api-56f54d69d4-b4mkk | 1/1   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| aether-roc-gui-75d6bf95d7-998bg | 1/1   | Running | 0        | 47s |
+---------------------------------+-------+---------+----------+-----+
| onos-cli-77d589f9c7-7jzcl       | 1/1   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| onos-config-6646dcb964-kslbs    | 2/2   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| onos-consensus-db-1-0           | 1/1   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| onos-gui-dfd58b788-bkj6l        | 2/2   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| onos-topo-6948484f46-6m6fg      | 1/1   | Running | 0        | 46s |
+---------------------------------+-------+---------+----------+-----+
| sdcore-adapter-69bff5fc45-79pld | 1/1   | Running | 0        | 47s |
+---------------------------------+-------+---------+----------+-----+

| 3. Once all pods are in a Running state, port-forward to port 8181 with the following command:
| ``kubectl -n micro-onos port-forward $(kubectl -n micro-onos get pods -l type=api -o name) 8181``

Running the tests
^^^^^^^^^^^^^^^^^
| 1. Checkout the aether-system-tests repo:
| ``git clone "ssh://$GIT_USER@gerrit.opencord.org:29418/aether-system-tests"``
| 2. Go to the repo directory:
| ``cd aether-system-tests``
| 3. Install the requirements:
| ``make ast-venv``
| 4. The ROC API test files are located inside the ``tests/roc/api`` directory. There is a test file
| for each of the API end points. For example, we can run the test file for ``access-profile`` with
| the following command:
| ``robot tests/roc/api/access-profile.robot``
| This will generate test reports and logs in the current directory.
