virt-install \
--name ipa.srv.01 \
--ram 4096 \
--disk path=/data-8/vm-images/ipa.srv.01.img,size=40 \
--vcpus 2 \
--virt-type kvm \
--os-type linux \
--os-variant ubuntu20.04 \
--graphics none \
--console pty,target_type=serial \
--location '/data-4/vm-images/iso/ubuntu-20.10-live-server-amd64.iso' \
--extra-args "console=tty0 console=ttyS0,115200n8"
--network bridge=br0 \
--extra-args "ip=10.1.1.30::10.1.1.1:255.255.255.0:ipa.srv.01.tmcg.local:eth0=none"
