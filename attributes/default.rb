default[:huchen][:capture_file] = "#{Chef::Config[:file_cache_path]}/huchen.json"
default[:huchen][:pcap2json] = Mash.new
default[:huchen][:pcap2json][:version] = '0.1.0'
