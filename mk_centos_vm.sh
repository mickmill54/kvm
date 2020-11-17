export ISO="/data-1/vm-images/iso/CentOS-8.2.2004-x86_64-dvd1.iso" 
export NET="br0"
export OS="centos8"
export VM_IMG="/data-1/vm-images/centos8.qcow2"


virt-install \
--virt-type=kvm \
--name centos8 \
--ram 4096 \
--vcpus=2 \
--os-variant=${OS} \
--cdrom=${ISO} \
--network=bridge=${NET},model=virtio \
--graphics vnc \
--console pty,target_type=serial \
--disk path=${VM_IMG},size=50,bus=virtio,format=qcow2 \
