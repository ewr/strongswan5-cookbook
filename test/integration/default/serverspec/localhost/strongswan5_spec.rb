require "spec_helper"

# ipsec should be running (charon daemon)
describe process("charon") do
  it { should be_running }
end

describe command("ipsec statusall") do
  # xauth-pam plugin should be loaded
  its(:stdout) { should match(/plugins\:.*xauth-pam/)}
  
  # it should have our IP pool
  its(:stdout) { should include("10.0.2.20/25: 126/0/0") }
end

describe port(500) do
  it { should be_listening.with('udp') }
end

#describe iptables do
  #it { should have_rule("-A POSTROUTING -s 10.0.2.0/25 -m policy --dir out --pol ipsec -j ACCEPT").with_chain("POSTROUTIN")}
#end