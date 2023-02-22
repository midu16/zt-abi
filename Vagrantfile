# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = "1"
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
file_to_disk1 = './disk-0-1.vdi'
Vagrant.configure("2") do |config|
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.
  
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    config.vm.box = "fedora/37-cloud-base"
    config.vm.box_version = "37.20221105.0"
    config.vm.hostname = "inbacrnrdl0100.offline.oxtechnix.lan"
    config.disksize.size = '50GB'
    # Disable automatic box update checking. If you disable this, then
    # boxes will only be checked for updates when the user runs
    # `vagrant box outdated`. This is not recommended.
    # config.vm.box_check_update = false
  
    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # NOTE: This will enable public access to the opened port
    # config.vm.network "forwarded_port", guest: 80, host: 8080
  
    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine and only allow access
    # via 127.0.0.1 to disable public access
    # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  
    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    # config.vm.network "private_network", ip: "192.168.33.10"
  
    # Create a public network, which generally matched to bridged network.
    # Bridged networks make the machine appear as another physical device on
    # your network.
    # config.vm.network "public_network"
  
    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.network "public_network", bridge: "enp4s0f3u2"  
    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    config.vm.provider "virtualbox" do |node|
        node.customize ['storagectl', :id, '--name', 'SATA Controller', '--add', 'sata', '--portcount', 1]
        unless File.exists?(file_to_disk1)
            node.customize ['createhd', '--filename', file_to_disk1, '--variant', 'Fixed', '--size', 100 * 1024]
        end
        node.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk1]
        node.memory = 2048
        node.cpus = 2
        node.name = "AgentBasedInstaller"
    end
    config.vm.provision "shell", inline: <<-SHELL
        yes|  mkfs.ext4 -L extradisk1 /dev/sda
        mkdir /apps ; echo \'LABEL=extradisk1 /apps ext4 defaults 0 0\' >> /etc/fstab
        mount -a
    SHELL
    # View the documentation for the provider you are using for more
    # information on available options.
  
    # Enable provisioning with a shell script. Additional provisioners such as
    # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
    # documentation for more information about their specific syntax and use.
    config.vm.provision "shell", inline: <<-SHELL
        echo "fastestmirror=1" >> /etc/dnf/dnf.conf
        # installing all required packages
        dnf update -y && dnf -y install podman httpd httpd-tools jq skopeo libseccomp-devel podman-compose tree lvm2
        # exporting the env variables
        export REGISTRY_NAME="inbacrnrdl0100.offline.oxtechnix.lan"
        export REGISTRY_USER='pi'
        export REGISTRY_PASSWORD='raspberry'
        export REGISTRTY_PATH="/apps/registry"
        #creating the directory structure
        mkdir -p /apps/rhcos_image_cache
        mkdir -p ${REGISTRTY_PATH}/{auth,certs,data}
        #generating the certs
        cert_c="AT"                     # Country Name (C, 2 letter code)
        cert_s="Wien"                   # Certificate State (S)
        cert_l="Wien"                   # Certificate Locality (L)
        cert_o="TelcoEng"               # Certificate Organization (O)
        cert_ou="RedHat"                # Certificate Organizational Unit (OU)
        cert_cn="${REGISTRY_NAME}"      # Certificate Common Name (CN)
        openssl req \
            -newkey rsa:4096 \
            -nodes \
            -sha256 \
            -keyout /apps/registry/certs/domain.key \
            -x509 \
            -days 365 \
            -out /apps/registry/certs/domain.crt \
            -addext "subjectAltName = DNS:${REGISTRY_NAME}" \
            -subj "/C=${cert_c}/ST=${cert_s}/L=${cert_l}/O=${cert_o}/OU=${cert_ou}/CN=${cert_cn}"
        cp ${REGISTRTY_PATH}/certs/domain.crt /etc/pki/ca-trust/source/anchors/
        # adding certs to localhost
        update-ca-trust extract
        htpasswd -bBc ${REGISTRTY_PATH}/auth/htpasswd ${REGISTRY_USER} ${REGISTRY_PASSWORD}
        sudo systemctl enable --now podman.socket
        sudo systemctl status podman.socket
    SHELL
  end