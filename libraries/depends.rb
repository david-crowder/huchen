module Huchen

  class Depends

    # Responsible for assessing dependencies.
    #
    # @param packets Captured packets to make sense of.
    # @param ip_white_list List of ip addresses to ignore
    def initialize(packets, ip_white_list=[])
      @packets = packets
      @ip_white_list = ip_white_list
    end

    # Packages - currently only looks for debian packages.
    # @return [Array] Discovered package dependencies
    def packages
      http_requests.find_all{|req| req[:path].match(/.deb$/)}.map{|req| {:host => req[:host], :file_name => req[:path].sub(/.*\//, ''), :format => :deb}}
    end

    # Identify HTTP requests within the capture packets
    #
    # @return [Array] Array of HTTP requests made
    def http_requests
      requests = []
      @packets.each do |packet|
        next unless packet[:dest_port] == 80 and packet[:data].include? 'GET'
        next if @ip_white_list.include? packet[:dest_ip_address]
        paths = packet[:data].gsub(/\n/m, '').split(/GET /).reject{|get_req| ! get_req.include? ' HTTP'}.map{|get_req| get_req.slice(0, get_req.index(' HTTP'))}
        requests += paths.map{|path| {:host => packet[:dest_ip_address], :method => :GET, :path => path}}
      end
      requests
    end

    # Are there any external dependencies?
    #
    # @return [Boolean] True if external dependencies exist
    def external_deps?
      ! packages.empty?
    end

    # A string representation of the discovered dependencies, suitable for showing to the end user.
    def to_s
      sorted_pkgs = packages.sort{|a,b| a[:file_name] <=> b[:file_name]}
      sorted_pkgs.map{|pkg| "[package] #{pkg[:file_name]} (#{pkg[:host]})"}.join("\n")
    end

  end

end