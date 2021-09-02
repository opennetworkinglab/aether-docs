Aether Documentation
====================

Aether is an ONF's 5G/LTE Connected Edge Platform-as-a-Service.  More
information about Aether can be found at the `ONF website
<https://opennetworking.org/aether/>`_.


Getting Started with Aether
---------------------------

Here are some useful places to start with Aether:

* Read the most recent :doc:`Release Notes </release/1.5>`.

* Learn the requirements of hosting an :doc:`Aether Connected Edge
  </edge_deployment/overview>`.

* Learn about the :doc:`Aether Managemnt Platform </amp/roc>`.

* Setup an Aether software development environment with :doc:`Aether-in-a-Box
  </developer/aiab>`.

Aether Architecture and Components
----------------------------------

Aether uses components from several ONF projects. More information can be found
at these sites:

* `SD-Core <https://opennetworking.org/sd-core/>`_
* `SD-Fabric <https://opennetworking.org/sd-fabric/>`_
* `SD-RAN <https://docs.sd-ran.org/master/index.html>`_

More information about mobile networks and 5G can be found in the :doc:`5G
Mobile Networks: A Systems Approach <sysapproach5g:intro>` book.

Community
---------

Information about participating in the Aether community and development process
can be found on the `ONF Wiki
<https://wiki.opennetworking.org/display/COM/Aether>`_.

.. toctree::
   :maxdepth: 3
   :caption: Edge Deployment
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
   edge_deployment/troubleshooting
   edge_deployment/pronto

.. toctree::
   :maxdepth: 3
   :caption: Operations
   :hidden:
   :glob:

   operations/procedures
   operations/subscriber
   operations/vcs

.. toctree::
   :maxdepth: 3
   :caption: Aether Management Platform
   :hidden:
   :glob:

   amp/roc
   amp/monitoring

.. toctree::
   :maxdepth: 3
   :caption: Aether Test Automation
   :hidden:
   :glob:

   testing/about_system_tests
   testing/sdcore_testing
   testing/aether-roc-tests
   testing/acceptance_specification

.. toctree::
   :maxdepth: 3
   :caption: Aether Developer Notes
   :hidden:
   :glob:

   developer/aiab
   developer/roc
   developer/roc-api

.. toctree::
   :maxdepth: 2
   :caption: Releases
   :hidden:
   :glob:

   release/1*
   release/process.rst

.. toctree::
   :maxdepth: 1
   :caption: Meta
   :hidden:
   :glob:

   readme
