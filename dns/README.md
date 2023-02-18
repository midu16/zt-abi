Step 1. Build the podman image (from within project directory)
```bash
$ podman build . -t ocp-bind9:latest
```
Step 2. Run the container on your host
```bash
$ podman run -d --name ocp-bind9 --restart unless-stopped --ip 10.0.99.2 --net=macvlan0 localhost/ocp-bind9:latest
```