[![dockeri.co](http://dockeri.co/image/weldpua2008/docker-nsd)](https://hub.docker.com/r/weldpua2008/docker-nsd/)
[![Docker Pulls](https://img.shields.io/docker/pulls/weldpua2008/docker-nsd.svg)](https://hub.docker.com/r/weldpua2008/docker-nsd/)
[![Docker Stars](https://img.shields.io/docker/stars/weldpua2008/docker-nsd.svg)](https://hub.docker.com/r/weldpua2008/docker-nsd/)
[![GitHub issues](https://img.shields.io/github/issues/weldpua2008/docker-nsd.svg)](https://github.com/weldpua2008/docker-nsd/issues) [![GitHub forks](https://img.shields.io/github/forks/weldpua2008/docker-nsd.svg)](https://github.com/weldpua2008/docker-nsd/network) [![GitHub stars](https://img.shields.io/github/stars/weldpua2008/docker-nsd.svg)](https://github.com/weldpua2008/docker-nsd/stargazers) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/weldpua2008/docker-nsd/master/LICENSE) 
[![Github Releases (by Release)](https://img.shields.io/github/downloads/weldpua2008/docker-nsd/v1.0.0/total.svg)](https://github.com/weldpua2008/docker-nsd/releases/tag/v1.0.0)

docker-nsd
===================
NSD is an authoritative only and open source DNS server. It is developed by NLnet Labs and it is distributed under the BSD license.

[NSD website][1]

[wikipedia.org/wiki/NSD][2]

The following OS are aviable
=============================

* [Ubuntu](http://www.ubuntu.com/)
  * 14.04
  * 12.04
  * 15.04
  * 15.10

How to use this image
=====================
Testing with an empty NSD server
--------------------------------

By default, this image provides a NSD server with no configuration and no zone. It may still be tested by running on the host:

    docker run -d --name nsd-server weldpua2008/docker-nsd

To interrogate this local empty name server, simply use `dig`:

    dig @`docker inspect --format "{{ .NetworkSettings.IPAddress }}" nsd-server`

This command should return an empty *QUESTION SECTION* and some details about the request.

If you receive no response from the NSD server and an error message "*connection timed out; no servers could be reached*", this may be due to an input blockage from your firewall. In such a case, check the rules related to the `docker0` interface.

Accessing the data
------------------

Two volumes devoted to handle the mutable data are included in the image. An easy way to deal with them consists in running `/bin/bash` in a container that can see them,

    docker run -it --name nsd-data --hostname nsd-data \
                   --volumes-from nsd-server \
                   debian:wheezy /bin/bash

Thus, the log file `nsd.log` is located in `/var/log/nsd`,

    root@nsd-data:/# cat /var/log/nsd/nsd.log

and the configuration and zone files are in `/etc/nsd3`,

    root@nsd-data:/# ls /etc/nsd3

Adding configuration and zone files
-----------------------------------

For the moment, the container `nsd-server` is empty and does not serve to anything. Now we want to have fun with our own configuration and zone files.

The default configuration file is `nsd.conf` and is located in `/etc/nsd3`. Help about this file can be found with `man 5 nsd.conf` and in the sample configuration file,

    root@nsd-data:/# cat /etc/nsd3/nsd.conf.sample

Let us take a basic example to test our server,

    root@nsd-data:/# cat <<EOF > /etc/nsd3/nsd.conf
    server:
      hide-version: yes
      identity: ""
    
    zone:
      name: test.nsd
      zonefile: test.nsd.zone
    EOF

The zone files can also be located in `/etc/nsd3`. The format of a zone file is defined in RFC 1035 (section 5) and RFC 1034 (section 3.6.1). For more details, see

[wikipedia.org/wiki/Zone_file][3]

In our example of `nsd.conf`, we have declared a zone `test.nsd` defined in a zone file `test.nsd.zone`. Let us create it,

    root@nsd-data:/# cat <<EOF > /etc/nsd3/test.nsd.zone
    \$ORIGIN test.nsd.
    \$TTL 86400
    
    @ IN SOA test.nsd. admin.test.nsd. (
        201410292335 ;
        28800 ;
        28800 ;
        864000 ;
        28800 ;
    )
    
    @ IN A 1.2.3.4
    EOF

To take into account the changes, simply `restart` the container of the NSD server from the host,

    docker restart nsd-server

You can use `docker logs nsd-server` to make sure there was no error and, if everything works, you can test the NSD server,

    dig @`docker inspect --format "{{ .NetworkSettings.IPAddress }}" nsd-server` A test.nsd

You should obtain

    [...]
    
    ;; QUESTION SECTION:
    ;test.nsd.    IN    A

    ;; ANSWER SECTION:
    test.nsd.    86400    IN    A    1.2.3.4
    
    [...]

Exposing the port
-----------------

To use the container as a name server listening on the standard domain port of the host, we need to map its port `53/udp` to the one of the host:

    docker run -p 53:53/udp -d --name nsd-server nsd-server

Advanced configuration
----------------------

Dealing with the configuration, log and zone files through the volumes given by the NSD server can be annoying. A better approach to handle these files is to proceed in the other way: create a container for the mutable data and share the volumes with the container of the NSD server. For this, we propose to use a host directory for the configuration and zones files, `/nsd-conf` in the sequel, and a simple volume for the logs. Thus, we create the container `nsd-data` with

    docker run -it --name nsd-data --hostname nsd-data \
           -v /nsd-conf:/etc/nsd3 \
           -v /var/log/nsd \
           debian:wheezy /bin/bash

The host directory `/nsd-conf` contains your configuration and zone files and is mounted as a data volume on `/etc/nsd3`. Moreover, a classical volume is mounted on `/var/log/nsd` for the logs.

It is now simple to use this two volumes to create the container for the NSD server,

    docker run -d -p 53:53/udp --name nsd-server \
           --volumes-from nsd-data \
           weldpua2008/docker-nsd

As above, if you modify a file in `/nsd-conf` (or in the directory `/etc/nsd3` of the container `/nsd-data`), it is sufficient to `restart` the container `nsd-server` for taking it into account,

    docker restart nsd-server


Obtaining these Images from DockerHub
=====================================

Ansible, Inc content on DockerHub lives at https://hub.docker.com/r/weldpua2008/docker-nsd/

This images on DockerHub will be updated periodically.

Requirements
=====================================
* docker


Disclaimer
=============================

This is currently a work in progress, I am not responsible and shall not
be held responsible in any manner if this tool causes loss of data, hardware
faults, act of gods, invocation of old or ancient ones, elder gods and other
horrors from the depths.

Issues
==========
If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/weldpua2008/docker-nsd/issues).

Contributing
==========
    You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/weldpua2008/docker-nsd/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

  [1]: https://www.nlnetlabs.nl/projects/nsd/
  [2]: https://en.wikipedia.org/wiki/NSD
  [3]: https://www.nlnetlabs.nl/projects/nsd/
