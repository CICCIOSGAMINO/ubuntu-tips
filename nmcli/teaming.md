Teaming with nmcli
==================
[TOC]

```bash
# create team interface
nmcli con add type team con-name team0 ifname team0 team.runner activebackup

# if the interface you want assign to them is not configured, crete new connection profile
nmcli con add type wifi slave-type team con-name team0-wlp3s0 ifname wlp3s0 master team0 ssid THE-NET
nmcli con modify team0-wlp3s0 wifi-sec.key-mgmt wpa-psk wifi-sec.psk the-password

# assign an existing connection profile to the team, set the master parameter of these connections to team0
nmcli con modify bond0 master team0

# Configure the IP settings of the team. Skip this step if you want to use this team as a ports of other devices
# Configure the IPv4 settings. For example
# static IPv4 address, network mask, default gateway, DNS server, and DNSsearch domain the team0
nmcli con modify team0 ipv4.method manual
nmcli con modify team0 ipv4.addresses '192.168.1.10/24'
nmcli con modify team0 ipv4.gateway '192.168.1.1'
nmcli con modify team0 ipv4.dns '8.8.8.8'

# Configure the IPv6 settings
nmcli connection modify team0 ipv6.method manual
nmcli connection modify team0 ipv6.addresses '2001:db8:1::1/64'
nmcli connection modify team0 ipv6.gateway '2001:db8:1::fffe'
nmcli connection modify team0 ipv6.dns '2001:db8:1::fffd'

# activate the connection
nmcli connection up team0
```