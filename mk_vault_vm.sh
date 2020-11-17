virt-install \
--name vault-1 \
--ram 4096 \
--disk path=/data-1/vm-images/vault-1.img,size=50 \
--vcpus 2 \
--virt-type kvm \
--os-type linux \
--os-variant ubuntu20.04 \
--graphics none \
--console pty,target_type=serial \
--location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \
--extra-args "console=tty0 console=ttyS0,115200n8"
--network bridge=br0 \
--extra-args "ip=10.1.1.60::10.1.1.1:255.255.255.0:vault-01.tmcg.local"

