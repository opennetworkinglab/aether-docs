Introduction
==============

Aether is an open source 5G edge cloud platform that supports
enterprise deployments of Private 5G. Information about Aether (a
Linux Foundation project) can be found on the project website. An
introduction to the Aether architecture can be found in a companion
book:

.. _reading_private5g:
.. admonition:: Further Reading

   `Aether Project <https://aetherproject.org>`_.

   L. Peterson, O. Sunay, and B. Davie. `Private 5G: A Systems
   Approach <https://5g.systemsapproach.org>`__. 2023


Getting Started with Aether
---------------------------

:doc:`Aether OnRamp </onramp/overview>` is now the recommended way to
get started with Aether. It defines a step-by-step procedure for
deploying and operating Aether on your own hardware, including support
for `5G small cell
<https://opennetworking.org/products/moso-canopy-5g-indoor-small-cell/>`__
radios.

Other Aether guides available on this site include:

* :doc:`Developing for Aether </developer/roc>`: Learn how to
  contribute back to Aether.

* :doc:`Runtime Operations </operations/gui>`: Learn how
  to operate Aether's 5G connectivity service.

* :doc:`Test Automation </testing/about_system_tests>`: Learn how Aether
  components are tested.

Note that Aether was originally deployed as a centrally-managed cloud
service with a dedicated ops team. The expectation was that
organizations would participate in Aether by connecting their edge
site to this operational deployment.\ [#]_ That service has now been
deprecated in favor of users bringing up their own Aether sites using
:doc:`OnRamp </onramp/overview>`.

.. [#] The original Aether service supported the Pronto research
       project, with edge clusters built on top of an SDN-controlled
       and fully programmable switching fabric.  That fabric is no
       longer included in Aether OnRamp.


Aether Components
------------------------

Aether builds on two main subsystems: SD-Core (a 3GPP-compliant cloud
native Mobile Core) and SD-RAN (an O-RAN compliant near Real-Time RAN
Intelligent Controller, or nRT-RIC).  Additional documentation for each is
available at:

* :doc:`SD-Core Documentation <sdcore:index>`
* :doc:`SD-RAN Documentation <sdran:index>`

A third component, *ROC (Runtime Operational Control)*, is part of the
Aether Management Plane. This Guide documents how operators use ROC to
control Aether (see the NAV bar). ROC builds on µONOS (specifically
the ``onos-config`` microservice), with additional documentation for
developers available at:

* `µONOS Documentation <https://docs.onosproject.org>`__

More information about 5G and Aether's architecture can be found in
the :doc:`Private 5G: A Systems Approach <sysapproach5g:index>` book.

Community
---------

Information about participating in the Aether community and
development process can be found on the `Aether Wiki
<https://wiki.aetherproject.org/display/HOME/Aether+Project>`_.
