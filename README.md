# zt-abi
 

 Requirements:
```bash
 sudo dnf install -y podman-docker
 sudo -H pip3 install --upgrade pip
 sudo curl -SL https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
 sudo chmod +x /usr/local/bin/docker-compose
```

```bash
sudo systemctl enable --now podman.socket
sudo systemctl status podman.socket
```
