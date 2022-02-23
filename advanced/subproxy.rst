..
   SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Subscriber Proxy
================

The Aether subscriber proxy is a component that sits between the SD-Core's simapp
SIM card management subsystem and the SD-Core's configuration service, and communicates
newly provisioned SIM cards to the ROC.

.. image:: images/subproxy.svg
  :width: 400

How Subscriber Proxy Works
--------------------------

The subscriber proxy transparently intercepts simapp traffic and inspects each message for
the IMSI that is contained in that message. If the IMSI is a new one that is not
already present in the ROC, then the subscriber proxy will contact the ROC to insert a
Sim-Card object with that IMSI.

The subscriber proxy will attempt to insert the SIM Card into the appropriate site. It does
this by examining the `imsi-definition` for each site, until subscriber proxy finds a
site whose `mcc`, `mnc`, and `enterprise` match the IMSI that has been intercepted
from simapp. For this to work, the `imsi-format` must be set appropriately, for example
to `CCCNNEESSSSSSSS`. Setting the `imsi-format` to `SSSSSSSSSSSSSSS` will not allow the
subscriber-proxy to automatically determine the site. If no matching site exists, then
the subscriber proxy will attempt to add the Sim-Card to a site whose identifier is
`defaultent-defaultsite`.

If no appropriate site can be determined, then the subscriber proxy will not add the
sim-card to the ROC, but the request will still be passed to SD-Core.

Configuring simapp
------------------

To configure simapp to send messages to the subscriber proxy, edit simapp's configuration
file as follows::

    simapp.yaml:
      configuration:
        sub-proxy-endpt:
          addr: subscriber-proxy.aether-roc.svc.cluster.local
          port: 5000

In the above example, `subscriber-proxy.aether-roc.svc.cluster.local` is the address of the
subscriber proxy. Do not remove the existing `sub-provision-endpt` as that setting contains
the address of the SD-Core, and will be passed through the proxy, so the proxy knows which
core to connect to.
