name             "strongswan5"
maintainer       "Eric Richardson"
maintainer_email "e@ewr.is"
license          "BSD"
description      "Installs/Configures a Strongswan 5.x VPN server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "apt"
depends "iptables-ng"