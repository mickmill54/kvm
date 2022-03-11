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
  --os-variant rhel8.0 \
  --graphics none \
  --console pty,target_type=serial \
  --location '/data-1/vm-images/iso/CentOS-8.2.2004-x86_64-dvd1.iso' \
  --extra-args 'console=tty0 console=ttyS0,115200n8' \
  --network bridge=br0 
}



# main
make_vm
