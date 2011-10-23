require 'spec_helper'

module Huchen
  describe Capture do
    describe "#initialize" do
      context "file path passed" do
        it "should accept a capture json file as an argument" do
          json_file = File.join(Dir.tmpdir, 'huchen.json')
          FileUtils.touch(json_file)
          Capture.new(:json_file_path => json_file)
        end
        it "should raise an error immediately if the file does not exist" do
          expect{Capture.new(:json_file_path => 'non-existent.json')}.should raise_error(ArgumentError, "Capture file 'non-existent.json' could not be found.")
        end
      end
      context "json string passed" do
        it "should accept a capture json string as an argument" do
          Capture.new(:json_string => '[]')
        end
        it "should raise an error if the json string is nil" do
          expect{Capture.new(:json_string => nil)}.should raise_error(ArgumentError, ':json_string cannot be nil or empty')
        end
        it "should raise an error if the json string is empty" do
          expect{Capture.new(:json_string => '')}.should raise_error(ArgumentError, ':json_string cannot be nil or empty')
        end
      end
      it "should raise an error if neither a file path or json string is passed" do
        expect{Capture.new({})}.should raise_error(ArgumentError, 'You must provide either a :json_file_path or :json_string')
      end
    end
    describe "#packets" do
      context "well-formed json" do
        let(:capture) do
          Capture.new(:json_string => [
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Data' => 'first packet'}),
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Data' => 'second packet'})
          ].join("\n"))
        end
        it "should parse json documents one per line for each packet" do
          capture.packets.size.should == 2
        end
        it "should return packets with all expected fields" do
          capture.packets.find{|packet| ! (packet.has_key?(:src_ip_address) && packet.has_key?(:dest_ip_address) && packet.has_key?(:src_port) && packet.has_key?(:dest_port) && packet.has_key?(:data)) }.should be_nil
        end
      end
      context "ill-formed json" do
        let(:capture) do
          Capture.new(:json_string => ['this is not json!',
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Data' => 'second packet'})
          ].join("\n"))
        end
        it "should raise an error with the packet index if any packet cannot be parsed" do
          expect{capture.packets}.to raise_error(CaptureReadError, 'Packet could not be read: 0')
        end
      end
      context "missing fields" do
        let(:capture){Capture.new(:json_string => JSON.generate({'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Data' => 'first packet'}))}
        it "should raise an error with the packet index if any packet is missing fields" do
          expect{capture.packets}.to raise_error(CaptureReadError, 'Packet missing field (:src_ip_address): 0')
        end
      end

    end
  end
end