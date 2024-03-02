Development Support
-----------------------

OnRamp's primary goal is to support users that want to deploy
officially released versions of Aether on local hardware, but it also
provides a way for users that want to develop new features to deploy
and test them. To this end, this section describes how to
configure OnRamp to use locally modified components, such as
Helm Charts, Docker images, 5GC's source code.

At a low level, development is a component-specific task, and users
are referred to documentation for the respective subsystems:

* To develop SD-Core, see the :doc:`SD-Core Guide <sdcore:index>`.

* To develop SD-RAN, see the :doc:`SD-RAN Guide <sdran:index>`.

* To develop ROC-based APIs, see :doc:`ROC Development </developer/roc>`.

* To develop Monitoring Dashboards, see :doc:`Monitoring & Alert Development </developer/monitoring>`.

At a high level, OnRamp provides a means to deploy developmental
versions of Aether than include local modifications to the standard
components. These modifications range from coarse-grain (i.e.,
replacing the Helm Chart for an entire subsystem), to fine-grain
(i.e., replacing the container image for an individual microservice).
The following uses SD-Core as a specific example to illustrate how
this is done. The same approach can be applied to other subsystems.

To substitute a local Helm Chart—for example, one located in directory
``/home/ubuntu/aether/sdcore-helm-charts/sdcore-helm-charts`` on the
server where you run the OnRamp ``make`` targets—edit the ``helm``
block of the ``core`` section of ``vars/main.yml`` to replace:

.. code-block::

  helm:
    local_charts: false
    chart_ref: aether/sd-core
    chart_version: 0.12.8

with

.. code-block::

  helm:
    local_charts: true
    chart_ref: "/home/ubuntu/aether/sdcore-helm-charts/sdcore-helm-charts"
    chart_version: 0.13.2

Note that variable ``core.helm.local_charts`` is a boolean, not the
string ``"true"``. And in this example, we have declared our new chart
to be version ``0.13.2`` instead of ``0.12.8``.

To substitute a locally built container image, edit the corresponding
block in the values override file that you have configured in
``vars/main.yml``; e.g.,
``deps/5gc/roles/core/templates/sdcore-5g-values.yaml``.  For example,
if you have published an alternative version of the AMF microservice
in your account on Docker Hub with tag ``myversion:foo``, then set the
``images`` block of 5G control plane section accordingly:

.. code-block::

  5g-control-plane:
    enable5G: true
    images:
      repository: "hub.docker.com/myregistry/"
      tags:
        amf: myversion:foo
