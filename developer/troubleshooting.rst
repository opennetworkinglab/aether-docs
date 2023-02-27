.. vim: syntax=rst

.. _aiab_troubleshooting:

Aether-in-a-Box FAQs and Troubleshooting
========================================

FAQs
----

RKE2 vs. Kubespray Install
^^^^^^^^^^^^^^^^^^^^^^^^^^

The AiaB installer will bring up Kubernetes on the server where it is run.  By default it
uses `RKE2 <https://docs.rke2.io>`_ as the Kubernetes platform.  However, older versions of AiaB
used `Kubespray <https://kubernetes.io/docs/setup/production-environment/tools/kubespray/>`_
and that is still an option.  To switch to Kubespray as the Kubernetes platform, edit the
Makefile and replace *rke2* with *kubespray* on this line::

    node0:~/aether-in-a-box$ git diff Makefile
    diff --git a/Makefile b/Makefile
    index 5f2c186..608c221 100644
    --- a/Makefile
    +++ b/Makefile
    @@ -35,7 +35,7 @@ ENABLE_GNBSIM ?= true
     ENABLE_SUBSCRIBER_PROXY ?= false
     GNBSIM_COLORS ?= true

    -K8S_INSTALL ?= rke2
    +K8S_INSTALL ?= kubespray
     CTR_CMD     := sudo /var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io

     PROXY_ENABLED   ?= false
    node0:~/aether-in-a-box$


You may wish to use Kubespray instead of RKE2 if you want to use locally-built images with AiaB
(e.g., if you are developing SD-CORE services).  The reason is that RKE2 uses containerd instead of
Docker and so cannot access images in the local Docker registry.

How to use Local Image
^^^^^^^^^^^^^^^^^^^^^^

Note that RKE2 (the default Kubernetes installer) is based on containerd rather than Docker.
Containerd has its own local image registry that is separate from the local Docker Registry.  With RKE2,
if you have used `docker build` to build a local image, it is only in the Docker registry and so is not
available to run in AiaB without some additional steps.  An easy workaround
is to use `docker push` to push the image to a remote repository (e.g., Docker Hub) and then modify your
Helm values file to pull in that remote image.  Another option is to save the local Docker image
into a file and push the file to the containerd registry like this::

    docker save -o /tmp/lte-uesoftmodem.tar omecproject/lte-uesoftmodem:1.1.0
    sudo /var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io \
        images import /tmp/lte-uesoftmodem.tar

The above commands save the local Docker image `omecproject/lte-uesoftmodem:1.1.0` in a tarball, and then upload
the tarball into the containerd registry where it is available for use by RKE2.  Of course you should replace
`omecproject/lte-uesoftmodem:1.1.0` with the name of your image.

If you know that you are going to be using AiaB to test locally-built images, probably the easiest thing to do is to
use the Kubespray installer.  If you have already installed using RKE2 and you want to switch to Kubespray, first
run `make clean` before following the steps in the :ref:`rke2-vs-kubespray-install` section above.

Restarting the AiaB Server
^^^^^^^^^^^^^^^^^^^^^^^^^^

AiaB should come up in a mostly working state if the AiaB server is rebooted.  If any pods are
stuck in an Error or CrashLoopBackoff state they can be restarted using ``kubectl delete pod``.
It might also be necessary to power cycle the Sercomm eNodeB in order to get it to reconnect to
the SD-CORE.


Enabling externalIP at MME
^^^^^^^^^^^^^^^^^^^^^^^^^^

You can enable externalIP service in the MME by providing following config in the override file::

   node0:~/aether-in-a-box$ git diff sd-core-4g-values.yaml
   diff --git a/sd-core-4g-values.yaml b/sd-core-4g-values.yaml
   index 0939739..f240f89 100644
   --- a/sd-core-4g-values.yaml
   +++ b/sd-core-4g-values.yaml
   @@ -24,6 +24,11 @@ omec-control-plane:
          bootstrap:
            users: []
            staticusers: []
   +    mme:
   +      s1ap:
   +        serviceType: ClusterIP
   +        externalIP: 10.1.1.1
   +
        spgwc:
          pfcp: true
          cfgFiles:
   node0:~/aether-in-a-box$

Enabling externalIP at AMF
^^^^^^^^^^^^^^^^^^^^^^^^^^

You can enable externalIP service in the AMF by providing following config in the override file::

    node0:~/aether-in-a-box$ git diff sd-core-5g-values.yaml
    diff --git a/sd-core-5g-values.yaml b/sd-core-5g-values.yaml
    index e513e1f..fc1c684 100644
    --- a/sd-core-5g-values.yaml
    +++ b/sd-core-5g-values.yaml
    @@ -34,6 +34,9 @@

         amf:
           cfgFiles:
    +        ngapp:
    +          serviceType: ClusterIP
    +          externalIp: "10.1.1.2"
    +          port: 38412
             amfcfg.conf:
               configuration:
                 enableDBStore: false
    @@ -176,6 +179,7 @@ omec-user-plane:
               cpiface:
                 dnn: "internet"
                 hostname: "upf"

     5g-ran-sim:
       enable: ${ENABLE_GNBSIM}

    node0:~/aether-in-a-box$

Troubleshooting
---------------

**NOTE: Running both 4G and 5G SD-CORE simultaneously in AiaB is currently not supported.**

Proxy Issues
^^^^^^^^^^^^

When working with AiaB behind a proxy, it may be possible to experience certain issues
due to security policies. That is, the proxy may block a domain (e.g., opencord.org)
and you may see messages like these ones when trying to clone or get a copy of aether-in-a-box::

    ubuntu18:~$ git clone https://gerrit.opencord.org/aether-in-a-box
    Cloning into 'aether-in-a-box'...
    fatal: unable to access 'https://gerrit.opencord.org/aether-in-a-box/': server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none

or::

    ubuntu18:~$ wget https://gerrit.opencord.org/plugins/gitiles/aether-in-a-box/+archive/refs/heads/master.tar.gz
    --2022-06-01 13:13:42--  https://gerrit.opencord.org/plugins/gitiles/aether-in-a-box/+archive/refs/heads/master.tar.gz
    Resolving proxy.company-xyz.com (proxy.company-xyz.com)... w.x.y.z
    Connecting to proxy.company-xyz.com (proxy.company-xyz.com)|w.x.y.z|:#... connected.
    ERROR: cannot verify gerrit.opencord.org's certificate, issued by 'emailAddress=proxy-team@company-xyz.com,... ,C=US':
     Self-signed certificate encountered.

To address this issue, you need to talk to your company's proxy admins and request to
unblock (re-classify) the opencord.org domain


"make" fails immediately
^^^^^^^^^^^^^^^^^^^^^^^^

AiaB connects macvlan networks to ``DATA_IFACE`` so that the UPF can communicate on the network.
To do this it assumes that the *systemd-networkd* service is installed and running, ``DATA_IFACE``
is under its control, and the systemd-networkd configuration file for ``DATA_IFACE`` ends with
``<DATA_IFACE>.network``, where ``<DATA_IFACE>`` stands for the actual interface name.  It
tries to find this configuration file by looking in the standard paths.  If it fails you'll see
a message like::

    FATAL: Could not find systemd-networkd config for interface foobar, exiting now!
    make: *** [Makefile:112: /users/acb/aether-in-a-box//build/milestones/interface-check] Error 1

In this case, you can specify a ``DATA_IFACE_PATH=<path to the config file>`` argument to ``make``
so that AiaB can find the systemd-networkd configuration file for ``DATA_IFACE``.  It's also possible
that your system does not use systemd-networkd to configure network interfaces (more likely if you
are running in a VM), in which case AiaB is currently not able to install in your setup.  You
can check that systemd-networkd is installed and running as follows::

    $ systemctl status systemd-networkd.service
    ● systemd-networkd.service - Network Service
        Loaded: loaded (/lib/systemd/system/systemd-networkd.service; disabled; vendor preset: enabled)
        Active: active (running) since Tue 2022-07-12 13:42:18 CDT; 2h 26min ago
    TriggeredBy: ● systemd-networkd.socket
        Docs: man:systemd-networkd.service(8)
    Main PID: 13777 (systemd-network)
        Status: "Processing requests..."
        Tasks: 1 (limit: 193212)
        Memory: 6.4M
        CGroup: /system.slice/systemd-networkd.service
                └─13777 /lib/systemd/systemd-networkd


.. _AiaB_fails_too_many_files_open:

AiaB fails during deployment of SD-Core network
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When running AiaB in Ubuntu 22.04, AiaB installation fails during the deployment of the SD-Core with
an error message as shown below::

    ...
    ...
    Update Complete. ⎈Happy Helming!⎈
    NODE_IP=10.80.51.4 DATA_IFACE=data RAN_SUBNET=192.168.251.0/24 ENABLE_GNBSIM=true envsubst < /home/ubuntu/aether-in-a-box//sd-core-5g-values.yaml | \
    helm upgrade --create-namespace --install --wait  \
            --namespace omec \
            --values - \
            sd-core \
            aether/sd-core
    Release "sd-core" does not exist. Installing it now.
    coalesce.go:175: warning: skipped value for kafka.config: Not a table.
    Error: timed out waiting for the condition
    make: *** [Makefile:336: /home/ubuntu/aether-in-a-box//build/milestones/5g-core] Error 1

To get more details about the issue, you can execute the following command to see what pod(s) have issues::

    $ kubectl -n omec get pods
    NAME                          READY   STATUS             RESTARTS         AGE
    amf-6dd746b9cd-2mk2j          0/1     CrashLoopBackOff   13 (24s ago)     42m
    ausf-6dbb7655c7-4pkmp         1/1     Running            0                42m
    gnbsim-0                      1/1     Running            0                42m
    metricfunc-7864fb8b7c-srf2l   1/1     Running            3 (41m ago)      42m
    mongodb-0                     1/1     Running            0                42m
    mongodb-1                     1/1     Running            0                41m
    mongodb-arbiter-0             1/1     Running            0                42m
    nrf-57c79d9f65-fs9qj          1/1     Running            0                42m
    nssf-5b85b8978d-q8dz5         1/1     Running            0                42m
    pcf-758d7cfb48-wjfxf          1/1     Running            0                42m
    sd-core-kafka-0               1/1     Running            0                42m
    sd-core-zookeeper-0           1/1     Running            0                42m
    simapp-6cccd6f787-sd52q       0/1     Error              13 (5m14s ago)   42m
    smf-ff667d5b8-sw5vf           1/1     Running            0                42m
    udm-768b9987b4-cqvbg          1/1     Running            0                42m
    udr-8566897d45-n8cbz          1/1     Running            0                42m
    upf-0                         5/5     Running            0                42m
    webui-5894ffd49d-bdwf4        1/1     Running            0                42m

As shown above, there are problems with the AMF and SIMAPP pods and to see the specifics of the
problem, the user can see the logs as shown below::

    $ kubectl -n omec logs amf-6dd746b9cd-2mk2j
    ...
    ...
    } (resolver returned new addresses)
    2023/01/24 17:24:56 INFO: [core] [Channel #1] Channel switches to new LB policy "pick_first"
    2023/01/24 17:24:56 INFO: [core] [Channel #1 SubChannel #2] Subchannel created
    2023/01/24 17:24:56 too many open files

As the message shows, the problem is due to "too many open files". To resolve this issue, the user
can increase the maximum number of available watches and the maximum number of inotify instances
(e.g., 10x). To do so, first, see the current maximum numbers::

    $ sysctl fs.inotify.max_user_instances
    fs.inotify.max_user_instances = 128
    $ sysctl fs.inotify.max_user_watches
    fs.inotify.max_user_watches = 1048576

Then, increase these values by executing::

    sudo sysctl fs.inotify.max_user_instances=1280
    sudo sysctl fs.inotify.max_user_watches=10485760

The above setting gets reset to their original values when the machine is rebooted. You can make
this change permanent by creating an override file::

    sudo nano /etc/sysctl.d/90-override.conf
        fs.inotify.max_user_instances=1280
        fs.inotify.max_user_watches=10485760
    sudo sysctl --system

The last command is to load the changes without having to reboot the machine

Data plane is not working
^^^^^^^^^^^^^^^^^^^^^^^^^

The first step is to read `Understanding AiaB networking`_understanding_aiab_networking, which
gives a high level picture
of the AiaB data plane and how the pieces fit together.  In order to debug the problem you will
need to figure out where data plane packets from the eNodeB are dropped.  One way to do this is to
run ``tcpdump`` on (1) DATA_IFACE to ensure that the data plane packets are arriving, (2) the
``access`` interface to see that they make it to the UPF, and (3) the ``core`` to check that they
are forwarded upstream.

If the upstream packets don't make it to DATA_IFACE, you probably need to add the static route
on the eNodeB so packets to the UPF have a next hop of DATA_IFACE.  You can see these upstream
packets by running::

    tcpdump -i <data-iface> -n udp port 2152

If they don't make it to ``access`` you should check that the kernel routing table is forwarding
a packet with destination 192.158.252.3 to the ``access`` interface.  You can see them by running::

    tcpdump -i access -n udp port 2152

In case packets are not forwarded from ``DATA_IFACE``  to ``acccess`` interface, the following command
can be used to forward the traffic which is destined to 192.168.252.3::

    iptables -A FORWARD -d 192.168.252.3 -i <data-iface> -o access -j ACCEPT

If they don't make it to ``core`` then they are being dropped by the UPF for some reason.  This
may be a configuration issue with the state loaded in the ROC / SD-CORE -- the UPF is being told
to discard these packets.  You should check that the device's IMSI is part of a slice and that
the slice's policy settings allow traffic to that destination.  You can view them via the following::

    tcpdump -i core -n net 172.250.0.0/16

That command will capture all packets to/from the UE subnet.

If you cannot figure out the issue, see `Getting Help`_.

.. _rke2-vs-kubespray-install:

Getting Help
------------

Please introduce yourself and post your questions to the `#aether-dev` channel on the ONF Community Slack.
Details about how to join this channel can be found on the `ONF Wiki <https://wiki.opennetworking.org/display/COM/Aether>`_.
In your introduction please state your institution and position, and describe why you are interested in Aether
and what is your end goal.

If you need help debugging your setup, please give as much detail as possible about
your environment: the OS version you have installed, are you running on bare metal or in a VM,
how much CPU and memory does your server have, are you installing behind a proxy, and so on.  Also list the steps
you have performed so far, and post any error messages you have received.  These details will aid the community
to understand where you are and how to help you make progress.


