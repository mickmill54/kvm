# Installing KVM on my Ubuntu 20.04 Headless Server
</br>
### References
</br>

https://www.cyberciti.biz/faq/how-to-install-kvm-on-ubuntu-20-04-lts-headless-server/

</br>
https://levelup.gitconnected.com/how-to-setup-bridge-networking-with-kvm-on-ubuntu-20-04-9c560b3e3991

### Is the cpu on the host virtualization capable

```
{
  $ lscpu | grep -i virt
    
    Virtualization:   VT-x

  ## or ##

  $ kvm-ok
    INFO: /dev/kvm exists
    KVM acceleration can be used

}
```
If virtualization is not enabled, try booting into the BIOS and seeing if you can enable the virtualization feature in the bios.

## Step 1: Install 

| Package Name | Description |
| ------------------ | ----------------------------- |
| qemu-kvm           | QEMU Full virtualization on x86 hardware |


