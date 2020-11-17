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
| --------------------- | --------------------------------------------- |
| qemu-kvm              | QEMU Full virtualization on x86 hardware      |
| libvirt-daemon-system | Libvirt daemon configuration files            |
| libvirt-clients       | Programs for the libvirt library              |
| virtinst              | Programs to create and clone virtual machines |
| libosinfo-bin	        | Tools for querying the osinfo database        |
| libguestfs-tools      | Guest disk image management system and tools for Cloud images |
| cpu-checker           | Tools to help evaluate certain CPU (or BIOS) features |
| virt-manager          | Desktop application for managing virtual machines |
| ssh-askpass-gnome     | Interactive X program to prompt users for a passphrase for ssh-add |

### Install the packages
```
{
  $ sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virtinst cpu-checker libguestfs-tools libosinfo-bin
}
```

## Step 2: Configure network bridge

The next thing we’re going to do is replace the default bridging. As mentioned above, KVM installs a virtual bridge that all the VMs connect to. It provides its own subnet and DHCP to configure the guest’s network and uses NAT to access the outside world. We’re going to replace that with a public bridge that runs on the host network and uses whatever external DHCP server is on the host network.
</br>
For performance reasons, it is recommended to disable netfilter on bridges in the host. To do that, create a file called /etc/sysctl.d/bridge.conf and fill it in with this:

```
{
  net.bridge.bridge-nf-call-ip6tables=0
  net.bridge.bridge-nf-call-iptables=0
  net.bridge.bridge-nf-call-arptables=0
}
```

Then create a file called /etc/udev/rules.d/99-bridge.rules and add this line:

```
{
  ACTION=="add", SUBSYSTEM=="module", KERNEL=="br_netfilter", RUN+="/sbin/sysctl -p /etc/sysctl.d/bridge.conf"
}
```

That should all be on one line. That will set the flags to disable netfilter on bridges at the proper place in system start-up. Reboot to take effect.
</br>
Next, we need to disable the default networking that KVM installed for itself. You can use ip to see what the default network looks like:

```
{
  $ ip link
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: wlp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 34:02:86:2a:f6:f2 brd ff:ff:ff:ff:ff:ff
    3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:d9:6f:66 brd ff:ff:ff:ff:ff:ff
    4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:d9:6f:66 brd ff:ff:ff:ff:ff:ff

}

```

The entries virbr0 and virbr0-nic are what KVM installs by default.
</br>
Because this host just had KVM installed, I don’t have to worry about existing VMs. If you have existing VMs, you will have to edit them to use the new network setup. It’s possible you can have both public and private VMs, but I’d just as soon have only one type of network per host to avoid confusion. Here’s how to remove the default KVM network:

```
{
  $ virsh net-destroy default
  $ virsh net-undefine default
}
```

Now you can run ip again and the virbr0 and virbr0-nic should be gone.

```
{
  $ ip link                   
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: wlp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 34:02:86:2a:f6:f2 brd ff:ff:ff:ff:ff:ff
}
```


Next, we will need to set up a bridge to use when we create a VM. Edit your /etc/netplan/00-installer-config.yaml (after making a back-up) to add a bridge. This is what mine looks like after editing:

```
{
network:
  version: 2
  renderer: networkd

  ethernets:
    eno1:
      dhcp4: no
      dhcp6: no
    enp8s0:
      dhcp4: no
      dhcp6: no
      addresses: [10.1.1.21/24]
      gateway4: 10.1.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4,10.1.1.21]
      dhcp4: no
      dhcp6: no
    enp9s0:
      dhcp4: true
  version: 2

  bridges:
    br0:
      interfaces: [eno1]
      addresses: [10.1.1.20/24]
      gateway4: 10.1.1.1
      mtu: 1500
      nameservers:
        addresses: [8.8.8.8,8.8.4.4,10.1.1.21]
      parameters:
        stp: true
        forward-delay: 4
      dhcp4: no
      dhcp6: no
}
```


In my case en01 is the name of my NIC, 10.1.1.20 is the IP address of my host, and 10.1.1.1 is my firewall. My host is using a static IP. The bridge br0 is attached to the en01 interface, the physical network card on the host. Notice that the en01 interface is not configured, the bridge now has the network configuration that used to be specified in the en01 section.


Now run 

```
{
sudo netplan apply 
}
```

to apply your new configuration. You can use the ip command to inspect that it looks correct:

```
{

  $ ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
    2: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 90:2b:34:56:c3:83 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.21/24 brd 10.1.1.255 scope global enp8s0
       valid_lft forever preferred_lft forever
    inet6 fe80::922b:34ff:fe56:c383/64 scope link 
       valid_lft forever preferred_lft forever
    3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether 90:2b:34:56:c3:73 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    4: enp7s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 68:05:ca:0d:e8:af brd ff:ff:ff:ff:ff:ff
    5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 90:2b:34:56:c3:73 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.20/24 brd 10.1.1.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::922b:34ff:fe56:c373/64 scope link 
       valid_lft forever preferred_lft forever
    8: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:19:7a:ed:10 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
     29: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UNKNOWN group default qlen 1000
    link/ether fe:54:00:48:2c:e5 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fe48:2ce5/64 scope link 
       valid_lft forever preferred_lft forever

}
```

Note that the br0 entry now has the IP address and the enp0s7 entry now has master br0 to show that it belongs to the bridge.
</br>
Now we can make KVM aware of this bridge. create a scratch XML file called host-bridge.xml and insert the following:

```
{

<network>
  <name>host-bridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>

}
```


Use the following commands to make that our default bridge for VMs:

```
{

  $ virsh net-define host-bridge.xml
  $ virsh net-start host-bridge
  $ virsh net-autostart host-bridge

}
```

And then list the networks to confirm it is set to autostart:

```
{

  $ virsh net-list --all
    Name          State    Autostart   Persistent
    ------------------------------------------------
    host-bridge   active   yes         yes

}
```

Now that we have a bridge configured, let's make a KVM guest.


