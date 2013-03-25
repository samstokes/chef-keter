package 'haskell-platform'

cabal_home = "#{ENV['HOME']}/.cabal"

bash 'cabal_update' do
  code 'cabal update'
  not_if "test -d #{cabal_home}"
end

keter_build = "#{cabal_home}/bin/keter"

keter_install = '/usr/bin/keter'

bash 'build_keter' do
  code 'cabal install keter'
  not_if "test -x #{keter_build}"
end

bash 'install_keter' do
  code "cp #{keter_build} #{keter_install}"
  not_if 'which keter'
end

group 'keter'

directory node[:keter][:root]

directory "#{node[:keter][:root]}/incoming" do
  group 'keter'
  mode '775'
end

keter_conf = '/etc/keter.yaml'

file keter_conf do
  content <<-YAML
root: #{node[:keter][:root]}
  YAML
end

file '/etc/init/keter.conf' do
  content <<-UPSTART
start on (net-device-up and local-filesystems and runlevel [2345])
stop on runlevel [016]
respawn

console none

exec #{keter_install} #{keter_conf}
  UPSTART
end

service 'keter' do
  action :start
end
