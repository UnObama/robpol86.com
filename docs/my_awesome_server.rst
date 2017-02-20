.. _my_awesome_server:

=================
My Awesome Server
=================

I've had home servers since I was in high school in 2002. However I've never documented how I set them up before. Here
I'll be outlining the steps I took in setting up my current home Linux server. It's a general purpose server, acting as:

1. A file server for all of my media/backups/etc.
2. `Docker <https://www.docker.com/>`_ server.
3. Automated Bluray/DVD ripping (backups) station.
4. `Plex <https://www.plex.tv/>`_ media server.
5. `Metrics <https://github.com/influxdata/chronograf>`_ collector and email alerting.
6. Tape backup server.

Hardware
========

My server will be going inside my `TV stand/cabinet`_. It'll share a case with my `pfSense <https://pfsense.org/>`_
custom router and be on a `UPS`_.

=============== ===========================================================================================
Case            `Travla T2241`_ dual mini-ITX with `Seasonic 250 watt`_ power supplies
Motherboard/CPU `Supermicro X10SDV-TLN4F-O`_ with Xeon D-1541
Memory          Kingston KVR24R17D8K4/64 (64 GB)
M.2 SSD         Samsung 960 PRO 512 GB
Storage HDDs    6x Seagate 10TB IronWolf Pro (ST10000NE0004)
SAS HBA         HighPoint RocketRAID 2721 4-Port Internal / 4 Port External
External Tape   *TBD*
=============== ===========================================================================================

Operating System
================

I'm using Fedora 25 Server installed on my M.2 SSD using `LUKS`_. I'll also be encryping all of my non-SSD hard drives
using their own LUKS key file (same file for all HDDs, but not SSD).

I follow https://gist.github.com/Robpol86/6226495 when setting up any Linux system, including my server. However I don't
setup my HDDs during setup, I leave them alone.

Sending Email
-------------

I want my server to send email alerts to me when events happen (e.g. a disk fails). I did write a guide about this at
:ref:`postfix_gmail_forwarding`. However instead of using Gmail to send email I'm going with https://www.sparkpost.com/
since they have a free tier and I can send emails in scripts using simple HTTP requests. Also email templates are a nice
feature.

To setup run:

.. code-block:: bash

    sudo dnf install postfix mailx cyrus-sasl{,-plain}

Then edit ``/etc/postfix/main.cf`` with the following. Replace ``<API-KEY>`` and ``<SENDING-DOMAIN>``.

.. code-block:: ini

    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = static:SMTP_Injection:<API-KEY>
    relayhost = [smtp.sparkpostmail.com]:587
    smtp_sasl_security_options = noanonymous
    smtp_tls_security_level = encrypt
    header_size_limit = 4096000
    myorigin = <SENDING-DOMAIN>.com
    mydestination = <SENDING-DOMAIN>.com $myhostname localhost.$mydomain localhost

Then run:

.. code-block:: bash

    sudo tee /etc/aliases <<< 'root: <YOU>@gmail.com'
    sudo newaliases
    sudo systemctl start postfix.service
    sudo systemctl enable postfix.service
    mail -s "Test Email $(date)" <YOU>@gmail.com <<< "This is a test email."
    mail -s "Test Email for Root $(date)" root <<< "This is a test email."

You should receive both emails in your personal email account. If not make sure the numbers in your SparkPost's
dashboard's usage report have increased.

Docker
======

I'll be making heavy use of Docker on my server. Fedora ships with a forked version of Docker. I'd rather run the latest
"real" Docker so I ran these commands:

.. code-block:: bash

    sudo dnf -y remove docker docker-common container-selinux docker-selinux
    sudo dnf config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/fedora/docker.repo
    sudo dnf makecache fast
    sudo dnf install docker-engine
    sudo systemctl start docker
    sudo systemctl enable docker.service
    sudo docker run hello-world

LUKS and Btrfs
==============

TODO

.. _TV stand/cabinet: https://www.standoutdesigns.com/products/media-console-solid-wood-majestic-ex-70-inch-wide
.. _Seasonic 250 watt: https://seasonic.com/product/ss-250-su-active-pfc-f0/
.. _UPS: http://www.apc.com/shop/us/en/products/APC-Smart-UPS-1500VA-LCD-RM-2U-120V/P-SMT1500RM2U
.. _Travla T2241: http://www.travla.com/business/index.php?id_product=49&controller=product
.. _Supermicro X10SDV-TLN4F-O: http://www.supermicro.com/products/motherboard/Xeon/D/X10SDV-TLN4F.cfm
.. _LUKS: https://fedoraproject.org/wiki/Disk_Encryption_User_Guide
