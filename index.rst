Aether Documentation
====================

Aether is an ONF's 5G/LTE Connected Edge Platform-as-a-Service.  More
information about Aether can be found at the `ONF website
<https://opennetworking.org/aether/>`_.


Getting Started with Aether
---------------------------

Here are some useful places to start with Aether:

* Deploy and operate Aether on your own cluster with :doc:`Aether OnRamp </onramp/overview>`.

* Setup an Aether software development environment with :doc:`Aether-in-a-Box </developer/aiab>`.

* Learn about how to :doc:`configure Aether using the ROC </operations/gui>`.

* Learn the requirements of hosting an :doc:`Aether Connected Edge
  </edge_deployment/overview>`.

* Read the most recent :doc:`Release Notes </release/2.1>`.

Aether Architecture and Components
----------------------------------

Aether uses components from several ONF projects. More information can be found
at these sites:

* SD-Core

  * `SD-Core Website <https://opennetworking.org/sd-core/>`_
  * :doc:`SD-Core Documentation <sdcore:index>`

* SD-Fabric

  * `SD-Fabric Website <https://opennetworking.org/sd-fabric/>`_
  * :doc:`SD-Fabric Documentation <sdfabric:index>`

* SD-RAN

  * `SD-RAN Website <https://opennetworking.org/open-ran/>`_
  * :doc:`SD-RAN Documentation <sdran:index>`

More information about 5G and Aether's architecture can be found in
the :doc:`Private 5G: A Systems Approach <sysapproach5g:index>` book.

Community
---------

Information about participating in the Aether community and development process
can be found on the `ONF Wiki
<https://wiki.opennetworking.org/display/COM/Aether>`_.

.. toctree::
   :maxdepth: 3
   :caption: Aether OnRamp
   :hidden:
   :glob:

   onramp/overview
   onramp/directory
   onramp/start
   onramp/inspect
   onramp/scale
   onramp/network
   onramp/gnbsim
   onramp/gnb
   onramp/roc
   onramp/enb

.. toctree::
   :maxdepth: 3
   :caption: Aether-in-a-Box
   :hidden:
   :glob:

   developer/aiab
   developer/aiabhw
   developer/aiabhw5g
   developer/troubleshooting
   developer/contributing.rst

.. toctree::
   :maxdepth: 3
   :caption: Operations
   :hidden:
   :glob:

   operations/gui
   operations/subscriber
   operations/application
   operations/slice
   operations/metering
   operations/monitor
   operations/procedures

.. toctree::
   :maxdepth: 3
   :caption: Production Edge Deployment
   :hidden:
   :glob:

   edge_deployment/overview
   edge_deployment/site_planning
   edge_deployment/management_net_bootstrap
   edge_deployment/server_bootstrap
   edge_deployment/fabric_switch_bootstrap
   edge_deployment/vpn_bootstrap
   edge_deployment/runtime_deployment
   edge_deployment/bess_upf_deployment
   edge_deployment/sdfabric_deployment
   edge_deployment/connectivity_service_update
   edge_deployment/enb_installation
   edge_deployment/site_remove
   edge_deployment/troubleshooting
   edge_deployment/pronto

.. toctree::
   :maxdepth: 3
   :caption: Aether Management Platform
   :hidden:
   :glob:

   amp/roc
   amp/subproxy
   amp/monitoring

.. toctree::
   :maxdepth: 3
   :caption: ROC Development
   :hidden:
   :glob:

   developer/roc
   developer/roc-api

.. toctree::
   :maxdepth: 3
   :caption: Aether Test Automation
   :hidden:
   :glob:

   testing/about_system_tests
   testing/aether-roc-tests
   testing/system-tests
   testing/acceptance_specification

.. toctree::
   :maxdepth: 2
   :caption: Releases
   :hidden:
   :glob:

   release/1*
   release/2*
   release/process.rst
