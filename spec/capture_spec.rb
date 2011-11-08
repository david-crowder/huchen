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
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80}),
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80})
          ].join("\n"))
        end
        it "should parse json documents one per line for each packet" do
          capture.packets.size.should == 2
        end
        it "should return packets with all expected fields" do
          capture.packets.find{|packet| ! (packet.has_key?(:src_ip_address) && packet.has_key?(:dest_ip_address) && packet.has_key?(:src_port) && packet.has_key?(:dest_port)) }.should be_nil
        end
      end
      context "ill-formed json" do
        let(:capture) do
          Capture.new(:json_string => ['this is not json!',
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80})
          ].join("\n"))
        end
        it "should raise an error with the packet index if any packet cannot be parsed" do
          expect{capture.packets}.to raise_error(CaptureReadError, 'Packet could not be read: 0')
        end
      end
      context "missing fields" do
        let(:capture){Capture.new(:json_string => JSON.generate({'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80}))}
        it "should raise an error with the packet index if any packet is missing fields" do
          expect{capture.packets}.to raise_error(CaptureReadError, 'Packet missing field (:src_ip_address): 0')
        end
      end
    end
    describe "#http_requests" do
      context :curl_request do
        let(:capture) do
          Capture.new(:json_string => [
          JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Request' => {'URL' => {'Path' => '/'}, 'Host' => 'www.example.com', 'Header' => {'User-Agent' => ['curl/7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15']}}})
          ].join("\n"))
        end
        it "should parse HTTP requests" do
          capture.http_requests.size.should == 1
        end
        it "should return requests with all expected fields" do
          capture.http_requests.find{|req| ! ((req.has_key?(:src_ip_address) && req.has_key?(:dest_ip_address) && req.has_key?(:src_port) && req.has_key?(:dest_port)) && req.has_key?(:path) && req.has_key?(:host) && req.has_key?(:user_agent))}.should be_nil
        end
        it "should set the path correctly" do
          capture.http_requests.first[:path].should == '/'
        end
        it "should set the hostname correctly" do
          capture.http_requests.first[:host].should == 'www.example.com'
        end
        it "should set the hostname correctly" do
          capture.http_requests.first[:host].should == 'www.example.com'
        end
        it "should set the user agent correctly" do
          capture.http_requests.first[:user_agent].should == 'curl/7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15'
        end
      end
      context :missing_data do
        it "should cope when no hostname is specified" do
          capture = Capture.new(:json_string => [JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Request' => {'URL' => {'Path' => '/'}, 'Header' => {'User-Agent' => ['curl/7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15']}}})].join("\n"))
          capture.http_requests.first[:host].should be_nil
        end
        it "should cope when no user agent is specified" do
          capture = Capture.new(:json_string => [JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Request' => {'URL' => {'Path' => '/'}, 'Header' => {'Host' => 'www.example.com'}}})].join("\n"))
          capture.http_requests.first[:user_agent].should be_nil
        end
        it "should return only a single user agent" do
          capture = Capture.new(:json_string => [JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Request' => {'URL' => {'Path' => '/'}, 'Header' => {'Host' => 'www.example.com', 'User-Agent' => ['Mozilla/3.0 (Macintosh; I; 68K)', 'curl/7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15']}}})].join("\n"))
          capture.http_requests.first[:user_agent].should == 'Mozilla/3.0 (Macintosh; I; 68K)'
        end
        it "should raise an error when a path is not specified" do
          capture = Capture.new(:json_string => [JSON.generate({'SrcIp' => '10.0.2.15', 'DestIp' => '208.91.1.36', 'SrcPort' => 50042, 'DestPort' => 80, 'Request' => {'URL' => {}, 'Header' => {'Host' => 'www.example.com', 'User-Agent' => ['curl/7.19.7 (i486-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15']}}})].join("\n"))
          expect{capture.http_requests}.should raise_error(CaptureReadError, 'HTTP request missing field (:path): 0')
        end
      end
    end
  end
end