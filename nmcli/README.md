nmcli
=====
[TOC]

/etc/NetworkManager
/usr/lib/NetworkManager

# manage the unmanaged
In first i can't manage the ethernet devices, so let's dig in into this interesting NetworkManager configuration file, print the actual value and change it a bit:
```bash
cd /usr/lib/NetworkManager/conf.d/
cat 10-globally-managed-devices.conf
> [keyfile]
  unmanaged-devices=*,except:type:wifi,except:type:gsm,except:type:cdma

# modify the file with vim

# cat the new file
> [keyfile]
  unmanaged-devices=*,except:type:ethernet,except:type:wifi,except:type:gsm,except:type:cdma

# restart NetworkManager
sudo systemctl restart NetworkManager

# ethernet device managed
nmcli
> eth0: connected to eth0
          "eth0"
          ethernet (bcmgenet), DC:XX:XX:XX:XX:XX, hw, mtu 1500
          inet4 192.168.1.176/24
          route4 0.0.0.0/0
          route4 192.168.1.0/24
          route4 192.168.1.1/32
          inet6 fe80::dea6:32ff:fe22:b8a3/64
          route6 fe80::/64

  wlan0: disconnected
          "Broadcom BCM43438 combo and Bluetooth Low Energy"
          wifi (brcmfmac), DC:XX:XX:XX:XX:XX, hw, mtu 1500

  lo: unmanaged
          "lo"
          loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

  p2p-dev-wlan0: unmanaged
          "p2p-dev-wlan0"
          wifi-p2p, hw
```

# Modify a Static Ethernet Connection
When the ethernet interface is in manage state you can now modify the configuration:
```bash
# ipv4
nmcli con mod eth0 ipv4.mode manual
nmcli con mod eth0 ipv4.addresses "192.168.1.3/24"
nmcli con mod eth0 ipv4.gw4 "192.168.1.1"
# replace the value of DNS
nmcli con mod eth0 ipv4.dns "8.8.8.8,8.8.4.4"
# adding to previous value of DNS
nmcli con mod eth0 +ipv4.dns "192.168.1.1"
nmcli con up eth0

# ipv6
nmcli con mod eth0 ipv6.dns "2001:4860:4860::8888 2001:4860:4860::8844"

# adding an ethernet connection profile in interactive editor (a)
nmcli connection edit type ethernet
```


# Create a Wifi HOTSPOT Access Point with nmcli
Usually, when you create an Wi-Fi access point with NetworkManager (802-11-wireless.mode ap), then you also want to run a DHCP and DNS server with IPv4 NAT (or use IPv6 prefix delegation). The Wi-Fi "ap" and the IP shared method are independent. For example, you can also configure "ipv4.method=shared" on an ethernet or bluetooth device.

If you configure ipv4.method shared, NetworkManager will run dnsmasq on the interface, which acts as a DHCP and DNS server. It will also add an iptables rule to enable masquerading (NAT). If you configure ipv6.method shared, NetworkManager will do IPv6 prefix delegation.

Easy example, with cable connected on the ethernet interface spin up a wifi hotspot:
```bash
# create the connection (interface wlan0)
nmcli connection add type wifi ifname wlan0 con-name hotspot ssid HOTSPOT-NET
# set wifi network mode, one of "infrastructure", "mesh", "adhoc" or "ap". If blank, infrastructure is assumed.
nmcli connection modify hotspot 802-11-wireless.mode ap
# set the band, One of "a" for 5GHz 802.11a or "bg" for 2.4GHz 802.11
nmcli connection modify hotspot 802-11-wireless.band bg
# set the ipv4.method, for IPv4 method "shared", the IP subnet can be configured by adding one manual IPv4 
# address or otherwise 10.42.x.0/24 is chosen. Note that the shared method must be configured on the interface 
# which shares the internet to a subnet, not on the uplink which is shared.
nmcli connection modify hotspot ipv4.method shared
# Key management used for the connection. One of "none" (WEP), "ieee8021x" (Dynamic WEP), "wpa-psk" (infrastructure WPA-PSK), "sae" (SAE) or "wpa-eap" (WPA-Enterprise).  This property must be set for any Wi-Fi connection that uses security.
nmcli connection modify hotspot 802-11-wireless-security.key-mgmt wpa-psk
# Pre-Shared-Key for WPA networks. For WPA-PSK, it's either an ASCII passphrase of 8 to 63 characters that is (as specified in the 802.11i standard) hashed to derive the actual key, or the key in form of 64 hexadecimal character. The WPA3-Personal networks use a passphrase of any length for SAE authentication.
nmcli connection modify hotspot 802-11-wireless-security.psk "bananecocco"

# start up the connection
nmcli connection up hotspot

# show the hotspot password
nmcli dev wifi show-password
SSID: HOTSPOT-NET
Security: WPA
Password: bananecocco

  █████████████████████████████████
  ██ ▄▄▄▄▄ █▀█ █▄▀█▀ █▄█▄█ ▄▄▄▄▄ ██
  ██ █   █ █▀▀▀█ ▀ ▀███ ▄█ █   █ ██
  ██ █▄▄▄█ █▀ █▀▀ ▀▀ ███ █ █▄▄▄█ ██
  ██▄▄▄▄▄▄▄█▄▀ ▀▄█ █ █ █ █▄▄▄▄▄▄▄██
  ██  ▄▄▄█▄ ▄▄▀▄▀ ▀█▀ ▄ █▄▀▄▀▄▀ ███
  ███▀▀▄█▀▄▀▄█▄█▀▄▀▄▄▄▄█▀  ▄▀▄█▀▀██
  ██ █▀▄▀▀▄▄ ▄▄█▄ ▀▄▀███ ▀█  ▄ ▀███
  ██▀▄ █ ▀▄█▄   ▄▄▀  █ ▀  ▄▄█▀▄████
  ██▀█▀▀▀▀▄ ▄▄█▄▀▀█▄▀ ▄▄▀▀█▄▀ █ ▄██
  ██ ██▀▄ ▄▄ █▀█▀ ▄▄▀▄ ███ ▄ ███▀██
  ██▄█▄██▄▄█ █ █▄█▄█▀▄▀▀ ▄▄▄ ▄ ████
  ██ ▄▄▄▄▄ █▄▄▀ ▄█▀ ▄▄ ▀ █▄█ ▀▄▀███
  ██ █   █ █ ██▄▀▀▀▄▀▄▀▀ ▄▄▄  █  ██
  ██ █▄▄▄█ █ █ █▀ ▄▄▀█▄▀███▄  ▄ ███
  ██▄▄▄▄▄▄▄█▄▄▄█▄█▄██▄█▄█▄██▄▄█████
  █████████████████████████████████

```

## Change ip
10.42.0.1/24 is the default address set by NetworkManager for a device in shared mode. Addresses in this range are also distributed via DHCP to other computers. If the range conflicts with other private networks in your environment, change it by modifying the ipv4.addresses property:
```bash
nmcli connection modify hotspot ipv4.addresses 192.168.42.1/24
# activate again the connection profile after any change to apply the new values:
nmcli connection up hotspot
```

## ipv6
Let's test a simple share hotspot with ipv6 configuration. 

## Adding custom dnsmasq options (with dnsmasq)
In case you want to further extend the dnsmasq configuration, you can add new configuration snippets in /etc/NetworkManager/dnsmasq-shared.d/. For example, the following configuration:
```bash
# dnsmasq to advertise a NTP server via DHCP
dhcp-option=option:ntp-server,192.168.42.1
# it assigns a static IP to a client with a certain MAC
dhcp-host=52:54:00:a4:65:c8,192.168.42.170
```

There are many other useful options in the dnsmasq manual page. However, remember that some of them may conflict with the rest of the configuration; so please use custom options only if you know what you are doing.


# Interface Bonding (bond)
https://www.golinuxcloud.com/nmcli-command-examples-cheatsheet-centos-rhel/

Bonding (or channel bonding) is a technology-enabled by the Linux kernel and Red Hat Enterprise Linux, that allows administrators to combine two or more network interfaces to form a single, logical “bonded” interface for redundancy or increased throughput. The behavior of the bonded interfaces depends upon the mode; generally speaking, modes provide either hot standby or load balancing services. Additionally, they may provide link-integrity monitoring.

The two important reasons to create an interface bonding are :
1. To provide increased bandwidth
2. To provide redundancy in the face of hardware failure

One of the pre-requisites to configure a bonding is to have the network switch which supports EtherChannel (which is true in case of almost all switches).

**Bonding Modes**
Mode 0  **Round Robin** - packets are sequentially transmitted/received through each interfaces one by one. 
         Fault Tollerance  YES   Load Balancing  YES
  
Mode 1 **Active Backup** - one NIC active while another NIC is asleep. If the active NIC goes down, another NIC becomes active. only supported in x86 environments.
         Fault Tollerance  YES   Load Balancing  NO

Mode 2 **XOR** - In this mode the, the MAC address of the slave NIC is matched up against the incoming request’s MAC and once this connection is established same NIC is used to transmit/receive for the destination MAC.
         Fault Tollerance  YES   Load Balancing  YES

Mode 3 **Broadcast** - All transmissions are sent on all slaves
         Fault Tollerance  YES   Load Balancing  NO

Mode 4 **Dynamic Link Aggregation** - aggregated NICs act as one NIC which results in a higher throughput, but also provides failover in the case that a NIC fails. Dynamic Link Aggregation requires a switch that supports IEEE 802.3ad
         Fault Tollerance  YES   Load Balancing  YES

Mode 5 **Transmit Load Balancing TLB** - The outgoing traffic is distributed depending on the current load on each slave interface. Incoming traffic is received by the current slave. If the receiving slave fails, another slave takes over the MAC address of the failed slave.
         Fault Tollerance  YES   Load Balancing  YES

Mode 6 **Adaptive Load Balancing ALB** - Unlike Dynamic Link Aggregation, Adaptive Load Balancing does not require any particular switch configuration. Adaptive Load Balancing is only supported in x86 environments. The receiving packets are load balanced through ARP negotiation.
         Fault Tollerance  YES   Load Balancing  YES

```bash
# down active connection on device will use
nmcli con down HOME-NET
# crete the bond ( mode balance-rr )
nmcli con add type bond con-name bond-alb ifname bond0 mode balance-rr

# create two bond slave with two device (interface) type ethernet
nmcli con add type bond-slave ifname wlp3s0 master bond-alb
nmcli con add type bond-slave ifname wlx9cd64300f65b master bond-alb

# create two wifi bond slave
nmcli con add type wifi con-name bond-wlx9cd64300f65b slave-type bond master bond-alb ifname wlx9cd64300f65b ssid CICCIO-NET
nmcli con modify bond-wlx9cd64300f65b wifi-sec.key-mgmt wpa-psk wifi-sec.psk bananecocco

nmcli con add type wifi con-name bond-wlp3s0 slave-type bond master bond-alb ifname wlp3s0 ssid CICCIO-NET
nmcli con modify bond-wlp3s0 wifi-sec.key-mgmt wpa-psk wifi-sec.psk bananecocco

# set the active_slave and the primary
nmcli dev mod bond0 +bond.options "active_slave=wlx9cd64300f65b,primary=wlx9cd64300f65b"
# up the slaves (phisical device)
nmcli con up bond-alb

```

**Understanding the Default Behavior of Master and Slave Interfaces**
When controlling bonded slave interfaces using the NetworkManager daemon, and especially when fault finding, keep the following in mind:

+ Starting the master interface does not automatically start the slave interfaces.
+ Starting a slave interface always starts the master interface.
+ Stopping the master interface also stops the slave interfaces.
+ A master without slaves can start static IP connections.
+ A master without slaves waits for slaves when starting DHCP connections.
+ A master with a DHCP connection waiting for slaves completes when a slave with a carrier is added.
+ A master with a DHCP connection waiting for slaves continues waiting when a slave without a carrier is added.

## Verify Bonding Configuration
Network redundancy is a process when devices are used for backup purposes to prevent or recover from a failure of a specific system. The following procedure describes how to verify the network configuration for bonding in redundancy:
```bash
# ping from bond interface
ping -I bond0 nike.com
# view bond mode
cat /sys/class/net/bond0/bonding/mode
> active-backup 1
# view which interface is active
cat /sys/class/net/bond0/bonding/active_slave
> wlx9cd64300
# view primary interface
cat /sys/class/net/bond0/bonding/primary
> wlx9cd64300
# view miimo
cat /sys/class/net/bond0/bonding/miimo
> 100
```

Try now to down the primary active_slave and check it out if the other slave will be active so you can ping again your target with the backup interface:
```bash
# down the primary interface
ip link set wlx9cd64300 down

cat /sys/class/net/bond0/bonding/active_slave 
wlp3s0

ping -I bond0 nike.com
```

Note: sysfs is a virtual file system that represents kernel objects as directories, files and symbolic links. sysfs can be used to query for information about kernel objects, and can also manipulate those objects through the use of normal file system commands. The sysfs virtual file system is mounted under the /sys/ directory. All bonding interfaces can be configured dynamically by interacting with and manipulating files under the /sys/class/net/ directory.