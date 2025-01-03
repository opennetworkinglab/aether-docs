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

Aether OnRamp begins with a *Quick Start* recipe that deploys Aether
in a single VM or server, but then goes on to prescribe a sequence of
steps users can follow to deploy increasingly complex configurations.
OnRamp refers to each such configuration as a *blueprint*, where the
set supports both emulated and physical RANs, along with the runtime
machinery needed to operate an Aether cluster supporting live 5G
workloads.\ [#]_ The goal of this Guide is to help users take
ownership of the Aether deployment process by incrementally exposing
all the degrees-of-freedom Aether supports.

.. [#] OnRamp also defines a 4G blueprint that can be used to
       connected one or more physical eNBs, but we postpone a
       discussion of that capability until a later section. Everything
       else in this guide assumes 5G.

.. include:: directory.rst

Aether OnRamp is still a work in progress, but anyone
interested in participating in that effort is encouraged to join the
discussion on Slack in the `Aether Community Workspace
<https://aether5g-project.slack.com/>`__. A roadmap for the work that
needs to be done can be found in the `Aether OnRamp Wiki
<https://wiki.aetherproject.org/display/HOME/Aether+OnRamp>`__.

How to Read This Guide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This guide is written to be followed sequentially, with each section
establishing a capability that later sections build upon. This is also
helpful when troubleshooting a deployment—for example, isolating a
problem with a physical gNB is easier if you know that connectivity to
the AMF and UPF works correctly, which the :doc:`Emulated RAN
</onramp/gnbsim>` section helps to establish.

Once you reach the last section (:doc:`Other Blueprints
</onramp/blueprints>`), you will have seen examples of all the
degrees-of-freedom OnRamp supports, with the goal of preparing you to
take ownership of your own deployment. You can do this by defining
your own customized blueprint, and/or directly interacting with Helm
and Kubernetes (rather than depending entirely on OnRamp's playbooks).

That final :doc:`Other Blueprints </onramp/blueprints>` section then
gives a synopsis of several additional OnRamp blueprints. Each
blueprint enables a particular combination of Aether features,
demonstrating how those features are configured, and deployed. This
section presumes familiarity with all of OnRamp's capabilities
introduced in the earlier sections. For a summary review of all
available blueprints, see the :doc:`Quick Reference </onramp/ref>`
guide.
