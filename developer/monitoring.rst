..
   SPDX-FileCopyrightText: © 2021 Open Networking Foundation <support@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

Monitoring Development
================================

Aether leverages `Prometheus <https://prometheus.io/docs/introduction/overview/>`_ to collect
and store platform and service metrics, `Grafana <https://grafana.com/docs/grafana/latest/getting-started/>`_
to visualize metrics over time, and `Alertmanager <https://prometheus.io/docs/alerting/latest/alertmanager/>`_ to
notify Aether operators of events requiring attention.  This monitoring stack is running on each Aether cluster.
This section describes how an Aether component can "opt in" to the Aether monitoring stack so that its metrics can be
collected and graphed, and can trigger alerts.


Exporting Service Metrics to Prometheus
---------------------------------------

An Aether component implements a `Prometheus exporter <https://prometheus.io/docs/instrumenting/writing_exporters/>`_
to expose its metrics to Prometheus.  An exporter provides the current values of a components's
metrics via HTTP using a simple text format.  Prometheus scrapes the exporter's HTTP endpoint and stores the metrics
in its Time Series Database (TSDB) for querying and analysis.  Many `client libraries <https://prometheus.io/docs/instrumenting/clientlibs/>`_
are available for instrumenting code to export metrics in Prometheus format.  If a component's metrics are available
in some other format, tools like `Telegraf <https://docs.influxdata.com/telegraf>`_ can be used to convert the metrics
into Prometheus format and export them.

A component that exposes a Prometheus exporter HTTP endpoint via a Service can tell Prometheus to scrape
this endpoint by defining a
`ServiceMonitor <https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/running-exporters.md>`_
custom resource.  The ServiceMonitor is typically created by the Helm chart that installs the component.


Working with Grafana Dashboards
--------------------------------

Once the local cluster's Prometheus is collecting a component's
metrics, they can be visualized using Grafana dashboards.  The Grafana
instance running on the AMP cluster is able to send queries to the
Prometheus servers running on all Aether clusters.  This means that
component metrics can be visualized on the AMP Grafana regardless of
where the component is actually running.

In order to create a new Grafana dashboard or modify an existing one,
first login to the AMP Grafana using an account with admin privileges.
To add a new dashboard, click the **+** at left.  To make a copy of an
existing dashboard for editing, click the **Dashboard Settings** icon
(gear icon) at upper right of the existing dashboard, and then click
the **Save as…** button at left.

Next, add panels to the dashboard.  Since Grafana can access
Prometheus on all the clusters in the environment, each cluster is
available as a data source.  For example, when adding a panel showing
metrics collected on the ace-menlo cluster, choose ace-menlo as the
data source.

Clicking on the floppy disk icon at top will save the dashboard
*temporarily* (the dashboard is not saved to persistent storage and is
deleted as soon as Grafana is restarted).  To save the dashboard
*permanently*, click the **Share Dashboard** icon next to the title
and save its JSON to a file.  Then add the file to the
AMP submodule of OnRamp so that it will be deployed by Ansible:

* Change to directory ``aeher-onramp/deps/amp/roles/monitor-load/templates/``
* Copy the dashboard JSON file to the ``dashboards/`` sub-directory
* Edit ``kustomization.yaml`` and add the new dashboard JSON under ``configmapGenerator``

Adding Service-specific Alerts
------------------------------

An alert can be triggered in Prometheus when a component metric crosses a threshold.  The Alertmanager
then routes the alert to one or more receivers (e.g., an email address
or Slack channel).

.. note:: This section on alerts is specific to an operational
   instantiation of Aether that is no longer supported. A port of this
   capability to Aether OnRamp (so it is available to anyone that
   wants to operate Aether) is pending.

To add an alert for a component, create a
`PrometheusRule <https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/alerting.md>`_
custom resource, for example in the Helm chart that deploys the component.  This resource describes one or
more `rules <https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/>`_ using Prometheus expressions;
if the expression is true for the time indicated, then the alert is raised. Once the PrometheusRule
resource is instantiated, the cluster's Prometheus will pick up the rule and start evaluating it.

The Alertmanager is configured to send alerts with *critical* or *warning* severity to e-mail and Slack channels
monitored by Aether OPs staff.  If it is desirable to route a specific alert to a different receiver
(e.g., a component-specific Slack channel), it is necessary to change the Alertmanager configuration. This is stored in
a `SealedSecret <https://github.com/bitnami-labs/sealed-secrets>`_ custom resource in the aether-app-configs repository.
To update the configuration:

* Change to directory ``aether-app-configs/infrastructure/rancher-monitoring/overlays/<cluster>/``
* Update the ``receivers`` and ``route`` sections of the ``alertmanager-config.yaml`` file
* Encode the ``alertmanager-config.yaml`` file as a Base64 string
* Create a file ``alertmanager-config-secret.yaml`` to define the Secret resource using the Base64-encoded string
* Run the following command using a valid ``PUBLICKEY``:

.. code-block:: shell

   $ kubeseal --cert "${PUBLICKEY}" --scope cluster-wide --format yaml < alertmanager-config-secret.yaml > alertmanager-config-sealed-secret.yaml

* Commit the changes and submit patchset to gerrit

Once the patchset is merged, verify that the SealedSecret was successfully unsealed and converted to a Secret
by looking at the logs of the *sealed-secrets-controller* pod running on the cluster in the *kube-system* namespace.
