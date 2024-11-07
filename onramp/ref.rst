Quick Reference
-----------------

This guide provides a quick reference for all the blueprints OnRamp
defines for Aether. It assumes a general familiarity with
:doc:`OnRamp</onramp/overview>`, and a specific understanding of how
OnRamp uses :doc:`blueprints</onramp/blueprints>` to configure target
deployments of Aether.

Blueprint Specification
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The specification for every Aether blueprint is rooted in an Ansible
variable file (e.g., ``vars/main-blueprint.yml``).  Most blueprints
also include a Jenkins pipeline (e.g., ``blueprint.groovy``) that
illustrates how the blueprint is deployed and validated.

The blueprint names in the first column of the following table link
the relevant OnRamp documentation. The vars files can be found in the
`aether-onramp <https://github.com/opennetworkinglab/aether-onramp>`__
repo. The groovy files can be found in the `aether-jenkins
<https://github.com/opennetworkinglab/aether-onramp>`__ repo.


.. list-table::
   :widths: 20 20 20 40
   :header-rows: 1

   * - Name
     - Vars File
     - Jenkins Pipeline
     - Description
   * - :doc:`Quick Start </onramp/start>`
     - `main-quickstart.yml`
     - `quickstart.groovy`
     - Minimal configuration running in a single server or VM.
   * - :doc:`Emulated RAN </onramp/gnbsim>`
     - `main-gnbsim.yml`
     - `gnbsim.groovy`
     - Scalable 5G Control Plane workload from gNBsim directed at 5G Core.
   * - :doc:`Physical gNB </onramp/gnb>`
     - `main-gNB.yml`
     - N/A
     - Physical 5G small cell radio connected to 5G Core; demonstrated with
       MOSO CANOPY 5G indoor small cell.
   * - `Multiple UPFs <https://docs.aetherproject.org/master/onramp/blueprints.html#multiple-upfs>`__
     - `main-upf.yml`
     - `upf.groovy`
     - Instantiate multiple UPFs and bind them to distinct Slices.
   * - `SD-RAN (RIC) <https://docs.aetherproject.org/master/onramp/blueprints.html#sd-ran-ric>`__
     - `main-sdran.yml`
     - `sdran.groovy`
     - SD-RAN (with RANSIM traffic) connected to 5G Core.
   * - `UERANSIM <https://docs.aetherproject.org/master/onramp/blueprints.html#ueransim>`__
     - `main-ueransim.yml`
     - `ueransim.groovy`
     - UERANSIM (with ``iperf`` traffic) connected to 5G Core.
   * - `Physical eNB <https://docs.aetherproject.org/master/onramp/blueprints.html#physical-enbs>`__
     - `main-eNB.yml`
     - N/A
     - Physical 4G small cell radio connected to 4G Core; demonstrated with
       Sercomm indoor small cell.
   * - `SR-IOV/DPDK <https://docs.aetherproject.org/master/onramp/blueprints.html#enable-sr-iov-and-dpdk>`__
     - `main-sriov.yml`
     - N/A
     - 5G Core with SR-IOV and DPDK optimizations enabled for User Plane.
   * - `OAI 5G RAN <https://docs.aetherproject.org/master/onramp/blueprints.html#oai-5g-ran>`__
     - `main-oai.yml`
     - `oai.groovy`
     - OAI software radio connected to 5G Core.


Ansible Variables
~~~~~~~~~~~~~~~~~~~~

The Ansible ``vars/main-blueprint.yml`` file associated with each
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
     - Subnet connecting Core to RAN when gNBs run in a container; set to empty string ("") when gNBs are directly connected via `core.data_iface`.
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
     - Socket mode for `core.data_iface`; set to `dpdk` to enable DPDK and SR-IOV optimizations.
   * - `gnbsim.data_iface`
     - `ens18`
     - Network interface used by gNBsim; same as `core.data_iface` when co-located on a single server.
   * - `oai.simulation`
     - `true`
     - Run UE in simulation mode; set to `false` to connect real UEs.
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
   * - `gnbsim.server`
     - `deps/gnbsim/config/gnbsim-default.yaml/`
   * - `k8s.rke2.config.params_file.master`
     - `deps/k8s/roles/rke2/templates/master_config.yaml`
   * - `k8s.rke2.config.params_file.worker`
     - `deps/k8s/roles/rke2/templates/worker_config.yaml`
   * - `oai.gnb.conf_file`
     - `deps/oai/roles/gNb/templates/gnb.sa.band78.fr1.106PRB.usrpb210.conf`
   * - `oai.ue.conf_file`
     - `deps/oai/roles/uEsimulator/templates/ue.conf`
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
     - Servers hosting gNBsim container(s).
   * - `[ueransim_nodes]`
     - Servers hosting UERANSIM process.
   * - `[oai_nodes]`
     - Servers hosting OAI gNB (and optionally UE) container(s).

The `[worker_nodes]` group can be empty, but must be present.  The
other groups are blueprint-specific, and with the exception of
`[ueransim_nodes]`, may be the same as the `[master_nodes]`, making it
possible for the blueprint to require only a single server.

Make Targets
~~~~~~~~~~~~~~~~~

OnRamp executes blueprints through a set of Make Targets.  The
following table identifies the Aether-wide targets used by the
QuickStart Blueprint.

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
   * - `aether-resetcore`
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

.. list-table::
   :widths: 25 50
   :header-rows: 1

   * - Target
     - Description
   * - **All Blueprints**
     -
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
   * - **SD-RAN Blueprint**
     -
   * - `sdran-install`
     - Install SD-RAN workload; assumes Core already deployed.
   * - `sdran-uninstall`
     - Uninstall SD-RAN workload.
   * - **UERANSIM Blueprint**
     -
   * - `ueransim-install`
     - Install UERANSIM emulated RAN; assumes Core already deployed.
   * - `ueransim-uninstall`
     - Uninstall UERANSIM emulated RAN.
   * - `ueransim-run`
     - Run UERANSIM UE to generate User Plane traffic for the Core.
   * - **OAI 5G RAN Blueprint**
     -
   * - `oai-gnb-install`
     - Install container running OAI 5G RAN radio; assumes Core already deployed.
   * - `oai-gnb-uninstall`
     - Uninstall OAI 5G RAN container.
   * - `oai-uesim-start`
     - Start container running OAI simulated UE.
   * - `oai-uesim-stop`
     - Stop container running OAI simulated UE.
   * - **Multi-UPF Blueprint**
     -
   * - `5gc-upf-install`
     - Install additional UPF pods; assumes Core already deployed.
   * - `5gc-upf-uninstall`
     - Uninstall additional UPF pods.

Network Subnets
~~~~~~~~~~~~~~~~~~~~~~

OnRamp utilizes a set of subnets, all of which are defined in
``vars/main.yml``.  These values do not typically need to be modified
to deploy a blueprint, but can be if local circumstances dictate.

.. list-table::
   :widths: 20 25 50
   :header-rows: 1

   * - IP Subnet
     - Ansible Variable
     - Description
   * - `172.20.0.0/16`
     - ``core.ran_subnet``
     - Assigned to container-based gNBs connecting to the Core. Other
       gNB implementations connect to the Core over the subnet
       assigned to the server's physical interface (as denoted by
       ``core.data_iface``). Note that variable
       ``gnbsim.router.macvlan.subnet_prefix`` must be a prefix of
       ``core.ran_subnet`` (if set).
   * - `192.168.250.1/24`
     - ``core.upf.core_subnet``
     - Assigned to `core` bridge that connects UPF(s) to the
       Internet.  Doubles as the address of the gateway on that
       bridge that forwards between the UPF pod and the "outside" world.
   * - `192.168.252.1/24`
     - ``core.upf.access_subnet``
     - Assigned to `access` bridge that connects UPF(s) to the
       RAN. Doubles as the address of the gateway on that bridge that
       forwards between the UPF pod and the "outside" world.
   * - `172.250.0.0/16`
     - ``core.upf.default_upf.ue_ip_pool``
     - Assigned (by the Core) to UEs connecting to Aether.
   * - `10.76.28.0/24`
     - N/A
     - Used as an exemplar for the local network throughout the OnRamp
       documentation.

Note that when multiple UPFs are deployed—in addition to
``core.upf.default_upf``\ —each is assigned its own ``ip.core`` and
``ip.access`` addresses; they must be on the ``core.upf.core_subnet``
and ``core.upf.access_subnet`` subnets, respectively. Each additional UPF
is also assigned its own ``ue_ip_pool`` subnet.
