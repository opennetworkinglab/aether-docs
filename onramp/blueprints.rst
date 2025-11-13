Other Blueprints
-----------------------

The previous sections describe how to deploy three Aether blueprints,
corresponding to three variants of ``var/main.yml``. This section
documents additional blueprints, each defined by a combination of
Ansible components:

* A ``vars/main-blueprint.yml`` file, checked into the
  ``aether-onramp`` repo, is the "root" of the blueprint
  specification.

* A ``hosts.ini`` file, documented by example, specifies the target
  servers required by the blueprint.

* A set of Make targets, defined in a submodule and imported into
  OnRamp's global Makefile, provides commands to install and uninstall
  the blueprint.

* (Optional) A new ``aether-blueprint`` repo defines the Ansible Roles
  and Playbooks required to deploy a new component.

* (Optional) New Roles, Playbooks, and Templates, checked to existing
  repos/submodules, customize existing components for integration with
  the new blueprint. To support blueprint independence, these elements
  are intentionally kept "narrow", rather than glommed onto an
  existing element.

* (Optional) Any additional hardware (beyond the Ansible-managed
  Aether servers) required to support the blueprint.

* A Jenkins pipeline, added to the set of OnRamp integration tests,
  verifies that the blueprint successfully deploys Aether. These
  pipelines are defined by Groovy scripts, and can be found in the
  ``aether-jenkins`` repo.

The above list also establishes the requirements for adding new
blueprints to OnRamp. The community is to encourage to contribute (and
maintain) new Aether configurations and deployment scenarios.\ [#]_
The rest of this section documents community-contributed blueprints
to-date; the concluding subsection gives a set of guidelines for
creating new blueprints.

.. [#] Not all possible configurations of Aether require a
       blueprint. There are other ways to add variability, for
       example, by documenting simple ways to modify an existing
       blueprint.  Disabling ``core.standalone`` and selecting an
       alternative ``core.values_file`` are two common examples.

Finally, because some blueprints include features that are not
compatible with simple configurations like *Quick Start*, it is
sometimes necessary to install/uninstall Aether using a set of narrow
Make targets (e.g., ``5gc-upf-install``) rather than a single broad
target (e.g., ``aether-5gc-install``). Such situations are documented
in the following subsections.

Multiple UPFs
~~~~~~~~~~~~~~~~~~~~~~

The base version of SD-Core includes a single UPF, running in the same
Kubernetes namespace as the Core's control plane. This blueprint adds
the ability to bring up multiple UPFs (each in a different namespace),
and uses ROC to establish the *UPF-to-Slice-to-Device* bindings
required to activate end-to-end user traffic. The resulting deployment
is then verified using gNBsim.

The Multi-UPF blueprint includes the following:

* Global vars file ``vars/main-upf.yml`` gives the overall
  blueprint specification.

* Inventory file ``hosts.ini`` is identical to that used in the
  :doc:`Emulated RAN </onramp/gnbsim>` section.  Minimally,
  SD-Core runs on one server and gNBsim runs on a second server.
  (The Quick Start deployment, with both SD-Core and gNBsim running
  in the same server, may also work, but is not actively maintained.)

* New make targets, ``5gc-upf-install`` and ``5gc-upf-uninstall``, to
  be executed after the standard SD-Core installation. The blueprint
  also reuses the ``roc-load`` target to activate new slices in ROC.

* New Ansible role (``upf``) added to the ``5gc`` submodule, including
  a new UPF-specific template (``upf-5g-values.yaml``).

* New models file (``roc-5g-models-upf2.json``) added to the
  ``roc-load`` role in the ``amp`` submodule. This models file is
  applied as a patch *on top of* the base set of ROC models. (Since
  this blueprint is demonstrated using gNBsim, the assumed base models
  are given by ``roc-5g-models.json``.)

* The Jenkins pipeline ``upf.groovy`` validates the Multi-UPF
  blueprint.

To use Multi-UPF, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-upf.yml main.yml

Then edit ``hosts.ini`` and ``vars/main.yml`` to match your local
target servers, and deploy the base system (as in previous sections).
You can also optionally install the monitoring subsystem.

.. code-block::

   $ make k8s-install
   $ make roc-install
   $ make roc-load
   $ make 5gc-install
   $ make gnbsim-install

Note that because ``main.yml`` sets ``core.standalone: "false"``, any
models loaded into ROC are automatically applied to SD-Core.

At this point you are ready to bring up additional UPFs and bind them
to specific slices and devices. An example configuration that brings
up second UPF is included in the ``upf`` block in the ``core`` section
of ``vars/main.yml``:

.. code-block::

   upf:
      access_subnet: "192.168.252.1/24"	# access subnet & gateway
      core_subnet: "192.168.250.1/24"	# core subnet & gateway
      helm:
          chart_ref: aether/bess-upf
     values_file: "deps/5gc/roles/upf/templates/upf-5g-values.yaml"
     default_upf:
        ip:
          access: "192.168.252.3"
          core:   "192.168.250.3"
        ue_ip_pool: "192.168.100.0/24"
     additional_upfs:
        "1":
           ip:
             access: "192.168.252.6"
             core:   "192.168.250.6"
           ue_ip_pool: "172.248.0.0/16"
        # "2":
        #   ip:
        #     access: "192.168.252.7"
        #     core:   "192.168.250.7"
        #   ue_ip_pool: "172.247.0.0/16"

As shown above, one additional UPF is enabled (beyond ``upf-0`` that
already came up as part of SD-Core), with the spec for yet another UPF
commented out.  In this example configuration, each UPF is assigned a
subnet on the ``access`` and ``core`` bridges, along with the IP
address pool for UEs that the UPF serves. To launch this second UPF,
type:

.. code-block::

   $ make 5gc-upf-install

At this point the new UPF(s) will be running in their own namespaces
(you can verify this using ``kubectl get pods --all-namespaces``), but
no traffic will be directed to them until UEs are assigned to their IP
address pool. Doing so requires loading the appropriate bindings into
ROC, which you can do by editing the ``roc_models`` line in ``amp``
section of ``vars/main.yml``. Comment out the original models file
already loaded into ROC, and uncomment the new patch that is to be
applied:

.. code-block::

   amp:
      # roc_models: "deps/amp/roles/roc-load/templates/roc-5g-models.json"
      roc_models: "deps/amp/roles/roc-load/templates/roc-5g-models-upf2.json"

Then run the following to load the patch:

.. code-block::

   $ make roc-load

At this point you can bring up the Aether GUI and see that a second
slice and a second device group have been mapped onto the second UPF.

Now you are ready to run traffic through both UPFs, which because the
configuration files identified in the ``servers`` block of the
``gnbsim`` section of ``vars/main.yml`` align with the IMSIs bound to
each Device Group (which are bound to each slice, which are in turn
bound to each UPF), the emulator sends data through both UPFs.  To run
the emulation, type:

.. code-block::

   $ make gnbsim-run

To verify that both UPFs were functional, you will need to look at the
``summary.log`` file from both instances of gNBsim:

.. code-block::

   $ docker exec -it gnbsim-1 cat summary.log
   $ docker exec -it gnbsim-2 cat summary.log


SD-RAN (RIC)
~~~~~~~~~~~~~~~~~~~~~~

This blueprint runs SD-Core and SD-RAN's near real-time RIC in tandem,
with RANSIM emulating various RAN elements. (The OnRamp roadmap
includes plans to couple SD-RAN with other virtual and physical RAN
elements, but RANSIM is currently the only option.)

The SD-RAN blueprint includes the following:

* Global vars file ``vars/main-sdran.yml`` gives the overall
  blueprint specification.

* Inventory file ``hosts.ini`` is identical to that used in the Quick
  Start deployment, with both SD-RAN and SD-Core co-located on a
  single server.

* New make targets, ``sdran-install`` and
  ``sdran-uninstall``, to be executed after the standard
  SD-Core installation.

* A new submodule ``deps/sdran`` (corresponding to repo
  ``aether-sdran``) defines the Ansible Roles and Playbooks required
  to deploy SD-RAN.

* The Jenkins pipeline ``sdran.groovy`` validates the SD-RAN
  blueprint.

To use SD-RAN, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-sdran.yml main.yml

Then edit ``hosts.ini`` and ``vars/main.yml`` to match your local
target servers, and deploy the base system (as in previous sections),
followed by SD-RAN:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make sdran-install

Use ``kubectl`` to validate that the SD-RAN workload is running, which
should result in output similar to the following:

.. code-block::

   $ kubectl get pods -n sdran
   NAME                             READY   STATUS    RESTARTS   AGE
   onos-a1t-68c59fb46-8mnng         2/2     Running   0          3m12s
   onos-cli-c7d5b54b4-cddhr         1/1     Running   0          3m12s
   onos-config-5786dbc85c-rffv7     3/3     Running   0          3m12s
   onos-e2t-5798f554b7-jgv27        2/2     Running   0          3m12s
   onos-kpimon-555c9fdb5c-cgl5b     2/2     Running   0          3m12s
   onos-topo-6b59c97579-pf5fm       2/2     Running   0          3m12s
   onos-uenib-6f65dc66b4-b78zp      2/2     Running   0          3m12s
   ran-simulator-5d9465df55-p8b9z   1/1     Running   0          3m12s
   sd-ran-consensus-0               1/1     Running   0          3m12s
   sd-ran-consensus-1               1/1     Running   0          3m12s
   sd-ran-consensus-2               1/1     Running   0          3m12s

Note that the SD-RAN workload includes RANSIM as one of its pods;
there is no separate "run simulator" step as is the case with gNBsim.
To validate that the emulation ran correctly, query the ONOS CLI as
follows:

Check ``onos-kpimon`` to see if 6 cells are present:

.. code-block::

   $ kubectl exec -it deployment/onos-cli -n sdran -- onos kpimon list metrics

Check ``ran-simulator`` to see if 10 UEs and 6 cells are present:

.. code-block::

   $ kubectl exec -it deployment/onos-cli -n sdran -- onos ransim get cells
   $ kubectl exec -it deployment/onos-cli -n sdran -- onos ransim get ues

Check ``onos-topo`` to see if ``E2Cell`` is present:

.. code-block::

   $ kubectl exec -it deployment/onos-cli-n sdran -- onos topo get entity -v

UERANSIM
~~~~~~~~~~~~~~~~~~~~~~

This blueprint runs UERANSIM in place of gNBsim, providing a second
way to direct workload at SD-Core. Of particular note, UERANSIM runs
``iperf3``, making it possible to measure UPF throughput. (In
contrast, gNBsim primarily stresses the Core's Control Plane.)

The UERANSIM blueprint includes the following:

* Global vars file ``vars/main-ueransim.yml`` gives the overall
  blueprint specification.

* Inventory file ``hosts.ini`` needs to be modified to identify the
  server that is to run UERANSIM. Currently, a second server is
  needed, as UERANSIM and SD-Core cannot be deployed on the same
  server. As an example, ``hosts.ini`` might look like this:

.. code-block::

   [all]
   node1  ansible_host=10.76.28.113 ansible_user=aether ansible_password=aether ansible_sudo_pass=aether
   node2  ansible_host=10.76.28.115 ansible_user=aether ansible_password=aether ansible_sudo_pass=aether

   [master_nodes]
   node1

   [worker_nodes]
   #node2

   [ueransim_nodes]
   node2

* New make targets, ``ueransim-install``,
  ``ueransim-run``, and ``ueransim-uninstall``, to be
  executed after the standard SD-Core installation.

* A new submodule ``deps/ueransim`` (corresponding to repo
  ``aether-ueransim``) defines the Ansible Roles and Playbooks
  required to deploy UERANSIM. It also contains configuration files
  for the emulator.

* The Jenkins pipeline ``ueransim.groovy`` validates the UERANSIM
  blueprint. It also illustrates how to run Linux commands that
  exercise the user plane from the emulated UE.

To use UERANSIM, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-ueransim.yml main.yml

Then edit ``hosts.ini`` and ``vars/main.yml`` to match your local
target servers, and deploy the base system (as in previous sections),
followed by UERANSIM:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make ueransim-install
   $ make ueransim-run

The last step actually starts UERANSIM, configured according to the
specification given in files ``custom-gnb.yaml`` and
``custom-ue.yaml`` located in ``deps/ueransim/config``. Make target
``ueransim-run`` can be run multiple times, where doing so
reflects any recent edits to the config files. More information about
UERANSIM can be found on `GitHub
<https://github.com/aligungr/UERANSIM>`__, including how to set up the
config files.

Finally, since the main value of UERANSIM is to measure user plane
throughput, you may want to play with the UPF's Quality-of-Service
parameters, as defined in
``deps/5gc/roles/core/templates/sdcore-5g-values.yaml``. Specifically,
see both the UE-level settings associated with ``ue-dnn-qos`` and the
slice-level settings associated with ``slice_rate_limit_config``.

Physical eNBs
~~~~~~~~~~~~~~~~~~

Aether OnRamp is geared towards 5G, but it does support physical eNBs,
including 4G-based versions of both SD-Core and AMP.  The 4G blueprint
has been demonstrated with `SERCOMM's 4G/LTE CBRS Small Cell
<https://wiki.aetherproject.org/display/HOME/Certified+Hardware>`__.
The blueprint uses all the same Ansible machinery outlined in earlier
sections, but starts with a variant of ``vars/main.yml`` customized
for running physical 4G radios:

.. code-block::

   $ cd vars
   $ cp main-eNB.yml main.yml

Assuming that starting point, the following outlines the key
differences from the 5G case:

* There is a 4G-specific repo, which you can find in ``deps/4gc``.

* The ``core`` section of ``vars/main.yml`` specifies a 4G-specific values file:

  ``values_file: "deps/4gc/roles/core/templates/radio-4g-values.yaml"``

* The ``amp`` section of ``vars/main.yml`` specifies that 4G-specific
  models and dashboards get loaded into the ROC and Monitoring
  services, respectively:

  ``roc_models: "deps/amp/roles/roc-load/templates/roc-4g-models.json"``

  ``monitor_dashboard:  "deps/amp/roles/monitor-load/templates/4g-monitor"``

* You need to edit two files with details for the 4G SIM cards you
  use. One is the 4G-specific values file used to configure SD-Core:

  ``deps/4gc/roles/core/templates/radio-4g-values.yaml``

  The other is the 4G-specific Models file used to bootstrap ROC:

  ``deps/amp/roles/roc-load/templates/radio-4g-models.json``

* There are 4G-specific Make targets for SD-Core (e.g., ``make
  aether-4gc-install`` and ``make aether-4gc-uninstall``), but the
  Make targets for AMP (e.g., ``make aether-amp-install`` and ``make
  aether-amp-uninstall``) work unchanged in both 4G and 5G.

The Quick Start and Emulated RAN (gNBsim) deployments are for 5G only,
but revisiting the previous sections—substituting the above for their
5G counterparts—serves as a guide for deploying a 4G blueprint of
Aether.  Note that the network is configured in exactly the same way
for both 4G and 5G. This is because SD-Core's implementation of the
UPF is used in both cases.

Enable SR-IOV and DPDK
~~~~~~~~~~~~~~~~~~~~~~~~~~

UPF performance can be improved by enabling SR-IOV and DPDK. This
blueprint supports both optimizations, where the former depends on the
server NIC(s) being SR-IOV capable. Before getting to the blueprint
itself, we note the following hardware-related prerequisites.

* Make sure virtualization and VT-d parameters are enabled in the BIOS.

* Make sure enough ``hugepage`` memory has been allocated and
  ``iommu`` is enabled. These changes can be made by updating
  ``/etc/default/grub``:

  .. code-block::

    GRUB_CMDLINE_LINUX="intel_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=32 transparent_hugepage=never"

  Note that the number of ``hugepages`` must be two times the number
  of UPF Instances.  Once the file is updated, apply the changes by running:

  .. code-block::

    $ sudo update-grub
    $ sudo reboot

  Verify the allocated ``hugepages`` using the following command:

  .. code-block::

    $ cat /proc/meminfo | grep HugePages
    AnonHugePages:         0 kB
    ShmemHugePages:        0 kB
    FileHugePages:         0 kB
    HugePages_Total:      32
    HugePages_Free:       32
    HugePages_Rsvd:        0
    HugePages_Surp:        0

* Create the required VF devices, where a minimum of two is required
  for each UPF. Using ``ens801f0`` as an example VF interface, this is
  done as follows:

  .. code-block::

    $ echo 2 > /sys/class/net/ens801f0/device/sriov_numvfs

  Retrieve the PCI address for the newly created VF devices using
  the following command:

  .. code-block::

    $ ls -l /sys/class/net/ens801f0/device/virtfn*

* Clone the DPDK repo to use the binding tools:

  .. code-block::

    $ git clone https://github.com/DPDK/dpdk.git
    $ cd dpdk

* Bind the VF devices to the ``vfio-pci`` driver as follows:

  .. code-block::

    $ ./usertools/dpdk-devbind.py -b vfio-pci 0000:b1:01.0
    $ ./usertools/dpdk-devbind.py -b vfio-pci 0000:b1:01.1

Returning to the OnRamp blueprint, it includes the following:

* Global vars file ``vars/main-sriov.yml`` gives the overall blueprint
  specification.

* Inventory file ``hosts.ini`` is identical to that used throughout
  this Guide. There are no additional node groups.

* New make targets, ``5gc-sriov-install`` and ``5gc-sriov-uninstall``, to
  be executed along with the standard SD-Core installation (see below).

* New Ansible role (``sriov``) added to the ``5gc``
  submodule.

* SRIOV-specific override variables required to configure the core are
  included in a new template:
  ``deps/5gc/roles/core/templates/sdcore-5g-sriov-values.yaml``.

* Integration tests require SR-IOV capable servers, and so have not
  been automated in Jenkins.

To use SR-IOV and DPDK, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-sriov.yml main.yml

You will see the main difference in the ``upf`` block of the ``core``
section:

.. code-block::

    upf:
      access_subnet: "192.168.252.1/24"	# access subnet & gateway
      core_subnet: "192.168.250.1/24"	# core subnet & gateway
      mode: dpdk			# Options: af_packet or dpdk
      # If mode set to 'dpdk':
      #    - make sure at least two VF devices are created out of 'data_iface'
      #      and these devices are attached to vfio-pci driver;
      #    - use 'sdcore-5g-sriov-values.yaml' file for 'values_file' (above).

Note the VF device requirement in ``upf`` block comments, and be sure
that the ``core`` block points to the alternative override file:

.. code-block::

    values_file: "deps/5gc/roles/core/templates/sdcore-5g-sriov-values.yaml"

Deploying this blueprint involves the invoking the following sequence
of Make targets:

.. code-block::

   $ make k8s-install
   $ make 5gc-router-install
   $ make 5gc-sriov-install
   $ make 5gc-core-install

The ``5gc-sriov-install`` step happens after the Kubernetes cluster is
installed, but before the Core workload is instantiated on that
cluster.  The corresponding playbook augments Kubernetes with the
required extensions. It has been written to do nothing unless variable
``core.upf.mode`` is set to ``dpdk``, where OnRamp now includes the
``5gc-sriov-install`` target as part of its default ``5gc-install``
target.


OAI 5G RAN
~~~~~~~~~~~~~~~~~~~~

Aether can be configured to work with the open source gNB from OAI.
The blueprint runs in either simulation mode or with a USRP
software-defined radio connecting wirelessly to one or more
off-the-shelf UEs. (OAI also supports USRP-based UEs, but this
blueprint does not currently support that option; you need to deploy
such a UE separately.)

The following assumes familiarity with the OAI 5G RAN stack, but it is
**not** necessary to separately install the OAI stack. OnRamp installs
both the Aether Core and the OAI RAN, plus the networking needed to
interconnect the two.

.. _reading_oai:
.. admonition:: Further Reading

   `Open Air Interface 5G
   <https://gitlab.eurecom.fr/oai/openairinterface5g/>`__.

The blueprint includes the following:

* Global vars file ``vars/main-oai.yml`` gives the overall blueprint
  specification.

* Inventory file ``hosts.ini`` uses label ``[oai_nodes]`` to denote
  the server(s) that host the gNB and (when configured in simulation
  mode) the UE. As with gNBsim, ``[oai_nodes]`` can identify the same
  server as Kubernetes (where the 5G Core runs). Another possible
  configuration is to co-locate the gNB and UE on one server, with the
  5G Core running on a separate server. (Although not necessary in
  principle, the current playbooks require the gNB and simulated UE be
  located on the same server.)

* New make targets, ``oai-gnb-install`` and ``oai-gnb-uninstall``, to
  be executed along with the standard SD-Core installation (see  below).
  When running a simulated UE, targets ``oai-uesim-start`` and
  ``oai-uesim-stop`` are also available.

* A new submodule ``deps/oai`` (corresponding to repo ``aether-oai``)
  defines the Ansible Roles and Playbooks required to deploy the OAI
  gNB.

* The Jenkins pipeline ``oai.groovy`` validates the OAI 5G
  blueprint. The pipeline runs OAI in simulation mode, but the blueprint
  has also been validated with USRP X310.

To use an OAI gNB, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-oai.yml main.yml

You will see the main difference is the addition of the ``oai``
section:

.. code-block::

   oai:
     docker:
       container:
         gnb_image: oaisoftwarealliance/oai-gnb:develop
         ue_image: oaisoftwarealliance/oai-nr-ue:develop
       network:
         data_iface: ens18
         name: public_net
         subnet: "172.20.0.0/16"
         bridge:
           name: rfsim5g-public
     simulation: true
     servers:
       0:
         gnb_conf: deps/oai/roles/gNb/templates/gnb.sa.band78.fr1.106PRB.usrpb210.conf
         gnb_ip: "172.20.0.2"
         ue_conf: deps/oai/roles/uEsimulator/templates/ue.conf

Variable ``simulation`` is set to ``true`` by default, causing OnRamp
to deploy the simulated UE.  When set to ``false``, the simulated UE
is not deployed and it is instead necessary to configure the USRP and
a physical UE.

Note that instead of downloading and compiling the latest OAI
software, this blueprint pulls in the published images for both the
gNB and UE, corresponding to variables
``docker.container.gnb_image`` and ``docker.container.ue_image``,
respectively. If you plan to modify the OAI software, you will need to
change these values accordingly. See the :doc:`Development Support
</onramp/devel>` section for guidance.

The ``network`` block of the ``oai`` section configures the necessary
tunnels so the gNB can connect to the Core's user and control planes.
Variable ``network.data_iface`` needs to be modified in the same way
as in the ``core`` and ``gnbsim`` sections of ``vars/main.yml``, as
described throughout this Guide.

Note: we can deploy multiple OAI gNB's simultaneously by adding as
many servers under ``oai.servers`` section.

The path names associated with variables ``gnb_conf`` and
``ue_conf`` are OAI-specific configuration files. The two
given by default are for simulation mode. The template directory for
the ``gNb`` role also includes a configuration file for when the USRP
X310 hardware is to be deployed; edit variable ``gnb_conf``
to point to that file instead. If you plan to use some other OAI
configuration file, note that the following two variables in the ``AMF
parameters`` section need to be modified to work with the Aether Core:

.. code-block::

   amf_ip_address = ({ ipv4 = "{{ core.amf.ip }}"; });

   GNB_IPV4_ADDRESS_FOR_NG_AMF  = "{{oai.gnb.ip}}/24";

The ``core`` section of ``vars/main.yml`` is similar to that used in
other blueprints, with two variable settings of note. First,
``ran_subnet`` is set to ``"172.20.0.0/16"`` and not the empty string
(``""``). As a general rule, ``core.ran_subnet`` is set to the empty
string whenever a physical gNB is on the same L2 network as the Core,
but in the case of an OAI-based gNB, the RAN stack runs in a
Macvlan-connected Docker container, and so the variable is set to
``"172.20.0.0/16"``.  (This is similar to how OnRamp configures the
Core for an emulated gNB using gNBsim.)

Second, variable ``values_file`` is set to
``"deps/5gc/roles/core/templates/sdcore-5g-values.yaml"`` by default,
meaning simulated UEs uses the same PLMN and IMSI range as gNBsim.
When deploying with physical UEs, it is necessary to replace that
values file with one that matches the SIM cards you plan to use. One
option is to reuse the values file also used by the :doc:`Physical RAN
</onramp/gnb>` blueprint, meaning you would set the variable as:

.. code-block::

   values_file: "deps/5gc/roles/core/templates/radio-5g-values.yaml"

That file should be edited, as necessary, to match your configuration.

To deploy the OAI blueprint in simulation mode, run the following:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make oai-gnb-install
   $ make oai-uesim-start

To deploy the OAI blueprint with a software-defined radio and physical
UE, first configure the USRP hardware as described in the USRP Hardware
Manual.

.. _reading_usrp:
.. admonition:: Further Reading

  `USRP Hardware Manual <https://files.ettus.com/manual/page_usrp_x3x0.html>`__.

Of particular note, you need to select whether the device is to
connect to the Aether Core using its 1-GigE or 10-GigE interface, and
make sure the OAI configuration file (corresponding to
``gnb.conf_file``) sets the ``sd_addrs`` variable to match the
interface you select. You also need to make sure the PLMN-related
values in the files specified by ``core.values_file`` and
``gnb.conf_file`` (along with the SIM cards you burn) are
consistent. Once ready, run the following Make targets:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make oai-gnb-install

The :doc:`Physical RAN </onramp/gnb>` section of this Guide can be
helpful in debugging the end-to-end setup, even though the gNB details
are different.

srsRAN 5G
~~~~~~~~~~~~~~~~~~~~

Aether can be configured to work with the open source gNB from srsRAN.
The blueprint supports the deployment of srsRAN in simulation mode, along
with USRP radios or in 7.2 split (DPDK mode) to connect to radio units (RUs).

The following assumes familiarity with the srsRAN 5G stack, but it is
**not** necessary to separately install the srsRAN stack. OnRamp
installs both the Aether Core and srsRAN, plus the networking needed
to interconnect the two.

.. _reading_srsran:
.. admonition:: Further Reading

   `srsRAN
   <https://docs.srsran.com/projects/project/en/latest/#>`__.

The blueprint includes the following:

* Global vars file ``vars/main-srsran.yml`` gives the overall blueprint
  specification.

* Inventory file ``hosts.ini`` uses label ``[srsran_nodes]`` to denote
  the server(s) that host the gNB and (when configured in simulation
  mode) the UE. The srsRAN blueprint installs the gNB and UE on one
  server, with the 5G Core running on a separate server. (Although not
  necessary in principle, the current playbooks require the gNB and
  simulated UE be located on the same server.)

* New make targets, ``srsran-gnb-install`` and ``srsran-gnb-uninstall``, to
  be executed along with the standard SD-Core installation (see  below).
  When running a simulated UE, targets ``srsran-uesim-start`` and
  ``srsran-uesim-stop`` are also available.

* A new submodule ``deps/srsran`` (corresponding to repo ``aether-srsran``)
  defines the Ansible Roles and Playbooks required to deploy the srsRAN
  gNB.

* The Jenkins pipeline ``srsran.groovy`` validates the srsRAN 5G
  blueprint. The pipeline runs srsRAN in simulation mode.

To use an srsRAN gNB, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-srsran.yml main.yml

You will see the main difference is the addition of the ``srsran``
section:

.. code-block::

   srsran:
     docker:
       container:
         gnb_image: aetherproject/srsran-gnb:rel-0.4.0
         ue_image: aetherproject/srsran-ue:rel-0.4.0
       network:
         name: host
         bridge:
           name: rfsim5g-public
     simulation: true
     servers:
       0: 
         gnb_conf: deps/srsran/roles/gNB/templates/gnb_zmq.conf
         gnb_ip: "172.20.0.2"
         ue_conf: deps/srsran/roles/uEsimulator/templates/ue_zmq.conf

Variable ``simulation`` is set to ``true`` by default, causing OnRamp
to deploy the simulated UE.  When set to ``false``, the simulated UE
is not deployed.

Note that instead of downloading and compiling the latest srsRAN
software, this blueprint pulls in the published images for both the
gNB and UE, corresponding to variables
``docker.container.gnb_image`` and ``docker.container.ue_image``,
respectively. If you plan to modify the srsRAN software, you will need to
change these values accordingly. See the :doc:`Development Support
</onramp/devel>` section for guidance.

The ``network`` block of the ``srsran`` section configures the necessary
tunnels so the gNB can connect to the Core's user and control planes.

The path names associated with variables ``gnb_conf`` and
``ue_conf`` are srsRAN-specific configuration files. The two
given by default are for simulation mode.

Note: we can deploy multiple srsRAN gNB's simultaneously by adding
as many servers under ``srsran.servers`` section.

The ``core`` section of ``vars/main.yml`` is similar to that used in
other blueprints, with two variable settings of note. First,
set ``ran_subnet`` to proper ran subnet as per your setup.
As a general rule, ``core.ran_subnet`` is set to the empty(``""``)
string whenever a physical gNB is on the same L2 network as the Core.

Second, variable ``values_file`` is set to
``"deps/5gc/roles/core/templates/sdcore-5g-values.yaml"`` by default,
meaning simulated UEs uses the same PLMN and IMSI range as gNBsim.
When deploying with physical UEs, it is necessary to replace that
values file with one that matches the SIM cards you plan to use. One
option is to reuse the values file also used by the :doc:`Physical RAN
</onramp/gnb>` blueprint, meaning you would set the variable as:

.. code-block::

   values_file: "deps/5gc/roles/core/templates/radio-5g-values.yaml"

That file should be edited, as necessary, to match your configuration.

To deploy the srsRAN blueprint in simulation mode, run the following:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make srsran-gnb-install
   $ make srsran-uesim-start

Non-3GPP Interworking Function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Aether can be configured to work with the open source Non-3GPP Interworking
Function (n3IWF) to allow internet connectivity to non-3GPP devices through
the 5G core network.

The following assumes familiarity with the N3IWF stack, but it is
**not** necessary to separately install the N3IWF NF. OnRamp
installs both the Aether Core and N3IWF, plus the networking needed
to interconnect the two.

The blueprint includes the following:

* Global vars file ``vars/main-n3iwf.yml`` gives the overall blueprint
  specification.

* Inventory file ``hosts.ini`` uses label ``[n3iwf_nodes]`` to denote
  the server(s) that host the N3IWF. The n3iwf blueprint installs the
  N3IWF on one server, with the 5G Core running on a separate server.

* New make targets, ``n3iwf-install`` and ``n3iwf-uninstall``, to
  be executed along with the standard SD-Core installation (see  below).

* A new submodule ``deps/n3iwf`` (corresponding to repo ``aether-n3iwf``)
  defines the Ansible Roles and Playbooks required to deploy the N3IWF.

To use/deploy a N3IWF instance, first copy the vars file to ``main.yml``:

.. code-block::

   $ cd vars
   $ cp main-n3iwf.yml main.yml

You will see the main difference is the addition of the ``n3iwf``
section:

.. code-block::

   n3iwf:
     docker:
       image: omecproject/5gc-n3iwf:rel-1.0.0
       network:
         name: host
     servers:
       0:
         conf_file: deps/n3iwf/roles/n3iwf/templates/n3iwf-default.yaml
         n3iwf_ip: "172.20.0.2"
         n2_ip: "172.20.0.2"
         n3_ip: "172.20.0.2"
         nwu_ip: "192.168.200.1/24"


Note that instead of downloading and compiling the latest N3IWF
software, this blueprint pulls in the published image corresponding
to variable ``docker.container.image``. If you plan to modify the N3IWF
software, you will need to change these values accordingly. See the
:doc:`Development Support </onramp/devel>` section for guidance.

The ``network`` block of the ``n3iwf`` section is meant to use the host's
network so the N3IWF can connect to the SD Core's user and control planes.

Note that the blueprint supports the deployment of multiple containerized
N3IWF instances and each instance is indicated as an index in the ``servers``
section.

The path names associated with variables ``conf_file`` is n3iwf-specific
configuration file that includes parameters such as PLMN, TAC, etc.

The ``core`` section of ``vars/main.yml`` is similar to that used in
other blueprints, with two variable settings of note. First,
set ``ran_subnet`` to proper ran subnet as per your setup.

Second, variable ``values_file`` is set to
``"deps/5gc/roles/core/templates/sdcore-5g-values.yaml"`` by default,
meaning simulated (N3IW)UEs use the same PLMN and IMSI range as gNBsim.
When deploying with physical UEs, it is necessary to replace that
values file with one that matches the SIM cards you plan to use. One
option is to reuse the values file also used by the :doc:`Physical RAN
</onramp/gnb>` blueprint, meaning you would set the variable as:

.. code-block::

   values_file: "deps/5gc/roles/core/templates/radio-5g-values.yaml"

That file should be edited, as necessary, to match your configuration.

To deploy the N3IWF blueprint, run the following:

.. code-block::

   $ make k8s-install
   $ make 5gc-install
   $ make n3iwf-install

Note that you need a UE that supports non-3GPP interworking.

Override Default N3 Subnet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, OnRamp manages an isolated subnet (``192.168.252.0/24``)
for the N3 interface. This prevents attaching gNBs on multiple subnets
and/or on subnets that are multiple hops away. This section describes
how to override this setting. It is not technically a self-contained
blueprint, but rather, a configuration option that can be applied to
any of the blueprints defined in this section.

The override requires setting variable ``core.upf.multihop_gnb`` to
``true``. This causes OnRamp to configure the UPF's N3 interface from
the same subnet as ``core.data_iface``. For example, suppose
``core.data_iface`` corresponds to subnet 10.21.61.0/24 and the gNB is
on subnet 10.202.1.0/24. Configure the parameters as follows:

.. code-block::

   data_iface: ens18
   ran_subnet: "10.202.1.0/24"
   upf:
      access_subnet: "10.21.61.1/24"		# access subnet & gateway
      core_subnet: "192.168.250.1/24"		# core subnet & gateway
      multihop_gnb: true			# N3 directly reachable via data_iface
      default_upf:
        ip:
          access: "10.21.61.12"			# same subnet as data_iface when multihop_gnb=true
          core:   "192.168.250.3"
        ue_ip_pool: "192.168.100.0/24"

To connect multiple gNBs on different subnets, you must also modify
the specified values file (e.g.,
``deps/5gc/roles/core/templates/sdcore-5g-values.yaml``) to add the
necessary routes. For example, if a second gNB is on 10.203.1.0/24,
then add the route as follows:

.. code-block::

   config:
     upf:
       routes:
         - to: {{ ansible_default_ipv4.address }}
           via: 169.254.1.1
         - to: 10.203.1.0/24
           via: 10.203.1.1

Guidelines for Blueprints
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Blueprints define alternate "on ramps" for using Aether. They are
intended to provide users with different starting points, depending on
the combination of features they are most interested in. The intent is
also that users eventually "own" their own customized blueprint, for
example by combining features from more than one of the set
distributed with OnRamp. Not all such combinations are valid, and not
all valid combinations have been been tested.  This is why there is
not currently one uber-blueprint that satisfies all requirements.

Users are encourage to contribute new blueprints to the official
release, for example by adding one or more new features/capabilities,
or possibly by demonstrating how to deploy a different combination of
existing features. In addition to meeting the general definition of a
blueprint (as introduced in the introduction to this section), we
recommend the following guidelines.

* Use Ansible best-practices for defining playbooks. This means using
  Ansible plugins rather than invoking shell scripts, whenever
  possible.

* Avoid embedding configuration parameters in Ansible playbooks.
  Such parameters should be collected in either ``vars/main-blueprint.yml``
  or a component-specific configuration file, depending on their
  purpose (see next item).

* Avoid exposing too many variables in
  ``vars/main-blueprint.yml``. Their main purpose is direct how
  Ansible deploys Aether, and not to configure the individual
  subsystems of a given deployment. The latter details are best
  defined in component-specific configuration files (e.g., values
  override files), which can then be referenced by
  ``vars/main-blueprint.yml``. The exception is variables that
  enable/disable a particular feature. Two good examples are
  ``core.standalone`` and ``oai.simulation``.

* Keep blueprints narrow. One of their main values is to document (in
  code) how a particular feature is enabled and configured. Introduce
  new roles to keep playbooks narrow.  Introduce new values override
  files (and other config files) to keep each configuration narrow.
  Introduce new ``vars/main-blueprint.yml`` files to document how a
  single feature is deployed. The exception is "combo" blueprints that
  combine multiple existing features (already enabled by
  single-feature blueprints) to deploy a comprehensive solution.




