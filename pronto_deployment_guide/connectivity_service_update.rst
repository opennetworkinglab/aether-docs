..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

===========================
Connectivity Control Update
===========================
At this point, Aether runtime and TOST should be ready.
But in order to make Aether connectivity control to serve the new ACE,
we need to create another patch to `aether-pod-configs` repository and update `omec-control-plane`.

.. attention::

   Note that this step will be done via ROC in the future.

Before you begin
================
Make sure you have the edge pod checklist ready.
Specifically, the following information is required in this section.

* MCC
* MNC
* TAC
* Subscriber IMSI list

Download aether-pod-configs repository
======================================
First, download the aether-pod-configs repository to your development machine.

.. code-block:: shell

   $ cd $WORKDIR
   $ git clone "ssh://[username]@gerrit.opencord.org:29418/aether-pod-configs"

Update OMEC control plane configs
=================================
Once you successfully download the `aether-pod-configs` repository to your local development machine
then move the directory to `aether-pod-configs/production/acc-gcp/app_values`
and edit `omec-control-plane.yml` file to add new user profile and subscribers for the new ACE.

Here is an example of the patch https://gerrit.opencord.org/c/aether-pod-configs/+/21396.
Please change MCC, MNC, TAC and IMSI in the example accordingly to match the new ACE.
Also, change FQDN of the `pfcp-agent` service of the target ACE cluster as `user-plane` value
and `UE_DNS` address as `dns_primary` value.

.. code-block:: diff

   $ cd $WORKDIR/aether-pod-configs/production/acc-gcp/app_values
   $ vi omec-control-plane.yml
   # Add the new ACE user profile and subscribers

   $ git diff
   diff --git a/production/acc-gcp/app_values/omec-control-plane.yml b/production/acc-gcp/app_values/omec-control-plane.yml
   index 24d19d9..0350fc1 100644
   --- a/production/acc-gcp/app_values/omec-control-plane.yml
   +++ b/production/acc-gcp/app_values/omec-control-plane.yml
   @@ -76,6 +76,17 @@ config:
                  - access-all
               selected-apn-profile: "apn-internet-menlo"
               selected-qos-profile: "qos-profile1"
   +          - selected-user-plane-profile: "test"
   +            keys:
   +              serving-plmn:
   +                mcc: 315
   +                mnc: 10
   +                tac: 205
   +            priority: 5
   +            selected-access-profile:
   +              - access-all
   +            selected-apn-profile: "apn-internet-test"
   +            selected-qos-profile: "qos-profile1"
            user-plane-profiles:
            onf-tucson:
               user-plane: "upf.omec.svc.prd.tucson.aetherproject.net"
   @@ -87,6 +98,8 @@ config:
               user-plane: "upf.omec.svc.prd.intel.aetherproject.net"
            menlo:
               user-plane: "pfcp-agent.omec.svc.prd.menlo.aetherproject.net"
   +          test:
   +            user-plane: "pfcp-agent.omec.svc.prd.new.aetherproject.net"
            apn-profiles:
            apn-internet-default:
               apn-name: "internet"
   @@ -120,6 +133,14 @@ config:
               dns_primary: "10.59.128.11"
               dns_secondary: "1.1.1.1"
               mtu: 1460
   +          apn-internet-test:
   +            apn-name: "internet"
   +            usage: 1
   +            network: "lbo"
   +            gx_enabled: true
   +            dns_primary: "10.54.128.11"
   +            dns_secondary: "1.1.1.1"
   +            mtu: 1460
      mme:
      cfgFiles:
         config.json:
   @@ -206,6 +227,14 @@ config:
            key: "ACB9E480B30DC12C6BDD26BE882D2940"
            opc: "F5929B14A34AD906BC44D205242CD182"
            sqn: 135
   +        # test
   +        - imsiStart: "315010102000001"
   +          msisdnStart: "9999234455"
   +          count: 30
   +          apn: "internet"
   +          key: "ACB9E480B30DC12C6BDD26BE882D2940"
   +          opc: "F5929B14A34AD906BC44D205242CD182"
   +          sqn: 135
         mmes:
            - id: 1
            mme_identity: "mme.omec.svc.prd.acc.gcp.aetherproject.net"

   $ git add .
   $ git commit -m “Update OMEC control plane for the new ACE”
   $ git review


Add subscribers to HSSDB
========================
Attach to one of the **cassandra-0** pod and run `hss-add-user.sh` script to add the subscribers.

.. code-block:: shell

   $ kubectl exec -it cassandra-0 /bin/bash -n omec
   # hss-add-user.sh arguments
   # count=${1}
   # imsi=${2}
   # msisdn=${3}
   # apn=${4}
   # key=${5:-'000102030405060708090a0b0c0d0e0f'}
   # opc=${6:-'69d5c2eb2e2e624750541d3bbc692ba5'}
   # sqn=${7:-'135'}
   # cassandra_ip=${8:-'localhost'}
   # mmeidentity=${9:-'mme.omec.svc.prd.acc.gcp.aetherproject.net'}
   # mmerealm=${10:-'omec.svc.prd.acc.gcp.aetherproject.net'}

   $ root@cassandra-0:/# ./hss-add-user.sh 30 315010102000001 9999234455 internet
