Integration Tests
--------------------

A set of integration tests validate the released :doc:`Aether
Blueprints </onramp/blueprints>`. These tests exercise representative
deployment scenarios and simulated 5G workloads used throughout this
guide.

The GitHub Actions workflows in ``aether-onramp/.github/workflows``
build ``hosts.ini`` dynamically before running the playbooks. The
single-node workflows use ``localhost`` with
``ansible_connection=local`` and do not set ``ansible_host``. This
lets the workflows exercise the same playbooks without requiring SSH
access back into the runner itself.

The current integration-test inventory patterns are as follows:

* Quick Start, Quick Start AMP, SD-RAN, OAI, and srsRAN run as
  single-node tests, with both ``[master_nodes]`` and the
  blueprint-specific host group pointing at ``localhost``.

This means the checked-in inventory examples and the CI-generated
inventories are similar in structure, but they do not use identical
host aliases.

Finally, note that the integration tests run a variety of simulated 5G
workloads, including gNBsim, UERANSIM, OAI 5G RAN (in simulation
mode), and srsRAN (in simulation mode). Of these, gNBsim provides the
most rigorous testing of the Core's control plane, and serves as
Aether's primary validation of that functionality. More information
about gNBsim can be found in the :doc:`Emulated RAN
</onramp/gnbsim>` section of this Guide.
