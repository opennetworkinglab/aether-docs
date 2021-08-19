Aether Documentation
====================

Aether is an ONF's 5G/LTE Connected Edge Platform-as-a-Service.  More
information about Aether can be found at the `ONF website
<https://opennetworking.org/aether/>`_.

Aether Components
-----------------

Aether uses components from several ONF projects. More information can be found
at these sites:

* `SD-Core <https://opennetworking.org/sd-core/>`_
* :doc:`SD-Fabric (Trellis) <trellis:index>`
* `SD-RAN <https://docs.sd-ran.org/master/index.html>`_
* `Stratum <https://github.com/stratum/stratum/>`_
* `µONOS <https://docs.onosproject.org/>`_

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
   testing/fabric_testing
   testing/pdp_testing

.. toctree::
   :maxdepth: 3
   :caption: Aether Developer Notes
   :hidden:
   :glob:

   developer/sdcore
   developer/roc
   developer/roc-api

.. toctree::
   :maxdepth: 2
   :caption: Releases
   :hidden:
   :glob:

   release/process.rst
   release/1*

.. toctree::
   :maxdepth: 1
   :caption: Meta
   :hidden:
   :glob:

   readme
