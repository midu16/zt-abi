Create a network using the macvlan driver
```bash
$ docker network create -d macvlan --subnet=10.0.99.0/24 --gateway=10.0.99.1 -o parent=enp4s0f3u2 macvlan0
```
Build the Docker image (from within project directory)
```bash
$ podman build . -t ocp-dhcpd:latest
```
Run the container on your host
```bash
$ podman run -d --restart unless-stopped --ip 10.0.99.6 --net=macvlan0 ocp-dhcpd:latest
```
