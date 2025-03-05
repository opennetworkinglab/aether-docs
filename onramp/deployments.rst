Deployment usecase's
-----------------------

This section documents various onramp deployment usecase's.

Multihop GNB
~~~~~~~~~~~~~~~~~~~~~~

By default onramp uses isolated networks for the N3(ex: 192.168.252.x) and
N6(ex: 192.168.250.x) interfaces. This prevents GNB(which is on different
subnet and located multiple hops away) connecting to the UPF on N3 interface.

In order to support such deployment onramp provides an option to configure
N3 IP from the same subnet as DATA_IFACE. It can be enabled by setting
``core.upf.multihop_gnb: true``

For ex, lets say the DATA_IFACE subnet is 10.21.61.0/24 and GNB subnet
is 10.202.1.0/24. Configure the parameters as follows,

.. code-block::

   data_iface: ens18
   ran_subnet: "10.202.1.0/24"
   upf:
      access_subnet: "10.21.61.1/24"	# access subnet & gateway
      core_subnet: "192.168.250.1/24"	# core subnet & gateway
      multihop_gnb: true
      default_upf:
        ip:
          access: "10.21.61.12" # when multihop_gnb set to true, make sure to assign IP from same subnet of data_iface
          core:   "192.168.250.3"
        ue_ip_pool: "172.250.0.0/16"

In case if we need to connect multiple GNB's (GNB2 subnet: 10.203.1.0/24)
from different subnet then add routes as follows
in ``deps/5gc/roles/core/templates/sdcore-5g-values.yaml`` ``(if core.upf.mode: af_packet)``:
in ``deps/5gc/roles/core/templates/sdcore-5g-sriov-values.yaml`` ``(if core.upf.mode: dpdk)``:

.. code-block::

   config:
     upf:
       routes:
         - to: {{ ansible_default_ipv4.address }}
           via: 169.254.1.1
         - to: 10.203.1.0/24
           via: 10.203.1.1

