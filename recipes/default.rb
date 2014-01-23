
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

cookbook_file "/etc/init/iptables.conf" do
  action :create
  source "iptables.upstart.conf"
end

service "iptables" do
  provider Chef::Provider::Service::Upstart
  action :nothing
end

template "/etc/iptables.rules" do
  action :create
  source "iptables.rules.erb"
  notifies :start, "service[iptables]"
end

