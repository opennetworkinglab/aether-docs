System Testing
==============

The Aether system is tested using Robot Framework.
The tests are located inside the aether-system-tests repository and they are run nightly using a Jenkins job.

Test Structure
--------------

At a high level, functional tests are ran by:

- Configuring ROC with various slices required for tests using pre-defined input data.
- ROC updates using pre-defined input data with patch updates built with the test framework.
- Control plane and data plane validated using NG40.

5G
---
Functional testing includes multiple slice creations, enable/disable of device groups,
QoS validations, rate limiting tests (at UE, slice, application), application filtering tests, container restart tests.

4G
---
Functional testing includes multiple slice creations, enable/disable of device groups,
QoS validations, rate limiting tests (at UE, slice, application), application filtering tests, container restart tests.

Development Prerequisites
-------------------------

Deploying each component is done with the use of Helm.
Instructions can be found on `this page <https://docs.onosproject.org/onos-docs/docs/content/developers/deploy_with_helm/>`_.

The following steps are needed to deploy the Aether system:

- If applicable, remove ROC, CRDs, and other resources. Fetch Kubernetes config.
- Deploy SD-Core components
- Deploy SD-Fabric components
- Deploy ROC
- Wait for pods to be up
- Sync with SD-Core adapter

Running Tests
-------------

System tests are executed in the following Jenkins views:

`Automated Test Jobs (Nightly) <https://jenkins.aetherproject.org/view/Aether%20System%20Tests/>`_

Tests are executed in the following order after deployment:

- Functional
- Failure/Restart
- Cleanup

Test Setup
----------

.. code-block:: shell

    # Set up virtual environment
    cd aether-system-tests/
    make ast-venv
    source ast-venv/bin/activate; set -u;

Running Tests (4G)
------------------

Functional, Failure/Restart, and Cleanup are executed similarly.
Replace `${TEST_FILE}` with the test file to execute.
This runs all tests in the suite. Add `-i ${TEST_TAG}` to robot arguments to run a specific test case.

.. code-block:: shell

    cd ${WORKSPACE_DIR}
    robot -d ${WORKSPACE_DIR}/${TEST_TYPE}/robotlogs \
        --debugfile ${WORKSPACE_DIR}/functionality/robotlogs/${TEST_FILE}_debug \
        -o ${log_xml} \
        -l ${log_html} \
        -r ${report_html} \
        -e notready \
        -v ACC_CONTEXT:${accContext} \
        -v AMP_CONTEXT:${rocContext} \
        -v ACE_CONTEXT:${aceContext} \
        -v UPF_NAMESPACE:${upfNamespace} \
        -v UPF_NAMESPACE2:${upfNamespace2} \
        -v UPF_NAMESPACE3:${upfNamespace3} \
        -v PFCP_NAMESPACE:${pfcpNamespace} \
        -v CORE_TYPE:${coreType} \
        -v UPF_TYPE:${upfType} \
        -v UPF_TYPE_NAME:${upfTypeName}\
        -v NG40_HOST:${ng40Host} \
        -v NG40_USER:${ng40User} \
        -v NG40RAN_DIR:${ng40RanDir} \
        -v NG40TEST_DIR:${ng40TestDir} \
        -v CSV_DIR:${ng40CsvDir} \
        -v PCAP_DIR:${WORKSPACE_DIR}/functionality/${pcapDir} \
        -v NG40_LOG_DIR:${WORKSPACE_DIR}/functionality/${ng40LogDir} \
        -v CDR_LOG_DIR:${WORKSPACE_DIR}/functionality/${cdrLogDir} \
        -v CONTAINER_LOG_DIR:${WORKSPACE_DIR}/functionality/${containerLogDir} \
        -v POD_NAME:${pod} \
        aether-system-tests/system-tests/tests/4G/functional/${TEST_FILE}.robot || true

Variables
---------

| `${WORKSPACE_DIR}` - Current workspace directory for Aether System Tests. Used for output logs and PCAPs.
| `${TEST_TYPE}` - Directories for logs for each test type Ex: functional, failure, cleanup.
| `${accContext}` - SD-Core context.
| `${rocContext}` - ROC context.
| `${aceContext}` - SD-Fabric and UPF context.
| `${upfNamespace}` - UPF namespace used in tests. Ex: `aether-sdcore-upf1`.
| `${pfcpNamespace}` - PFCP namespace used in tests. Ex: `tost`.
| `${coreType}` - 4G or 5G.
| `${upfType}` - UPF type used in tests. Ex: `bess`. Can also be `${None}` or empty.
| `${upfTypeName}` - UPF type name used in tests.
  This affects which input files are used. Ex: `p4`.
  Can also be `${None}` or empty.
| `${ng40Host}` - IP address for NG40 host.
| `${ng40User}` - NG40 User.
| `${ng40RanDir}` - NG40. RAN directory.
| `${ng40CsvDir}` - NG40 CSV directory.
| `${ng40TestDir}` - NG40 tests directory.
| `${pcapDir}` - Saved PCAP directory.
| `${cdrLogDir}` - NG40 CDR directory.
| `${containerLogDir}` - Log directory for each deployed component.
| `${pod}` - Pod name used in tests. This affects which input files are used. Ex: `qa`, `qa2`.

Running Tests (5G)
------------------
5G tests are executed similar to 4G, except using the tests located in the 5G directory.

.. code-block:: shell

    cd ${WORKSPACE_DIR}
    robot -d ${WORKSPACE_DIR}/${TEST_TYPE}/robotlogs \
        --debugfile ${WORKSPACE_DIR}/functionality/robotlogs/${TEST_FILE}_debug \
        -o ${log_xml} \
        -l ${log_html} \
        -r ${report_html} \
        -e notready \
        -v ACC_CONTEXT:${accContext} \
        -v AMP_CONTEXT:${rocContext} \
        -v ACE_CONTEXT:${aceContext} \
        -v UPF_NAMESPACE:${upfNamespace} \
        -v UPF_NAMESPACE2:${upfNamespace2} \
        -v UPF_NAMESPACE3:${upfNamespace3} \
        -v PFCP_NAMESPACE:${pfcpNamespace} \
        -v CORE_TYPE:${coreType} \
        -v UPF_TYPE:${upfType} \
        -v UPF_TYPE_NAME:${upfTypeName}\
        -v NG40_HOST:${ng40Host} \
        -v NG40_USER:${ng40User} \
        -v NG40RAN_DIR:${ng40RanDir} \
        -v NG40TEST_DIR:${ng40TestDir} \
        -v CSV_DIR:${ng40CsvDir} \
        -v PCAP_DIR:${WORKSPACE_DIR}/functionality/${pcapDir} \
        -v NG40_LOG_DIR:${WORKSPACE_DIR}/functionality/${ng40LogDir} \
        -v CDR_LOG_DIR:${WORKSPACE_DIR}/functionality/${cdrLogDir} \
        -v CONTAINER_LOG_DIR:${WORKSPACE_DIR}/functionality/${containerLogDir} \
        -v POD_NAME:${pod} \
        aether-system-tests/system-tests/tests/5G/functional/${TEST_FILE}.robot || true

