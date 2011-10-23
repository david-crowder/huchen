require 'chef/log'

module Huchen
  class Handler < Chef::Handler

    def report
      %x{killall pcap2json}
      raise "Failed to stop network capture" unless $?.success?
      capture = Capture.new(:json_file_path => node[:huchen][:capture_file])
      depends = Depends.new(capture.packets, node[:huchen][:ip_white_list])
      if depends.external_deps?
        Chef::Log.warn("This converge depends the following external dependencies and may not be repeatable:")
        Chef::Log.warn(depends.to_s)
      end
    end

  end
end

Chef::Config[:report_handlers] << Huchen::Handler.new