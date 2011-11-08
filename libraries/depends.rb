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
      ! @capture.http_requests.empty?
    end

    def packages
      @capture.http_requests.map do |req|
        if req.has_key?(:path) and req.has_key?(:host)
          @matchers.map do |matcher|
            if matcher.type == :package and matcher.path.match(req[:path])
              {:name => req[:path].sub(/.*\//, ''), :type => "#{matcher.name}_#{matcher.type}", :host => req[:host]}
            end
          end
        end
      end.flatten.compact.sort{|a,b| a[:name] <=> b[:name]}
    end

    # A string representation of the discovered dependencies, suitable for showing to the end user.
    def to_s
      packages.map{|pkg| "[#{pkg[:type]}] #{pkg[:name]} (#{pkg[:host]})"}.join("\n")
    end

  end

end