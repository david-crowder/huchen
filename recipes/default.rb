cookbook_file "/usr/bin/pcap2json" do
  source "pcap2json"
  mode "0700"
end

execute "pcap2json" do
  command "nohup /usr/bin/pcap2json > '#{node[:huchen][:capture_file]}' &"
end
