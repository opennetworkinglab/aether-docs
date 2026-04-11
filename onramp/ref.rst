Quick Reference
-----------------

This guide provides a quick reference for all the blueprints OnRamp
defines for Aether. It assumes a general familiarity with
:doc:`OnRamp</onramp/overview>`, and a specific understanding of how
OnRamp uses :doc:`blueprints</onramp/blueprints>` to configure target
deployments of Aether.

Blueprint Specification
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The specification for every Aether blueprint is anchored in an Ansible
variable file (e.g., ``vars/main-<blueprint>.yml``).

The blueprint names in the first column of the following table link
the relevant OnRamp documentation. The vars files can be found in the
`aether-onramp <https://github.com/opennetworkinglab/aether-onramp>`__
repo.


.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - Name
     - Vars File
     - Description
   * - :doc:`Quick Start </onramp/start>`
     - `main-quickstart.yml`
     - Minimal configuration running in a single server or VM.
   * - :doc:`Emulated RAN </onramp/gnbsim>`
     - `main-gnbsim.yml`
     - Scalable 5G Control Plane workload from gNBsim directed at 5G Core.
   * - :doc:`Physical gNB </onramp/gnb>`
     - `main-gNB.yml`
     - Physical 5G small cell radio connected to 5G Core; demonstrated with
       MOSO CANOPY 5G indoor small cell.
   * - `Multiple UPFs <https://docs.aetherproject.org/onramp/blueprints.html#multiple-upfs>`__
     - `main-upf.yml`
     - Instantiate multiple UPFs and bind them to distinct Slices.
   * - `SD-RAN (RIC) <https://docs.aetherproject.org/onramp/blueprints.html#sd-ran-ric>`__
     - `main-sdran.yml`
     - SD-RAN (with RANSIM traffic) connected to 5G Core.
   * - `UERANSIM <https://docs.aetherproject.org/onramp/blueprints.html#ueransim>`__
     - `main-ueransim.yml`
     - UERANSIM (with ``iperf`` traffic) connected to 5G Core.
   * - `Physical eNB <https://docs.aetherproject.org/onramp/blueprints.html#physical-enbs>`__
     - `main-eNB.yml`
     - Physical 4G small cell radio connected to 4G Core; demonstrated with
       Sercomm indoor small cell.
   * - `SR-IOV/DPDK <https://docs.aetherproject.org/onramp/blueprints.html#enable-sr-iov-and-dpdk>`__
     - `main-sriov.yml`
     - 5G Core with `core.upf.mode` set to `dpdk`, enabling SR-IOV and DPDK optimizations for the user plane.
   * - `OAI 5G RAN <https://docs.aetherproject.org/onramp/blueprints.html#oai-5g-ran>`__
     - `main-oai.yml`
     - OAI software radio connected to 5G Core.
   * - `srsRAN 5G <https://docs.aetherproject.org/onramp/blueprints.html#srsran-5g>`__
     - `main-srsran.yml`
     - srsRAN software radio connected to 5G Core.
   * - `OCUDU <https://docs.aetherproject.org/onramp/blueprints.html#ocudu>`__
     - `main-ocudu.yml`
     - OCUDU software radio connected to 5G Core.
   * - `N3IWF <https://docs.aetherproject.org/onramp/blueprints.html#non-3gpp-interworking-function>`__
     - `main-n3iwf.yml`
     - N3IWF connected to 5G Core to provide internet access to non-3GPP devices.


Ansible Variables
~~~~~~~~~~~~~~~~~~~~

The Ansible ``vars/main-<blueprint>.yml`` file associated with each
blueprint defines the high-level parameters used to configure Aether.
The following identifies the key variables users are likely to modify;
the list is not comprehensive.

.. list-table::
   :widths: 25 25 50
   :header-rows: 1

   * - Variable
     - Default
     - Description
   * - `core.ran_subnet`
     - `172.20.0.0/16`
     - Overlay subnet connecting Core to RAN when gNBs run in a container; set to empty string ("") when gNBs are directly connected via `core.data_iface`.
   * - `core.standalone`
     - `true`
     - Core to run standalone, initialized from values file; set to `false` when Core is to be initialized by ROC.
   * - `core.data_iface`
     - `ens18`
     - Network interface used by UPF; same as `gnbsim.data_iface` when co-located on a single server.
   * - `core.amf.ip`
     - `"10.76.28.113"`
     - IP address of AMF; edit to match IP address assigned to `core.data_iface`.
   * - `core.upf.mode`
     - `af_packet`
     - UPF datapath mode; set to `dpdk` to enable the integrated SR-IOV/DPDK rendering in the core and additional-UPF templates.
   * - `core.upf.multihop_gnb`
     - `false`
     - Override default N3 interface; set to `true` when external gNB is multiple hops away.
   * - `gnbsim.data_iface`
     - `ens18`
     - Network interface used by gNBsim; same as `core.data_iface` when co-located on a single server.
   * - `oai.simulation`
     - `true`
     - Run UE in simulation mode; set to `false` to connect real UEs.
   * - `srsran.simulation`
     - `true`
     - Run UE in simulation mode; set to `false` to connect real UEs.
   * - `ocudu.simulation`
     - `true`
     - Run UE in simulation mode; set to `false` to deploy OCUDU without the simulated UE.
   * - `*.helm.local_charts`
     - `false`
     - Loads Helm Charts from public repo; set to `true` to utilize
       local charts, with `*.helm.charts_ref` set to local path name.

In addition to the variables listed in the preceding table, the vars
file also references other configuration files required by each
component. These include values override files used by Helm,
along with other ad hoc files directly processed by the component.
Note that alternative config files used by other blueprints are often
available in the same directory. Edit these variable settings to
substitute custom config files.

.. list-table::
   :widths: 25 50
   :header-rows: 1

   * - Variable
     - Default Path Name
   * - `amp.monitor_dashboard`
     - `deps/amp/roles/monitor-load/templates/5g-monitoring/`
   * - `amp.roc_models`
     - `deps/amp/roles/roc-load/templates/roc-5g-models.json`
   * - `core.values_file`
     - `deps/5gc/roles/core/templates/sdcore-5g-values.yaml`
   * - `gnbsim.servers[0]`
     - `deps/gnbsim/config/gnbsim-default.yaml`
   * - `k8s.rke2.config.params_file.master`
     - `deps/k8s/roles/rke2/templates/master-config.yaml`
   * - `k8s.rke2.config.params_file.worker`
     - `deps/k8s/roles/rke2/templates/worker-config.yaml`
   * - `oai.servers[0].gnb_conf`
     - `deps/oai/roles/gNb/templates/gnb.sa.band78.fr1.106PRB.usrpb210.conf`
   * - `oai.servers[0].ue_conf`
     - `deps/oai/roles/uEsimulator/templates/ue.conf`
   * - `srsran.servers[0].gnb_conf`
     - `deps/srsran/roles/gNB/templates/gnb_zmq.yaml`
   * - `srsran.servers[0].ue_conf`
     - `deps/srsran/roles/uEsimulator/templates/ue_zmq.conf`
   * - `ocudu.servers[0].gnb_conf`
     - `gnb_zmq.yaml`
   * - `ocudu.servers[0].ue_conf`
     - `ue_zmq.conf`
   * - `n3iwf.servers[0].conf_file`
     - `deps/n3iwf/roles/n3iwf/templates/n3iwf-default.yaml`
   * - `ueransim.servers`
     - `deps/ueransim/config/custom-gnb.yaml`
   * -
     - `deps/ueransim/config/custom-ue.yaml`


Host Inventory
~~~~~~~~~~~~~~~~~~~

Each blueprint is deployed to the set of servers identified in an
Ansible inventory file (``hosts.ini``). The following identifies the
`host groups` that OnRamp currently supports.

.. list-table::
   :widths: 25 50
   :header-rows: 1

   * - Host Group
     - Description
   * - `[master_nodes]`
     - Servers hosting Kubernetes Controller.
   * - `[worker_nodes]`
     - Worker servers in Kubernetes Cluster.
   * - `[gnbsim_nodes]`
     - Servers hosting gNBsim containers.
   * - `[ueransim_nodes]`
     - Servers hosting UERANSIM process.
   * - `[oai_nodes]`
     - Servers hosting OAI gNB (and optionally UE) containers.
   * - `[srsran_nodes]`
     - Servers hosting srsRAN gNB (and optionally UE) containers.
   * - `[ocudu_nodes]`
     - Servers hosting OCUDU gNB (and optionally UE) containers.
   * - `[n3iwf_nodes]`
     - Servers hosting N3IWF containers.

The `[worker_nodes]` group can be empty, but must be present.  The
other groups are blueprint-specific, and with the exception of
`[ueransim_nodes]`, may be the same as the `[master_nodes]`, making it
possible for the blueprint to require only a single server.

Make Targets
~~~~~~~~~~~~~~~~~

OnRamp executes blueprints through a set of Make Targets.  The
following table identifies the Aether-wide targets used by the
Quick Start Blueprint.

.. list-table::
   :widths: 25 50
   :header-rows: 1

   * - Target
     - Description
   * - `aether-k8s-install`
     - Install RKE2 and Helm.
   * - `aether-k8s-uninstall`
     - Uninstall RKE2 Kubernetes and Helm.
   * - `aether-5gc-install`
     - Install 5G Core workload; includes bridges for networking.
   * - `aether-5gc-uninstall`
     - Uninstall 5G Core workload; includes bridges for networking.
   * - `aether-5gc-reset`
     - Delete and reinstall 5G Core workload; leaves network bridges untouched.
   * - `aether-gnbsim-install`
     - Install gNBsim containers.
   * - `aether-gnbsim-uninstall`
     - Uninstall gNBsim containers.
   * - `aether-gnbsim-run`
     - Run gNBsim containers; may rerun multiple times without reinstalling.
   * - `aether-amp-install`
     - Installs and initializes both ROC and Monitoring workloads.
   * - `aether-amp-uninstall`
     - Uninstalls both ROC and Monitoring workloads.

Other blueprints define component-specific targets, as listed in the
following table. (The Aether-wide targets can also be used for all
other blueprints.)

**All Blueprints**

.. list-table::
   :widths: 25 50

   * - `roc-install`
     - Install ROC workload.
   * - `roc-load`
     - Load model values into ROC; assumes ROC already deployed.
   * - `roc-uninstall`
     - Uninstall ROC workload.
   * - `monitor-install`
     - Install Monitor workload.
   * - `monitor-load`
     - Load dashboard panels into Monitor; assumes Monitor already deployed.
   * - `monitor-uninstall`
     - Uninstall Monitor workload.

**SD-RAN Blueprint**

.. list-table::
   :widths: 25 50

   * - `sdran-install`
     - Install SD-RAN workload; assumes Core already deployed.
   * - `sdran-uninstall`
     - Uninstall SD-RAN workload.

**UERANSIM Blueprint**

.. list-table::
   :widths: 25 50

   * - `ueransim-install`
     - Install UERANSIM emulated RAN; assumes Core already deployed.
   * - `ueransim-uninstall`
     - Uninstall UERANSIM emulated RAN.
   * - `ueransim-run`
     - Run UERANSIM UE to generate User Plane traffic for the Core.

**OAI 5G RAN Blueprint**

.. list-table::
   :widths: 25 50

   * - `oai-gnb-install`
     - Install container running OAI 5G RAN radio; assumes Core already deployed.
   * - `oai-gnb-uninstall`
     - Uninstall OAI 5G RAN container.
   * - `oai-uesim-start`
     - Start container running OAI simulated UE.
   * - `oai-uesim-stop`
     - Stop container running OAI simulated UE.

**srsRAN 5G Blueprint**

.. list-table::
   :widths: 25 50

   * - `srsran-gnb-install`
     - Install container running srsRAN 5G radio; assumes Core already deployed.
   * - `srsran-gnb-uninstall`
     - Uninstall srsRAN 5G radio container.
   * - `srsran-uesim-start`
     - Start container running srsRAN simulated UE.
   * - `srsran-uesim-stop`
     - Stop container running srsRAN simulated UE.

**OCUDU Blueprint**

.. list-table::
   :widths: 25 50

   * - `ocudu-gnb-install`
     - Install container running OCUDU gNB; assumes Core already deployed.
   * - `ocudu-gnb-uninstall`
     - Uninstall OCUDU gNB container.
   * - `ocudu-uesim-start`
     - Start container running the simulated srsRAN UE for OCUDU.
   * - `ocudu-uesim-stop`
     - Stop container running the simulated srsRAN UE for OCUDU.

**N3IWF Blueprint**

.. list-table::
   :widths: 25 50

   * - `n3iwf-install`
     - Install N3IWF; assumes Core already deployed.
   * - `n3iwf-uninstall`
     - Uninstall N3IWF.

**Multi-UPF Blueprint**

.. list-table::
   :widths: 25 50

   * - `5gc-upf-install`
     - Install additional UPF pods; assumes Core already deployed.
   * - `5gc-upf-uninstall`
     - Uninstall additional UPF pods.

Network Subnets
~~~~~~~~~~~~~~~~~~~~~~

OnRamp configures a set of subnets in support of a given Aether
deployment. The following subnets are defined in ``vars/main.yml``.
With the exception of ``core.ran_subnet``, these variables typically
do not need to be modified for an initial deployment of a blueprint.

.. list-table::
   :widths: 20 25 50
   :header-rows: 1

   * - IP Subnet
     - Ansible Variable
     - Description
   * - `172.20.0.0/16`
     - ``aether.ran_subnet``
     - Assigned to container-based gNBs connecting to the Core via an
       overlay subnet. Other gNB implementations connect to the Core
       over the subnet assigned to the server's physical interface (as
       defined by ``core.data_iface``).
   * - `192.168.250.0/24`
     - ``core.upf.core_subnet``
     - Assigned to `core` bridge that connects UPF(s) to the Internet.
   * - `192.168.252.0/24`
     - ``core.upf.access_subnet``
     - Assigned to `access` bridge that connects UPF(s) to the RAN.
   * - `192.168.100.0/24`
     - ``core.default_upf.ue_ip_pool``
     - Assigned (by the Core) to UEs connecting to Aether. When
       multiple UPFs are deployed—in addition to
       ``core.default_upf``\ —each is assigned its own ``ue_ip_pool``
       subnet.
   * - `10.76.28.0/24`
     - N/A
     - Used throughout OnRamp documentation as an exemplar for the
       local subnet on which Aether severs and radios are deployed.
       Corresponds to the network interface defined by variable ``core.data_iface``.
