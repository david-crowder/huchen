require 'spec_helper'

module Huchen

  BASE_PKG =	{:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  SYNTAX_PKG =	{:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  ASN_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/universe/e/erlang/erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  MNESIA_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  UNMATCHED_REQUEST = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/foo.tar.gz', :user_agent => 'curl', :host => 'example.com'}
  RUNTIME_PKG =	{:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  CRYPTO_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  PK_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  INETS_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/main/e/erlang/erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  CORBA_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '91.189.92.180', :src_port => 43849, :dest_port => 80, :path => '/ubuntu/pool/universe/e/erlang/erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'us.archive.ubuntu.com'}
  RABBIT_PKG = {:src_ip_address => '10.0.2.15', :dest_ip_address => '208.91.1.36', :src_port => 49374, :dest_port => 80, :path => '/debian/pool/main/r/rabbitmq-server/rabbitmq-server_2.6.1-1_all.deb', :user_agent => 'Ubuntu APT-HTTP/1.3 (0.7.25.3ubuntu9.5)', :host => 'www.rabbitmq.com'}
  ALL_REQS = [BASE_PKG, SYNTAX_PKG, ASN_PKG, MNESIA_PKG, UNMATCHED_REQUEST, RUNTIME_PKG, CRYPTO_PKG, PK_PKG, INETS_PKG, CORBA_PKG, RABBIT_PKG]

  HTTP_REQUESTS = Class.new do
    def http_requests
      ALL_REQS
    end
  end

  class SampleMatcher
    attr_accessor :name, :type, :path, :ignore

    def initialize(name, type, path, ignore)
      @name, @type, @path, @ignore = name, type, path, ignore
    end
  end

  EMPTY_CAPTURE = Class.new do
    def http_requests
      []
    end
  end

  DEBIAN_PKG_MATCHER = SampleMatcher.new(:debian, :package, /.deb$/, [])

  describe Depends do
    context :no_matchers do
      describe "#initialize" do
        it "should accept an empty capture" do
          Depends.new([], EMPTY_CAPTURE.new)
        end
        it "should accept a capture containing http requests" do
          Depends.new([], HTTP_REQUESTS.new)
        end
        it "should accept an empty set of matchers" do
          Depends.new([], EMPTY_CAPTURE.new)
        end
      end
      describe "#external_deps?" do
        it "should return true when there are external dependencies" do
          Depends.new([], HTTP_REQUESTS.new).external_deps?.should be_true
        end
        it "should return false when there are no external dependencies" do
          Depends.new([], EMPTY_CAPTURE.new).external_deps?.should be_false
        end
      end
      describe "#packages" do
        Depends.new([], HTTP_REQUESTS.new).packages.should == []
      end
      describe "unmatched" do
        Depends.new([], HTTP_REQUESTS.new).unmatched.should == HTTP_REQUESTS.new.http_requests
      end
      describe "#to_s" do
        it "should return empty when the capture is empty" do
          Depends.new([], EMPTY_CAPTURE.new).to_s.should == ''
        end
        it "should include all requests in the string representation when there are no matchers" do
          Depends.new([], HTTP_REQUESTS.new).to_s.should ==
              HTTP_REQUESTS.new.http_requests.map{|req| "[unmatched] #{req.to_s}"}.join("\n")
        end
      end
    end

    context :with_package_matcher do
      describe "#initialize" do
        it "should accept an empty capture" do
          Depends.new([DEBIAN_PKG_MATCHER], EMPTY_CAPTURE.new)
        end
        it "should accept a capture containing http requests" do
          Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new)
        end
        it "should accept a single matcher" do
          Depends.new([DEBIAN_PKG_MATCHER], EMPTY_CAPTURE.new)
        end
      end
      describe "#external_deps?" do
        it "should return true when there are external dependencies" do
          Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new).external_deps?.should be_true
        end
        it "should return false when there are no external dependencies" do
          Depends.new([DEBIAN_PKG_MATCHER], EMPTY_CAPTURE.new).external_deps?.should be_false
        end
      end
      describe "#packages" do
        it "should return the packages discovered by any matchers" do
          Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new).packages.should == [
              {:name => 'erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => ASN_PKG},
              {:name => 'erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => BASE_PKG},
              {:name => 'erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => CORBA_PKG},
              {:name => 'erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => CRYPTO_PKG},
              {:name => 'erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => INETS_PKG},
              {:name => 'erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => MNESIA_PKG},
              {:name => 'erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => PK_PKG},
              {:name => 'erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => RUNTIME_PKG},
              {:name => 'erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :type => 'debian_package', :host => 'us.archive.ubuntu.com', :request => SYNTAX_PKG},
              {:name => 'rabbitmq-server_2.6.1-1_all.deb', :type => 'debian_package', :host => 'www.rabbitmq.com', :request => RABBIT_PKG}
          ]
        end
      end
      describe "unmatched" do
        Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new).unmatched.should == [UNMATCHED_REQUEST]
      end
      describe "#to_s" do
        def with_no_indent(msg)
          msg.gsub(/^ +/, '').strip
        end
        it "should include packages in the string representation" do
          package_list = <<-eos
            [debian_package] erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb (us.archive.ubuntu.com)
            [debian_package] rabbitmq-server_2.6.1-1_all.deb (www.rabbitmq.com)
          eos
          Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new).to_s.should include with_no_indent(package_list)
        end
        it "should include unmatched requests in the string representation" do
          unmatched_msg = <<-eos
            [unmatched] {:src_ip_address=>"10.0.2.15", :dest_ip_address=>"91.189.92.180", :src_port=>43849, :dest_port=>80, :path=>"/foo.tar.gz", :user_agent=>"curl", :host=>"example.com"}
          eos
          Depends.new([DEBIAN_PKG_MATCHER], HTTP_REQUESTS.new).to_s.should include with_no_indent(unmatched_msg)
        end
      end
    end
  end

end