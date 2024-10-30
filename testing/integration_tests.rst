..
   SPDX-FileCopyrightText: © 2023 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Integration Tests
===================

A set of integration tests validate various configurations of Aether.
The tests are managed by Jenkins, and can be monitored using the
following `Dashboard <https://jenkins.aetherproject.org/>`__.

Source code for the integration tests can be found on `GitHub
<https://github.com/opennetworkinglab/aether-jenkins>`__, where each
file in the repo corresponds to a Groovy script that implements a Jenkins pipeline
for one of the :doc:`Aether Blueprints </onramp/blueprints>`.

The pipelines are executed daily, with each pipeline parameterized to
run in multiple jobs. The ``${AgentLabel}`` parameter selects the
Ubuntu release being tested (currently ``20.04`` and ``22.04``),
with all jobs running in AWS VMs (currently resourced as ``M7iFlex2xlarge``).
Pipelines that exercise two-server tests (e.g., ``ueransim.groovy``, ``upf.groovy``,
and ``gnbsim.groovy`` run in VMs that have the
`AWS CLI <https://aws.amazon.com/cli/>`__ installed; the CLI is is used to create
the second VM. All VMs have Ansible installed, as documented in the
:doc:`OnRamp Guide </onramp/start>`.
