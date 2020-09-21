=================
NG40 Test Results
=================

The logs for each test case can be found in their respective build artifacts.

OMEC
----

Functionality
^^^^^^^^^^^^^

This nightly-run job deploys the OMEC control plane and OMEC data plane on the dev cluster using images from `aether-helm-charts <https://gerrit.opencord.org/plugins/gitiles/aether-helm-charts>`_, then runs the following NG40 test cases:

- 4G_M2AS_PING_FIX
- 4G_M2AS_UDP
- 4G_M2AS_TCP
- 4G_AS2M_PAGING
- 4G_M2AS_SRQ_UDP
- 4G_M2CN_PS
- 4G_HO

Resources:

- *Detailed test plan page coming soon*
- Jenkins Job: `omec_func_dev <https://jenkins.opencord.org/job/omec_func_dev/>`_
- Latest build:
    - `OMEC Functionality NG40 logs <https://jenkins.opencord.org/job/omec_func_dev/lastBuild/artifact/ng40/log/>`_
    - `OMEC Functionality Artifacts <https://jenkins.opencord.org/job/omec_func_dev/lastBuild/artifact/>`_

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/omec_func_dev/plot.png
  :width: 840
  :height: 360
  :alt: OMEC NG40 Functionality Testing


Scaling
^^^^^^^

This nightly-run job deploys the OMEC control plane and OMEC data plane on the dev cluster using images from `aether-helm-charts <https://gerrit.opencord.org/plugins/gitiles/aether-helm-charts>`_, then performs the NG40 UE Scaling test.

Resources:

- *Detailed test plan page coming soon*
- Jenkins Job: `omec_scaling_dev <https://jenkins.opencord.org/job/omec_scaling_dev/>`_
- Latest build:
    - `OMEC Scaling NG40 logs <https://jenkins.opencord.org/job/omec_scaling_dev/lastBuild/artifact/ng40/log/>`_
    - `OMEC Scaling Artifacts <https://jenkins.opencord.org/job/omec_scaling_dev/lastBuild/artifact/>`_

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/omec_scaling_dev/attach.png
  :width: 840
  :height: 360
  :alt: OMEC NG40 Scaling Testing Attach Results

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/omec_scaling_dev/detach.png
  :width: 840
  :height: 360
  :alt: OMEC NG40 Scaling Testing Detach Results

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/omec_scaling_dev/ping.png
  :width: 840
  :height: 360
  :alt: OMEC NG40 Scaling Testing Ping Results

Aether
------

Functionality
^^^^^^^^^^^^^

This nightly-run job runs NG40 test cases from the NG40 VM on the production cluster. This list of test cases are:

- 4G_M2AS_PING_FIX
- 4G_M2AS_UDP
- 4G_M2AS_TCP
- 4G_AS2M_PAGING
- 4G_M2AS_SRQ_UDP
- 4G_M2CN_PS
- 4G_HO

Resources *(sign-in required)*:

- *Detailed test plan page coming soon*
- Jenkins Job: `aether_func_production <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_func_production/>`_
- Latest build:
    - `Aether Functionality NG40 logs <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_func_production/lastBuild/artifact/ng40/log/>`_
    - `Aether Functionality Artifacts <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_func_production/lastBuild/artifact/>`_

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/aether_func_production/plot.png
  :width: 840
  :height: 360
  :alt: Aether NG40 Functionality Testing

Scaling
^^^^^^^

This nightly-run job runs the NG40 UE scaling test from the NG40 VM on the production cluster.

Resources *(sign-in required)*:

- *Detailed test plan page coming soon*
- Jenkins Job: `aether_scaling_production <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_scaling_production/>`_
- Latest build:
    - `Aether Scaling NG40 logs <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_scaling_production/lastBuild/artifact/ng40/log/>`_
    - `Aether Scaling Artifacts <https://jenkins.opencord.org/job/aether-member-only-jobs/job/aether_scaling_production/lastBuild/artifact/>`_

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/aether_scaling_production/attach.png
  :width: 840
  :height: 360
  :alt: Aether NG40 Scaling Testing Attach Results

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/aether_scaling_production/detach.png
  :width: 840
  :height: 360
  :alt: Aether NG40 Scaling Testing Detach Results

.. image:: https://jenkins.opencord.org/view/OMEC/job/aether-archive-artifacts/lastSuccessfulBuild/artifact/aether_scaling_production/ping.png
  :width: 840
  :height: 360
  :alt: Aether NG40 Scaling Testing Ping Results
