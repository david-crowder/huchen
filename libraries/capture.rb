module Huchen

  # Network traffic capture
  class Capture

    # Create a Capture instance
    #
    # @param [Hash] options Options to use when parsing the network capture
    # @options options [String] :json_string JSON network capture as a string
    # @options options [String] :json_file_path JSON network capture as a file path
    def initialize(options)
      if options.has_key? :json_string
        raise ArgumentError.new ':json_string cannot be nil or empty' if options[:json_string].nil? || options[:json_string].empty?
      elsif options.has_key? :json_file_path
        raise ArgumentError.new "Capture file '#{options[:json_file_path]}' could not be found." unless File.exists? options[:json_file_path]
      else
        raise ArgumentError.new 'You must provide either a :json_file_path or :json_string'
      end
      @options = options
    end

    # Parse the network capture and return the captured packets.
    #
    # @return [Array] Array of captured packets
    # @raise [Huchen::CaptureReadError] If any packet is malformed
    def packets
      packets = []
      packets_string = @options.has_key?(:json_string) ? @options[:json_string] : IO.read(@options[:json_file_path])
      packets_string.split("\n").each_with_index do |line,index|
        begin
          packets << convert_packet_keys(JSON.parse(line), index)
        rescue JSON::ParserError => pe
          raise CaptureReadError.new("Packet could not be read: #{index}", index, pe)
        end
      end
      packets
    end

    private

    # Map of pcap2json fields to nicer ruby symbols
    KEY_MAP = {'SrcIp' => :src_ip_address, 'DestIp' => :dest_ip_address, 'SrcPort' => :src_port,
               'DestPort' => :dest_port, 'Data' => :data}

    # Convert pcap2json keys to nicer ruby equivalents.
    #
    # @param [Hash] packet The packet to convert
    # @param [Integer] index The offset of the packet within the capture
    # @return [Hash] Beautified packet
    # @raise [Huchen::CaptureReadError] If the packet is missing any required field
    def convert_packet_keys(packet, index)
      ruby_packet = {}
      KEY_MAP.keys.each do |key|
        raise CaptureReadError.new("Packet missing field (:#{KEY_MAP[key]}): #{index}", index) unless packet.has_key? key
        ruby_packet[KEY_MAP[key]] = packet[key]
      end
      ruby_packet
    end

  end

  # Thrown if an error is encountered reading the capture
  class CaptureReadError < StandardError
    attr_reader :index, :original

    # Create a new error
    #
    # @param [String] message The error message
    # @param [Integer] index The offset of the packet within the capture
    # @param [StandardError] original Any nested error (defaults to nil)
    def initialize(message, index, original=nil)
      super(message)
      @index, @original = index, original
    end
  end

end