Integration Tests
--------------------

A set of integration tests validate the released :doc:`Aether
Blueprints </onramp/blueprints>`. These tests exercise representative
deployment scenarios and simulated 5G workloads used throughout this
guide.

Finally, note that the integration tests run a variety of simulated 5G
workloads, including gNBsim, UERANSIM, OAI 5G RAN (in simulation
mode), and srsRAN (in simulation mode). Of these, gNBsim provides the
most rigorous testing of the Core's control plane, and serves as
Aether's primary validation of that functionality. More information
about gNBsim can be found in the :doc:`Emulated RAN
</onramp/gnbsim>` section of this Guide.
