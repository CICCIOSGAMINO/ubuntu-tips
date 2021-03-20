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
nmcli con mod eth0 ipv4.dns "8.8.8.8,8.8.4.4"

# ipv6
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
