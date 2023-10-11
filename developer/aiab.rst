.. vim: syntax=rst

Development Environment
=========================

There are different ways to build a development environment for
Aether.  Historically, Aether-in-a-Box (AiaB) has provided an easy way
to deploy and test Aether. AiaB is still available (as documented in
`Version 2.1 of this Guide
<https://docs.aetherproject.org/aether-2.1/developer/aiab.html>`__),
but it is no long supported.

`Aether OnRamp
<https://docs.aetherproject.org/master/onramp/overview.html>`__, which
builds on AiaB, is now the recommended way to deploy and test
Aether. It works across a range of scenarios, from a single VM running
an emulated RAN to a multi-node cluster supporting a physical
RAN. OnRamp's `Quick Start blueprint
<https://docs.aetherproject.org/master/onramp/start.html>`__ is
the closest in functionality to AiaB.

.. note:: If you are already using AiaB for your development, it
   should continue to work for the foreseeable future. One reason to
   consider migrating to OnRamp is that it establishes a well-defined
   procedure for contributing new configurations (OnRamp calls them
   `blueprints <https://docs.aetherproject.org/master/onramp/blueprints.html>`__)
   back to the community. This includes daily integration tests to ensure
   that various combinations of features continue to function correctly.

Finally, many developers prefer to work directly with Helm and
Kubernetes, bypassing the scripts/playbooks that AiaB and OnRamp
provide. This approach is especially efficient when you are working on
a single component and not concerned with cross-component integration.
The following section on ROC Development adopts this approach. For
details about contributing to SD-Core and SD-RAN, we refer you to
their respective guides:

* :doc:`SD-Core Documentation <sdcore:index>`

* :doc:`SD-RAN Documentation <sdran:index>`
