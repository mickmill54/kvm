#! /bin/bash
#===================================================================================
# Name: mk_ubunut_vm.sh
# Created by: Mick Miller
# Created on: 2020-11-17
#===================================================================================
# set -e
clear


# Read command line args
if [[ "${#}" -ne 1 ]]; then
  echo 
  echo ===========================================================================
  echo Usage: "${0}" the pass in a name for your VM on the command line.
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
  --ram 8192 \
  --disk path=/data-2/vm-images/"${KVM_NAME}".img,size=50 \
  --vcpus 2 \
  --virt-type kvm \
  --os-type linux \
  --os-variant ubuntu20.04 \
  --graphics none \
  --console pty,target_type=serial \
  --location  '/data-2/vm-images/iso/ubuntu-20.04.4-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd' \
  --extra-args 'console=tty0 console=ttyS0,115200n8' \
  --network bridge=br0,model=virtio \
  --extra-args 'console=ttyS0,115200n8 serial','ip=10.1.1.40::10.1.1.1:255.255.255.0:${KVM_NAME}.tmcg.local'
}

  #--location 'http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/' \

# main
make_vm
