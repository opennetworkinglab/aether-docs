..
   SPDX-FileCopyrightText: © 2021 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

SD-Core Testing
===============

Test Framework
--------------

NG40
~~~~

Overview
^^^^^^^^

NG40 tool is used as RAN emulator in SD-Core testing. NG40 runs inside a VM
which is connected to both Aether control plane and data plane. In testing
scenarios that involve data plane verifications, NG40 also emulates a few
application servers which serve as the destinations of data packets.

A typical NG40 test case involves UE attaching, data plane verifications and
UE detaching. During the test NG40 acts as UEs and eNBs and talks to the
mobile core to complete attach procedures for each UE it emulates. Then NG40
verifies that data plane works for each attached UE by sending traffic between
UEs and application servers. Before finishing each test NG40 performs detach
procedures for each attached UE.

Test cases
^^^^^^^^^^

Currently the following NG40 test cases are implemented:

1. ``4G_M2AS_PING_FIX`` (attach, dl ping, detach)
2. ``4G_M2AS_UDP`` (attach, dl+ul udp traffic, detach)
3. ``4G_M2AS_TCP`` (attach, relaese, service request, dl+ul tcp traffic, detach)
4. ``4G_AS2M_PAGING`` (attach, release, dl udp traffic, detach)
5. ``4G_M2AS_SRQ_UDP`` (attach, release, service request, dl+ul udp traffic)
6. ``4G_M2CN_PS`` (combined IMSI/PTMSI attach, detach)
7. ``4G_HO`` (attach, relocate and ping, detach)
8. ``4G_SCALE`` (attach with multiple UEs, ping, detach)

All the test cases are parameterized and can take arguments to specify number
of UEs, attach/detach rate, traffic type/rate etc. For example, ``4G_SCALE``
test case can be configured as a mini scalability test which performs only 5
UE attaches in a patchset pre-merge test, while in the nightly tests it can
take different arguments to run 10K UE attaches with a high attach rate.

Test suites
^^^^^^^^^^^

The test cases are atomic testing units and can be combined to build test
suites. The following test suites have been built so far:

* ``functionality test suite`` verifies basic functionality of the
  mobile core. It runs test case #1 to #8 including ``4G_SCALE`` which attaches
  5 UEs with 1/s attach rate

* ``scalability test suite`` tests the system by scale and verifies
  system stability. It runs ``4G_SCALE`` which attaches a large number of UEs
  with high attach rate (16k UEs with 100/s rate on dev pod, and 10k UEs with
  10/s rate on staging pod)

* ``performance test suite`` measures performance of the control and
  data plane. It runs ``4G_SCALE`` multiple times with different attach rates
  to understand how the system performs under different loads.

Robot Framework
~~~~~~~~~~~~~~~

Robot Framework was chosen to build test cases that involve interacting with
not only NG40 but also other parts of the system. In these scenarios Robot
Framework acts as a high level orchestrator which drives various components
of the system using component specific libraries including NG40.

Currently the ``Integration test suite`` is implemented using Robot
Framework. In the integration tests Robot Framework calls ng40 library to
perform normal attach/detach procedures. Meanwhile it injects failures into
the system (container restarts, link down etc.) by calling functions
implemented in the k8s library.

The following integration tests are implemented at the moment:

* Subscriber Attach with HSS Restart
* Subscriber Attach with MME Restart
* Subscriber Attach with SPGWC Restart
* Subscriber Attach with PFCP Agent Restart

.. Note::
   More integration tests are being developed as part of Robot Framework

Test Schedules
--------------

Nightly Tests
~~~~~~~~~~~~~

Overview
^^^^^^^^

SD-Core nightly tests are a set of jobs managed by Aether Jenkins.
All four test suites we mentioned above are scheduled to run nightly.

* ``functionality job (func)`` runs NG40 test cases included in the
  functionality suite and verifies all tests pass.

* ``scalability job (scale)`` runs the scalability test suite and reports
  the number of successful/failed attaches, detaches and pings.

* ``performance job (perf)`` runs the performance test suite and reports
  SCTP heartbeat RTT, GTP ICMP RTT and call setup latency numbers.

And all these jobs can be scheduled on any of the Aether PODs including
``dev`` pod, ``staging`` pod and ``qa`` pod. By combining the test type and
test pod the following Jenkins jobs are generated:

* ``dev`` pod: `func_dev`, `scale_dev`, `perf_dev`, `integ_dev`
* ``staging`` pod: `func_staging`, `scale_staging`, `perf_staging`, `integ_staging`
* ``qa`` pod: `func_qa`, `scale_qa`, `perf_qa`, `integ_qa`

Job structure
^^^^^^^^^^^^^

Take `scale_dev` job as an example. It runs the following downstream jobs:

* `omec_deploy_dev`: this job re-deploys the dev pod with latest OMEC images.

.. Note::
   only the dev pod job triggers a deployment downstream job. No
   re-deployment is performed on the staging and qa pod before the tests

* `ng40-test_dev`: this job executes the scalability test suite.

* `archive-artifacts_dev`: this job collects and uploads k8s and container logs.

* `post-results_dev`: this job collects the NG40 test logs/pcaps and pushes the
  test data to database. It also generates plots using Rscript for func and
  scale tests

The integration tests are written using Robot Framework so have a slightly
different Jenkins Job structure. Take `integ_dev` as an example. It runs the
following downstream jobs:

* `omec_deploy_dev`: this job executes the scalability test suite.

* `robotframework-test_dev`: this job is similar to `ng40-test_dev` with the
  exception that instead of directly executing NG40 commands it calls robot
  framework to exectue the test cases and publishes the test results using
  `RobotPublisher` Jenkins plugin. The robot results will also be copied to
  the upstream job and published there.

* `archive-artifacts_dev`: this job collects and uploads k8s and container logs.

* `post-results_dev`: this job collects the NG40 test logs/pcaps and pushes the
  test data to database. It also generates plots using Rscript for func and
  scale tests

Patchset Tests
~~~~~~~~~~~~~~

Overview
^^^^^^^^

SD-Core pre-merge verifications cover the following Github repos: ``c3po``,
``Nucleus``, ``upf-epc`` and ``spgw`` (private). OMEC CI includes the following
verifications:

* ONF CLA verification
* License verifications (FOSSA/Reuse)
* NG40 tests

These verifications are automatically triggered by submitted or updated PR to
the repos above. They can also be triggered manually by commenting ``retest
this please`` to the PR. At this moment only CLI and NG40 verifications are
mandatory.

The NG40 verifications are a set of jobs running on both opencord Jenkins and
Aether Jenkins (private). The jobs run on opencord Jenkins include

* `omec_c3po_container_remote <https://jenkins.opencord.org/job/omec_c3po_container_remote/>`_ (public)

* `omec_Nucleus_container_remote <https://jenkins.opencord.org/job/omec_Nucleus_container_remote/>`_ (public)

* `omec_upf-epc_container_remote <https://jenkins.opencord.org/job/omec_upf-epc_container_remote/>`_ (public)

* `omec_spgw_container_remote` (private, under member-only folder)

And the jobs run on Aether Jenkins include

* `c3po_premerge_dev`

* `Nucleus_premerge_dev`

* `upf-epc_premerge_dev`

* `spgw_premerge_dev`

Job structure
^^^^^^^^^^^^^

Take c3po jobs as an example. c3po PR triggers a public job `omec_c3po_container_remote <https://jenkins.opencord.org/job/omec_c3po_container_remote/>`__
job running on opencord Jenkins through Github webhooks,
which then triggers a private job `c3po_premerge_dev` running on Aether Jenkins
using a Jenkins plugin called `Parameterized Remote Trigger Plugin <https://www.jenkins.io/doc/pipeline/steps/Parameterized-Remote-Trigger/>`__.

The private c3po job runs the following downstream jobs sequentially:

* `docker-publish-github_c3po`: this job downloads the c3po PR, runs docker
  build and publishes the c3po docker images to `Aether registry`.

* `omec_deploy_dev`: this job deploys the images built from previous job onto
  the omec dev pod.

* `ng40-test_dev`: this job executes the functionality test suite.

* `archive-artifacts_dev`: this job collects and uploads k8s and container logs.

After all the downstream jobs are finished, the upstream job (`c3po_premerge_dev`)
copies artifacts including k8s/container/NG40 logs and pcap files from
downstream jobs and saves them as Jenkins job artifacts.

These artifacts are also copied to and published by the public job
(`omec_c3po_container_remote <https://jenkins.opencord.org/job/omec_c3po_container_remote/>`__)
on opencord Jenkins so that they can be accessed by the OMEC community.

Pre-merge jobs for other OMEC repos share the same structure.

Post-merge
^^^^^^^^^^

The following jobs are triggered as post-merge jobs when PRs are merged to
OMEC repos:

* `docker-publish-github-merge_c3po`

* `docker-publish-github-merge_Nucleus`

* `docker-publish-github-merge_upf-epc`

* `docker-publish-github-merge_spgw`

Again take the c3po job as an example. The post-merge job (`docker-publish-github-merge_c3po`)
runs the following downstream jobs sequentially:

* `docker-publish-github_c3po`: this is the same job as the one in pre-merge
  section. It checks out the latest c3po code, runs docker build and
  publishes the c3po docker images to `docker hub <https://hub.docker.com/u/omecproject>`__.

.. Note::
   the spgw images are published to Aether registry instead of docker hub

* `c3po_postrelease`: this job submits a patchset to aether-pod-configs repo
  for updating the CD pipeline with images published in the job above.

Post-merge jobs for other OMEC repos share the same structure.
