module Huchen

  class Depends

    # Responsible for assessing dependencies.
    #
    # @param matchers Matchers to assess dependencies with
    # @param capture Capture to make sense of.
    def initialize(matchers, capture)
      @matchers = matchers
      @capture = capture
    end

    # Are there any external dependencies?
    #
    # @return [Boolean] True if external dependencies exist
    def external_deps?
      ! (@capture.http_requests - ignored).empty?
    end

    # Packages requested
    #
    # @return [Array] Package details
    def packages
      @capture.http_requests.map do |req|
        if req.has_key?(:path) and req.has_key?(:host)
          @matchers.map do |matcher|
            if matcher.type == :package and matcher.path.match(req[:path])
              {:name => req[:path].sub(/.*\//, ''), :type => "#{matcher.name}_#{matcher.type}", :host => req[:host],
               :request => req}
            end
          end
        end
      end.flatten.compact.sort{|a,b| a[:name] <=> b[:name]}
    end

    # Requests that were marked to ignore
    #
    # @return [Array]
    def ignored
      @capture.http_requests.find_all{|req|@matchers.any?{|m| m.ignore.any?{|i|i.match(req[:path])}}}
    end

    # Requests that did not match and were not explicitly set to ignore by a matcher
    #
    # @return [Array]
    def unmatched
      @capture.http_requests - ignored - packages.map{|pkg| pkg[:request]}
    end

    # A string representation of the discovered dependencies, suitable for showing to the end user.
    def to_s
      lines = packages.map{|pkg| "[#{pkg[:type]}] #{pkg[:name]} (#{pkg[:host]})"}.sort
      lines << unmatched.map{|req| filter_request(req).inspect.gsub(/^/, '[unmatched] ')}
      lines.join("\n").strip
    end

    private

    # Filter a request to show any relevant details for display to the end user
    #
    # @param [Hash] req The request to filter
    # @return [Hash] The filtered request with minimal set of useful keys
    def filter_request(req)
      filtered = {}
      [:src_ip_address, :dest_ip_address, :src_port, :dest_port, :path, :user_agent, :host].each do |key|
        filtered[key] = req[key] if req.has_key?(key)
      end
      filtered
    end
  end

end