Development Support
-----------------------

OnRamp's primary goal is to support users that want to deploy
officially released versions of Aether on local hardware, but it also
provides a way for users that want to develop new features to deploy
and test them. To this end, this section describes how to configure
OnRamp to use locally modified components, such as Helm Charts and
Docker images (including new images built from source code).

At a low level, development is a component-specific task, and users
are referred to documentation for the respective subsystems:

* To develop SD-Core, see the :doc:`SD-Core Guide <sdcore:index>`.

* To develop SD-RAN, see the :doc:`SD-RAN Guide <sdran:index>`.

* To develop ROC-based APIs, see :doc:`ROC Development </developer/roc>`.

* To develop Monitoring Dashboards, see :doc:`Monitoring & Alert Development </developer/monitoring>`.

At a high level, OnRamp provides a means to deploy developmental
versions of Aether that include local modifications to the standard
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
if you want to deploy the AMF image with tag ``my-amf:version-foo``
from the container registry of your personal GitLab account, then set
the ``images`` block of 5G control plane section accordingly:

.. code-block::

  5g-control-plane:
    enable5G: true
    images:
      repository: "registry.gitlab.com"
      tags:
        amf: my-account/my-amf:version-foo

A new Make target streamlines the process of frequently re-installing
the Kubernetes pods that implement the Core:

.. code-block::

  $ make 5gc-core-reset

If you are also modifying gNBsim in concert with changes to SD-Core,
then note that the former is not deployed on Kubernetes, and so there
is no Helm Chart or values override file. Instead, you simply need to
modify the ``image`` variable in the ``gnbsim`` section of
``vars/main.yml`` to reference your locally built image:

.. code-block::

  gnbsim:
    docker:
      container:
        image: omecproject/5gc-gnbsim:main-PR_88-cc0d21b

For convenience, the following Make target restarts the container,
which pulls in the new image.

.. code-block::

  $ make gnbsim-reset

Keep in mind that you can also rerun gNBsim with the *same* container,
but loading the latest gNBsim config file, by typing:

.. code-block::

  $ make aether-gnbsim-run

