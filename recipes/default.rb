
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


