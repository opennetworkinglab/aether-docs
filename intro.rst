Introduction
==============

Aether is an open source 5G edge cloud platform that supports
enterprise deployments of Private 5G. Information about the Aether
project can be found on the ONF website, and an introduction to the
Aether architecture can be found in a companion book:

.. _reading_private5g:
.. admonition:: Further Reading

   `Aether: An ONF Project <https://opennetworking.org/aether/>`_.

   L. Peterson, O. Sunay, and B. Davie. `Private 5G: A Systems
   Approach <https://5g.systemsapproach.org>`__. 2023


Getting Started with Aether
---------------------------

There are two ways to get started with Aether:

* Deploy and operate Aether on your own cluster with :doc:`Aether OnRamp </onramp/overview>`.

* Setup an Aether software development environment with :doc:`Aether-in-a-Box </developer/aiab>`.

Other Aether guides included on this site include:

* :doc:`Runtime Operations </operations/gui>`: Learn how
  to operate Aether's 5G connectivity service.

* :doc:`Test Automation </testing/about_system_tests>`: Learn how Aether
  components are tested.

Note that Aether was originally deployed as a centrally-manged,
ONF-operated cloud service, with the expectation that organizations
would participate in Aether by connecting their site to this
operational deployment.\ [#]_ That service is now being deprecated in
favor of users bringing up their own Aether sites using :doc:`OnRamp
</onramp/overview>`, but the guide describing how to connect an edge
site to Aether (still available in `Version 2.1 of the Aether Docs
<https://docs.aetherproject.org/aether-2.1/edge_deployment/overview.html>`__)
is useful because it highlights many of the operational challenges
facing a production deployment of Aether as a managed cloud service.
Those challenges motivate many of the operational mechanisms available
in the Aether platform today, but now packaged for others to apply to
their deployments.

.. [#] The original Aether service supported the Pronto research
       project, with edge clusters built on top of an SDN-controlled
       and fully programmable switching fabric.  That fabric is no
       longer included in Aether OnRamp.


Aether Components
------------------------

Aether uses components from several ONF projects. Information about
these projects can be found at the following sites:

* SD-Core

  * `SD-Core Website <https://opennetworking.org/sd-core/>`_
  * :doc:`SD-Core Documentation <sdcore:index>`

* SD-RAN

  * `SD-RAN Website <https://opennetworking.org/open-ran/>`_
  * :doc:`SD-RAN Documentation <sdran:index>`

* SD-Fabric

  * `SD-Fabric Website <https://opennetworking.org/sd-fabric/>`_
  * :doc:`SD-Fabric Documentation <sdfabric:index>`

More information about 5G and Aether's architecture can be found in
the :doc:`Private 5G: A Systems Approach <sysapproach5g:index>` book.

Community
---------

Information about participating in the Aether community and
development process can be found on the `ONF Wiki
<https://wiki.opennetworking.org/display/COM/Aether>`_.  Join the
discussion about Aether on Slack in the `ONF Community Workspace
<https://onf-community.slack.com/>`__.
