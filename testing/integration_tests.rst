..
   SPDX-FileCopyrightText: © 2023 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Integration Tests
===================

A set of integration tests run daily to validate various
configurations of Aether, corresponding to the set of supported
:doc:`OnRamp Blueprints </onramp/blueprints>`. The tests are managed
by Jenkins, and can be monitored using the following
`Dashboard <https://jenkins.aetherproject.org/view/Aether%20OnRamp/>`__.
The following summarizes the current set of tests.

Basic Functionality
----------------------

These tests validate the base components, configured with (``AMP``) or
without the Aether Management Plane; running on either a single server
(``QuickStart``) or two servers (``2server``); configured with the
officially released Helm Charts (``default-charts``) or the most
recently published charts (``latest-charts``); and deployed on Ubuntu
``20.04`` or ``22.04``.

* ``AetherOnRamp_QuickStart_20.04_default-charts``
* ``AetherOnRamp_QuickStart_22.04_default-charts``
* ``AetherOnRamp_QuickStart_20.04_latest-charts``
* ``AetherOnRamp_QuickStart_22.04_latest-charts``
* ``AetherOnRamp_QuickStart_20.04_AMP``
* ``AetherOnRamp_QuickStart_22.04_AMP``
* ``AetherOnRamp_2servers_20.04_default-charts``
* ``AetherOnRamp_2servers_22.04_default-charts``

Advanced Functionality
----------------------------

These tests validate blueprints that incorporate additional
functionality, including being configured with alternative RANs
(``Physical-ENB``, ``Physical-GNB``, ``SD-RAN``, ``UERANSIM``) and
with multiple UPF pods (``Multi-UPF``).

* ``AetherOnRamp_2servers_20.04_UERANSIM``
* ``AetherOnRamp_QuickStart_20.04_UERANSIM``
* ``AetherOnRamp_2servers_Multi-UPF``
* ``AetherOnRamp_QuickStart_Multi-UPF``
* ``AetherOnRamp_QuickStart_SD-RAN``
* ``AetherOnRamp_Physical-ENB``
* ``AetherOnRamp_Physical-GNB``

Testing In-Depth
-------------------------

Although still a work-in-progress, we also plan for additional
in-depth tests, including automated testing of the :doc:`Aether API
</testing/aether-roc-tests>`.

* ``AetherOnRamp_QuickStart_API-Test``
