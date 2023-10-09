Overview
----------------

`Aether OnRamp <https://github.com/opennetworkinglab/aether-onramp>`__
is a packaging of Aether in a way that makes it easy to deploy the
system on your own hardware. It provides an incremental path for users
to:

* Learn about and observe all the moving parts in Aether.
* Customize Aether for different target environments.
* Experiment with scalable edge communication.
* Deploy and operate Aether with live 5G traffic.

Aether OnRamp begins with a *Quick Start* deployment similar to
`Aether-in-a-Box (AiaB)
<https://docs.aetherproject.org/master/developer/aiab.html>`__, but
then goes on to prescribe a sequence of steps users can follow to
deploy increasingly complex configurations. OnRamp refers to each such
configuration as a *blueprint*, and the set supports both emulated and
physical RANs, along with the runtime machinery needed to operate an
Aether cluster supporting live 5G workloads.  (OnRamp also defines a
4G blueprint that can be used to connected one or more physical eNBs,
but we postpone a discussion of that capability until a later
section. Everything else in this guide assumes 5G.)

.. include:: directory.rst

Aether OnRamp is still a work in progress, but anyone
interested in participating in that effort is encouraged to join the
discussion on Slack in the `ONF Community Workspace
<https://onf-community.slack.com/>`__. A roadmap for the work that
needs to be done can be found in the `Aether OnRamp Wiki
<https://github.com/opennetworkinglab/aether-onramp/wiki>`__.

