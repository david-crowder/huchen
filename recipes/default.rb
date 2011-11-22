%x{nohup --version}
raise RuntimeError.new("huchen requires the nohup utility") unless $?.success?

pkg_path = "/huchen/files/default/pcap2json_#{node[:huchen][:pcap2json][:version]}_i386.deb"
Chef::Config[:cookbook_path].each do |cbk_path|
  path = File.join(cbk_path, pkg_path)
  dpkg_package "pcap2json" do
    source path
    action :install
    only_if {File.exists? path}
  end
end

execute "nohup /usr/bin/pcap2json > '#{node[:huchen][:capture_file]}' &"

include_recipe 'huchen::matchers'