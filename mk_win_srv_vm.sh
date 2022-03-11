#! /bin/bash
#===================================================================================
# Name: mk_ubunut_vm.sh
# Created by: Mick Miller
# Created on: 2020-11-18
#===================================================================================
# set -e
clear


# Read command line args
if [[ "${#}" -ne 1 ]]; then
  echo 
  echo ===========================================================================
  echo Usage: "${0}" the pass in a name for you VM on the command line.
  echo ===========================================================================
  echo
  exit 1
fi

KVM_NAME="${1}"


make_vm() {
  echo 
  echo ===========================================================================
  echo Building VM... "${1}"
  echo ===========================================================================
  echo

virt-install \
  --name "${KVM_NAME}" \
  --ram 4096 \
  --disk path=/data-1/vm-images/"${KVM_NAME}".img,size=50 \
  --vcpus 2 \
  --virt-type kvm \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --graphics none \
  --console pty,target_type=serial \
  --location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \
  --extra-args 'console=tty0 console=ttyS0,115200n8' \
  --network bridge=br0 \
  --extra-args 'ip=10.1.1.60::10.1.1.1:255.255.255.0:vault-01.tmcg.local'

virt-install \
  --name=ad1 
  --ram=4096 
  --cpu host 
  --hvm 
  --vcpus=2 
  --os-type=windows 
  --os-variant=win 
  --disk /var/lib/libvirt/images/win10.img,size=40,bus=virtio 
  --cdrom /var/lib/libvirt/boot/Windows10.iso 
  --disk /var/lib/libvirt/boot/virtio-win.iso,device=cdrom 
  --network bridge=br0 
  --graphics vnc,listen=0.0.0.0,port=5904 
  --check all=off 
  --boot cdrom

}


# main
make_vm
