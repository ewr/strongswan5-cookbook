default.strongswan5.shared_secret  = "CHANGEMEINSECURE"
default.strongswan5.user_group     = "vpn"
default.strongswan5.interface      = "eth0"
default.strongswan5.left           = node.ipaddress
default.strongswan5.vpn_id         = "strongswanvpn"
default.strongswan5.subnets        = "10.0.0.0/24"
default.strongswan5.ip_range       = "10.0.2.20/25"
default.strongswan5.rightdns       = "8.8.8.8,8.8.4.4"

default.strongswan5.xauth_pam_template          = "xauth.pam.erb"
default.strongswan5.xauth_pam_template_cookbook = "strongswan5"

default.strongswan5.enable_firewall = true

default.strongswan5.accept_interfaces = ["lo","eth1"]
default.strongswan5.icmp_allowed      = true
default.strongswan5.tcp_ports_allowed = [22,500,4500]
default.strongswan5.udp_ports_allowed = [500,4500]

