
# -- add ewrcode ppa -- #

if node["lsb"]["codename"] == "precise"
  apt_repository "ewrcode-strongswan" do
    uri           "http://ppa.launchpad.net/ewrcode/strongswan/ubuntu"
    distribution  node["lsb"]["codename"]
    components    ["main"]
    key           "E9318FF5"
    keyserver     "keyserver.ubuntu.com"
    action        :add
  end
else
  raise "This recipe only knows how to install on Ubuntu 12.04 (precise)"
end

# -- install strongswan -- #

package "strongswan"
package "strongswan-plugin-xauth-pam"

service "strongswan" do
  action :nothing
  provider Chef::Provider::Service::Upstart
  supports [:start,:stop,:restart,:reload]
end

# -- write pam.d/xauth -- #

template "/etc/pam.d/xauth" do
  source  "xauth.pam.erb"
  user    "root"
  mode    644
end

# -- write ipsec.conf -- #

template "/etc/ipsec.conf" do
  source  "ipsec.conf.erb"
  user    "root"
  mode    0644
  notifies :restart, "service[strongswan]"
end

# -- write subnet-attrs.conf -- #

template "/etc/strongswan.d/subnet-attrs.conf" do
  source  "subnet-attrs.conf.erb"
  user    "root"
  mode    0644
  notifies :restart, "service[strongswan]"
end

# -- write ipsec.secrets -- #

template "/etc/ipsec.secrets" do
  source  "ipsec.secrets.erb"
  user    "root"
  mode    0600
  notifies :restart, "service[strongswan]"
end

# -- Host Networking -- #

service "procps" do
  action :nothing
  provider Chef::Provider::Service::Upstart
  supports [:start]
end

# allow forwarding
file "/etc/sysctl.d/40-net.ipv4.ip_forward.conf" do
  content "net.ipv4.ip_forward = 1\n"
  mode 0644
  notifies :start, "service[procps]"
end

# disallow icmp redirects
file "/etc/sysctl.d/40-disallow_icmp_redirects.conf" do
  content "net.ipv4.conf.all.accept_redirects = 0\nnet.ipv4.conf.all.send_redirects = 0\n"
  mode 0644
  notifies :start, "service[procps]"
end

# -- IP Tables -- #

include_recipe "iptables-ng::install"

iptables_ng_chain "FIREWALL" do
  policy "- [0:0]"
end

# send traffic to the firewall
iptables_ng_rule "75-strongswan5-firewall-input" do
  chain "INPUT"
  table "filter"
  rule  "-j FIREWALL"
end

# allow all traffic from these interfaces

iptables_ng_rule "80-strongswan5-allow-interfaces" do
  chain "FIREWALL"
  table "filter"
  rule  (node.strongswan5.accept_interfaces||[]).collect {|iface| "-i #{iface} -j ACCEPT" }
end

# allow ICMP traffic?
iptables_ng_rule "81-strongswan5-icmp" do
  action  node.strongswan5.icmp_allowed ? :create : :delete
  chain   "FIREWALL"
  table   "filter"
  rule    "-p icmp -j ACCEPT"
end

iptables_ng_rule "82-strongswan5-established" do
  chain "FIREWALL"
  table "filter"
  rule  "-m state --state ESTABLISHED,RELATED -j ACCEPT"
end

# set up TCP port allows
iptables_ng_rule "83-strongswan5-tcpports" do
  chain   "FIREWALL"
  table   "filter"
  rule    (node.strongswan5.tcp_ports_allowed||[]).collect {|p| "-m state --state NEW -m tcp -p tcp --dport #{p} -j ACCEPT" }
end

# set up UDP port allows
iptables_ng_rule "83-strongswan5-udpports" do
  chain   "FIREWALL"
  table   "filter"
  rule    (node.strongswan5.udp_ports_allowed||[]).collect {|p| "-m state --state NEW -m udp -p udp --dport #{p} -j ACCEPT" }
end

# reject everything else
iptables_ng_rule "84-strongswan5-reject" do
  chain "FIREWALL"
  table "filter"
  rule  "-j REJECT"
end

iptables_ng_rule "98-strongswan5-accept" do
  chain "POSTROUTING"
  table "nat"
  rule  "-s #{node.strongswan5.ip_range} -o #{node.strongswan5.interface} -m policy --dir out --pol ipsec -j ACCEPT"
end

iptables_ng_rule "99-strongswan5-masquerade" do
  chain "POSTROUTING"
  table "nat"
  rule  "-s #{node.strongswan5.ip_range} -o #{node.strongswan5.interface} -j MASQUERADE"
end

