package 'haskell-platform'

cabal_home = "#{ENV['HOME']}/.cabal"

bash 'cabal_update' do
  cabal_index = "#{cabal_home}/packages/hackage.haskell.org/00-index.tar"
  code 'cabal update'
  not_if do
    File.exists?(cabal_index) && (Time.now - File.mtime(cabal_index) < 60 * 60 * 24 * 7)
  end
end

keter_build = "#{cabal_home}/bin/keter"

keter_install = '/usr/bin/keter'

bash 'build_keter' do
  if version = node[:keter][:version]
    code "cabal install keter-#{version}"
    not_if "#{keter_build} --version | grep -F '#{version}'"
  else
    code 'cabal install keter'
    not_if "test -x #{keter_build}"
  end
end

bash 'install_keter' do
  code "[ -e #{keter_install} ] && mv #{keter_install}{,.bak}; cp #{keter_build} #{keter_install}"
  only_if { !File.executable?(keter_install) || File.mtime(keter_build) > File.mtime(keter_install) }

  notifies :restart, 'service[keter]', :delayed
end

group 'keter'

directory node[:keter][:root]

directory "#{node[:keter][:root]}/incoming" do
  group 'keter'
  mode '775'
end

keter_conf = '/etc/keter.yaml'

environment = node.chef_environment == '_default' ? 'staging' : node.chef_environment
ssl_cert = Chef::EncryptedDataBagItem.load('keter', "ssl_#{environment}")

ssl_cert_file = '/etc/ssl/certs/keter.crt'
file ssl_cert_file do
  content ssl_cert['crt']
  mode 0644
end

ssl_key_file = '/etc/ssl/private/keter.key'
file ssl_key_file do
  content ssl_cert['key']
  mode 0600
end

file keter_conf do
  content <<-YAML
root: #{node[:keter][:root]}
ssl:
  host: "*"
  port: 443
  key: #{ssl_key_file}
  certificate: #{ssl_cert_file}
  YAML

  notifies :restart, 'service[keter]', :delayed
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
  provider Chef::Provider::Service::Upstart
  subscribes :restart, resources(:file => ssl_cert_file), :delayed
  subscribes :restart, resources(:file => ssl_key_file), :delayed
end
