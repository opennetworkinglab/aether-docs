.. vim: syntax=rst

Aether ROC Control API
======================

Access
------
The ROC API specification can be accessed from the running ROC cluster at the API URL.

e.g. on a local system (if the GUI has been port-forwarded on port 8183)
*http://localhost:8183/aether-roc-api/*

For Aether-In-A-Box deployment the API can be found at *http://<hostname>:31194/aether-roc-api/*

On the Production system it would be *https://roc.aetherproject.org/aether-roc-api/*

.. note:: Opening this in a browser will display a HTML view of the API (powered by *ReDoc*).

    To access the raw YAML format use
    ``curl -H "Accept: application/yaml" http://localhost:8183/aether-roc-api/aether-2.0.0-openapi3.yaml``
    This YAML format can be imported in to various different tools e.g. |postman_link|

Background
----------

The Aether ROC control API is available via REST or via gNMI. It is expected that most external
consumers of the API will use REST.

The REST API supports the typical GET, POST, PATCH, DELETE operations:

* GET. Retrieve an object.
* POST. Create an object.
* PUT,  PATCH. Modify an existing object.
* DELETE. Delete an object.

Endpoints are named based on the type of object. Some examples:

* `GET http://roc/targets`. Get a list of enterprises.
* `GET http://roc/aether/v2.1.0/starbucks/application`. Get the list of applications in the Starbucks enterprise.
* `GET http://roc/aether/v2.1.0/starbucks/site`. Get the list of sites in the Starbucks enterprise.
* `GET http://roc/aether/v2.1.0/starbucks/site/starbucks-seattle`. Get details of the 'seattle' site in the Starbucks enterprise.
* `POST http://roc/aether/v2.1.0/starbucks/site/newsite`. Create a new (or update existing) site in the Starbucks enterprise.

This document is a high-level description of the objects that can be interacted with. For a
low-level description, see the specification (:ref:`developer/roc-api:Access` section above).

Enterprises
------------
The API is segmented by `enterprise`, as the Aether ROC is a multi Tenant system. Each of the URLs shown
above has an example enterprise built in to the path. If a valid enterprise is not given, the results will
be empty.

Identifying and Referencing Objects
-----------------------------------

Every object contains an `id` - for example, a site has a `site-id` and an slice has a
`slice-id`. The models are generally nested, for example `slice` is a member of `site`, which in
turn belongs to an `enterprise`.

In addition to an `id`, most identifiable objects also include a `display-name` and a `description`.
The `display-name` may be changed at any time by the user without affecting behavior. In contrast,
the `id` is immutable, and the only way to change an `id` is to delete the object and make a new one.

Some objects contain references to other objects. References
are constructed using the `id` field of the referenced object. It is an error to attempt to create
a reference to an object that does not exist. Deleting an object while there are open references
to it from other objects is also an error.

Common Model Fields
-------------------

Several fields are common to all models in Aether:

* `<objectname>-id`. The identifier for objects.
* `description`. A human-readable description, used to store additional context about the object.
* `display-name`. A human-readable name that is shown in the GUI.

As these fields are common to all objects, they will be omitted from the per-object descriptions below.

Key Aether Objects
------------------

The following is a list of Aether models elements (objects), generally organized in a top-down manner.

Site
~~~~

A site is a point of presence for an `Enterprise` and may be either physical or logical (i.e. a single
geographic location could in theory contain several logical sites). Site contains the following fields:

* `imsi-definition`. A description of how IMSIs are constructed for this site. Contains the following
  sub-fields:

   * `mcc`. Mobile country code.
   * `mnc`. Mobile network code.
   * `enterprise`. A numeric enterprise id.
   * `format`. A mask that allows the above three fields to be embedded into an IMSI. For example
     `CCCNNNEEESSSSSS` will construct IMSIs using a 3-digit MCC, 3-digit MNC, 3-digit ENT, and a
     6-digit subscriber.

* `monitoring` Configuration of how the monitoring framework of the site can be connected:

    * `edge-cluster-prometheus-url` the URL of the site's Edge cluster Prometheus service
    * `edge-monitoring-prometheus-url` the URL of the site's Edge monitoring Prometheus service
    * `edge-device` a list of monitoring devices that verify end-to-end connectivity

        * `edge-device-id` the identifier of the edge monitoring device. Serves the same purpose as other `id` fields.
        * `display-name` the user-friendly name for the edge device. It is recommended that the short hostname
          be used for the `display-name` as a convention.
        * `description` an optional description

The site also contains sub objects like:

* Devices
* Device Group
* IP Domain
* Sim Card
* Small Cell
* Slice
* UPF

Device
~~~~~~

A device represents a UE (User Equipment) registered on the Aether system. The devices are then referenced
by the `device-group` object.

* imei - the International Mobile Equipment Identifier of the device
* sim-card - a reference to the `sim-card` object
* state - a set of attributes that report the state of the device - includes `ip-address`,
   `connected` and `last-connected`

Device-Group
~~~~~~~~~~~~

`Device-Group` allows multiple devices to be logically grouped together. `Device-Group` contains
the following fields:

* `devices`. A list of Devices. Each device has an `enable` field which can be used to
  enable or disable the device.
* `ip-domain`. Reference to an `IP-Domain` object that describes the IP and DNS settings for UEs
  within this group.
* `mbr`. Per-device maximum bitrate in bits per second that the application will be limited to:

  * `uplink` the `mbr` from device to slice
  * `downlink` the `mbr` from slice to device

* `traffic-class`. The traffic class to be used for devices in this group.

SIM Card
~~~~~~~~
The Sim Card is used to represent a subscriber in the Aether system. When provisioned correctly there is
a 1:1 relationship between SIM Card and Device, with the identifier of the SIM Card being defined in the
Device

* `iccid` - the Integrated Circuit Card Identifier - which should be unique to any SIM Card
* `imsi` - the International Mobile Subscriber Identifier - the identifier of the Subscriber in Aether

Small Cell
~~~~~~~~~~

`Small cell` is list of 5G gNodeB or Access Point or Radios. Each small cell has the following:

    * `small-cell-id`. Identifier for the small cell. Serves the same purpose as other `id` fields.
    * `address`. Hostname of the small cell.
    * `tac`. Type Allocation Code.
    * `enable`. If set to `true`, the small cell is enabled. Otherwise, it is disabled.

Slice
~~~~~

`Slice` connects a `Device-Group` to an `Application`. `Slice` has the
following fields:

* `device-group`. A list of `Device-Group` objects that can participate in this `Slice`. Each
  entry in the list contains both the reference to the `Device-Group` as well as an `enable`
  field which may be used to temporarily remove access to the group.
* `default-behavior`. May be set to either `ALLOW-ALL`, `DENY-ALL`, or `ALLOW-PUBLIC`. This is
  the rule to use if no other rule in the filter matches. `ALLOW-PUBLIC` is a special alias
  that denies all private networks and then allows everything else.
* `filter`. A list of `Application` objects that are either allowed or denied for this
  `Slice`. Each entry in the list contains both a reference to the `Application` as well as an
  `allow` field which can be set to `true` to allow the application or `false` to deny it. It
  also has a `priority` field which can be used to order the applications when considering the
  enforcing of their `allow` or `deny` conditions.
* `upf`. Reference to the User Plane Function (`UPF`) that should be used to process packets
  for this `Slice`. It's permitted for multiple `Slice` to share a single `UPF`.
* `SST`, `SD`. Slice identifiers. These are assigned by Aether Operations.
* `mbr.uplink`, `mbr.downlink`. Slice-total Uplink and downlink maximum bit rates in bps.
* `mbr.uplink-burst-size`, `mbr.downlink-burst-size`. Maximum burst sizes in bytes for
  the maximum bit rates.


Application
~~~~~~~~~~~

`Application` specifies an application and the endpoints for the application. Applications are be shared
across Sites for an enterprise, and so are defined at the top level of the model. Applications are
the termination point for traffic from the UPF. Contains the following fields:

* `address`. The DNS name or IP address of the endpoint.
* `endpoint`. A list of endpoints. Each has the following fields:

    * `name`. Name of the endpoint. Used as a key.
    * `port-start`. Starting port number.
    * `port-end`. Ending port number.
    * `protocol`. `TCP|UDP`, specifies the protocol for the endpoint.
    * `mbr`. The maximum bitrate in bits per second that UEs sending traffic to the application endpoint
      will be limited to:

        * `uplink` the `mbr` from device to application
        * `downlink` the `mbr` from application to device

    * `traffic-class`. Traffic class to be used when UEs send traffic to this Application endpoint.

Supporting Aether Objects
-------------------------


IP-Domain
~~~~~~~~~

`IP-Domain` (beneath Site) specifies IP and DNS settings and has the following fields:

* `dnn`. Data network name for 5G, or APN for 4G.
* `dns-primary`, `dns-secondary`. IP addresses for DNS servers.
* `subnet`. Subnet to allocate to UEs.
* `admin-status`. Tells whether these ip-domain settings should be used, or whether they
  should be drained from UEs.
* `mtu`. Ethernet maximum transmission unit.
* `enterprise`. `Enterprise that owns this `IP-Domain`.

Template
~~~~~~~~

`Template` contains connectivity settings that are pre-configured by Aether Operations.
Templates are used to initialize `Slice` objects, and are shared across Sites for an enterprise.
`Template` has the following fields:

* `default-behavior`. May be set to either `ALLOW-ALL`, `DENY-ALL`, or `ALLOW-PUBLIC`. This is
  the rule to use if no other rule in the Slice's application filter matches. `ALLOW-PUBLIC` is
  a special alias that denies all private networks and then allows everything else.
* `sst`, `sd`. Slice identifiers.
* `uplink`, `downlink`. Guaranteed uplink and downlink bandwidth.
* `traffic-class`. Link to a `Traffic-Class` object that describes the type of traffic.
* `slice.mbr.uplink`, `slice.mbr.downlink`. Slice-total Uplink and downlink maximum bit rates in bps.
* `slice.mbr.uplink-burst-size`, `slice.mbr.downlink-burst-size`. Maximum burst sizes in bytes for
  the maximum bit rates.

Traffic-Class
~~~~~~~~~~~~~

Specifies the class of traffic, and is shared across Sites in an enterprise. Contains the following:

* `arp`. Allocation and Retention Priority.
* `qci`. QoS class identifier.
* `pelr`. Packet error loss rate.
* `pdb`. Packet delay budget.

UPF
~~~

Specifies the UPF that should forward packets. The UPF is part of the Site object, and also can only be
used by one Slice at a time. It has the following fields:

* `address`. Hostname or IP address of UPF.
* `port`. Port number of UPF.
* `enterprise`. Enterprise that owns this UPF.
* `site`. The Site that this UPF is located at.
* `config-endpoint` URL for configuring the UPF

.. |postman_link| raw:: html

   <a href="http://postman.com" target="_blank">Postman</a>
