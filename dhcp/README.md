Step 0. Configure the 2.1q interface
- Create the 2.1q connection
```bash
sudo nmcli connection add type vlan con-name enp4s0f3u2.99 ifname enp4s0f3u2.99 dev enp4s0f3u2 id 99
Connection 'enp4s0f3u2.99' (45e5804d-a195-455c-87aa-07488d167a3f) successfully added.
```
- Validate the creation of the connection
```bash
sudo nmcli con show
NAME                        UUID                                  TYPE      DEVICE
enp4s0f3u2.99               45e5804d-a195-455c-87aa-07488d167a3f  vlan      enp4s0f3u2.99
```
- Assign an ipv4.address to the connection
```bash
sudo nmcli connection modify enp4s0f3u2.99 ipv4.addresses '10.0.99.5/24'
```
- Validate that the interface connection has the ipv4.address
```bash
sudo ip a
17: enp4s0f3u2.99@enp4s0f3u2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 9c:eb:e8:88:9f:72 brd ff:ff:ff:ff:ff:ff
    inet 10.0.99.5/24 brd 10.0.99.255 scope global noprefixroute enp4s0f3u2.99
       valid_lft forever preferred_lft forever
    inet6 fe80::918:83c:54e1:9485/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```
Step 1. Create a network using the macvlan driver
```bash
$ podman network create -d macvlan --subnet=10.0.99.0/24 --gateway=10.0.99.1 -o parent=enp4s0f3u2 macvlan0
```
Step 2. Build the podman image (from within project directory)
```bash
$ podman build . -t ocp-dhcpd:latest
STEP 1/4: FROM alpine:latest
Resolved "alpine" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/alpine:latest...
Getting image source signatures
Copying blob 63b65145d645 done
Copying config b2aa39c304 done
Writing manifest to image destination
Storing signatures
STEP 2/4: RUN set -xe && apk add --update --no-progress dhcp && rm -rf /var/cache/apk/*
+ apk add --update --no-progress dhcp
fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/community/x86_64/APKINDEX.tar.gz
(1/3) Installing libgcc (12.2.1_git20220924-r4)
(2/3) Installing dhcp (4.4.3_p1-r1)
Executing dhcp-4.4.3_p1-r1.pre-install
(3/3) Installing dhcp-server-vanilla (4.4.3_p1-r1)
Executing busybox-1.35.0-r29.trigger
OK: 12 MiB in 18 packages
+ rm -rf /var/cache/apk/APKINDEX.ac15ed62.tar.gz /var/cache/apk/APKINDEX.c3d4ed66.tar.gz
--> 660d988884f
STEP 3/4: RUN ["touch", "/var/lib/dhcp/dhcpd.leases"]
--> f94007c0cc1
STEP 4/4: CMD ["/usr/sbin/dhcpd", "-4", "-f", "-d", "--no-pid", "-cf", "/etc/dhcp/dhcpd.conf"]
COMMIT ocp-dhcpd:latest
--> 3b0d00f156d
Successfully tagged localhost/ocp-dhcpd:latest
3b0d00f156ddf3e0bd23d66594f37473fd76e3421617f64fb6fb69c774d912cc
```
Step 3. Run the container on your host
```bash
$ podman run -d --name ocp-dhcpd --restart unless-stopped --ip 10.0.99.6 --net=macvlan0 localhost/ocp-dhcpd:latest
```


Validating the funcitonality

```bash
$ sudo podman logs ocp-dhcpd
Internet Systems Consortium DHCP Server 4.4.3-P1
Copyright 2004-2022 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/
Config file: /etc/dhcp/dhcpd.conf
Database file: /var/lib/dhcp/dhcpd.leases
PID file: /run/dhcp/dhcpd.pid
Wrote 0 deleted host decls to leases file.
Wrote 0 new dynamic host decls to leases file.
Wrote 0 leases to leases file.
Listening on LPF/eth0/d2:4c:87:d1:8a:c5/10.0.99.0/24
Sending on   LPF/eth0/d2:4c:87:d1:8a:c5/10.0.99.0/24
Sending on   Socket/fallback/fallback-net
Server starting service.
Dynamic and static leases present for 10.0.99.155.
Remove host declaration passacaglia or remove 10.0.99.155
from the dynamic address pool for 10.0.99.0/24
DHCPREQUEST for 10.0.99.155 from b8:27:eb:f0:d7:48 via eth0
DHCPACK on 10.0.99.155 to b8:27:eb:f0:d7:48 via eth0
```