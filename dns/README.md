Step 1. Build the podman image (from within project directory)
```bash
$ podman build . -t ocp-bind9:latest
STEP 1/8: FROM ubuntu:bionic
STEP 2/8: MAINTAINER midu@redhat.com
--> Using cache ab72555895c357990e1b17d47b033672b57e93fbb77f171441275e2a40a80e4d
--> ab72555895c
STEP 3/8: RUN apt-get update   && apt-get install -y   bind9   bind9utils   bind9-doc
--> Using cache 64920e4232e5a9d19b40cae8474355cd0a24c285212f007fc7a29cf01944146f
--> 64920e4232e
STEP 4/8: RUN sed -i 's/OPTIONS=.*/OPTIONS="-4 -u bind"/' /etc/default/bind9
--> Using cache f7f0bdc6632c4fdbb5d5c2b42ab7a6a7d6a257ad88ab51f63651750a3b18ac16
--> f7f0bdc6632
STEP 5/8: COPY config/named.conf.options /etc/bind/
--> Using cache 3a23dadcf3d99fb6ec3e1fae801cbbc5b03370b136c0e71877df60011841db26
--> 3a23dadcf3d
STEP 6/8: COPY config/named.conf.local /etc/bind/
--> Using cache 5084faac48c3e8b9657bf9d205ce1e97a4459573d48e59c44543c407cbe49d98
--> 5084faac48c
STEP 7/8: COPY config/db.offline.oxtechnix.lan /etc/bind/zones/
--> 5fca6456c38
STEP 8/8: CMD ["/bin/bash", "-c", "while :; do /etc/init.d/bind9 start; done"]
COMMIT ocp-bind9:latest
--> 5ce668cbf65
Successfully tagged localhost/ocp-bind9:latest
5ce668cbf655855aaa9c615923c3ac23094e1576d3c05adba1e6751c711c2be1
```
Step 2. Run the container on your host
```bash
$ podman run -d --name ocp-bind9 --restart unless-stopped --ip 10.0.99.2 --net=macvlan0 localhost/ocp-bind9:latest
```