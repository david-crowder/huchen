require 'spec_helper'

module Huchen
  describe Depends do
    describe "#initialize" do
      it "should accept an empty array of packets" do
        Depends.new []
      end
      it "should accept an array of packets" do
        Depends.new PACKETS
      end
      it "should accept an ip whitelist to ignore" do
        Depends.new PACKETS
      end
    end
    describe "#http_requests" do
      it "should return the hosts and requests made to each host" do
        depends = Depends.new(PACKETS)
        depends.http_requests.should eql HTTP_REQUESTS
      end
      it "should exclude requests made to whitelisted hosts" do
        depends = Depends.new(PACKETS, ['91.189.92.177'])
        depends.http_requests.should be_empty
      end
    end
    describe "#packages" do
      it "should recognise debian packages" do
        depends = Depends.new(PACKETS)
        depends.packages.should eql PACKAGES
      end
      it "should ignore packages served from a whitelisted host" do
        depends = Depends.new(PACKETS, ['91.189.92.177'])
        depends.packages.should be_empty
      end
    end
    describe "#external_deps?" do
      it "should return true when there are external dependencies" do
        Depends.new(PACKETS).external_deps?.should be_true
      end
      it "should return false when there are no external dependencies" do
        Depends.new([]).external_deps?.should be_false
      end
      it "should return false when there are external dependencies but they are served from a whitelisted host" do
        Depends.new(PACKETS, ['91.189.92.177']).external_deps?.should be_false
      end
    end
    describe "#to_s" do
      let(:depends) { Depends.new(PACKETS) }
      it "should include a sorted list of packages in the string representation" do
        package_list = <<-eos
          [package] erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-ssl_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
          [package] erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb (91.189.92.177)
        eos
        depends.to_s.should include package_list.gsub(/^ +/, '').strip
      end
    end
  end

  PACKETS = [
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "208.91.1.36", :src_port => 50043, :dest_port => 80, :data => "\nRT..5...'AS...E..(..@.@.]B.....[\n.$.{.P..]..xZRP....E.."},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "208.91.1.36", :src_port => 50046, :dest_port => 80, :data => "\nRT..5...'AS...E..\u003cx\"@.@........[\n.$.~.P..ag.........t............\n.E........"},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E..\u003c.]@.@.......[.\n\\....P.V........... ............\n.G........"},
      {:src_ip_address => "91.189.92.177", :dest_ip_address => "10.0.2.15", :src_port => 80, :dest_port => 48780, :data => "\n..'AS.RT..5...E..,....@...[.\\...\n...P.......V..`............."},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E..(.^@.@.......[.\n\\....P.V......P......."},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E...._@.@..?....[.\n\\....P.V......P....K..GET /ubunt\nu/pool/main/e/erlang/erlang-base\n_13.b.3-dfsg-2ubuntu2.1_i386.deb\n HTTP/1.1..Host: us.archive.ubun\ntu.com..Connection: keep-alive..\nUser-Agent: Ubuntu APT-HTTP/1.3 \n(0.7.25.3ubuntu9.5)....GET /ubun\ntu/pool/main/e/erlang/erlang-syn\ntax-tools_13.b.3-dfsg-2ubuntu2.1\n_i386.deb HTTP/1.1..Host: us.arc\nhive.ubuntu.com..Connection: kee\np-alive..User-Agent: Ubuntu APT-\nHTTP/1.3 (0.7.25.3ubuntu9.5)....\nGET /ubuntu/pool/universe/e/erla\nng/erlang-asn1_13.b.3-dfsg-2ubun\ntu2.1_i386.deb HTTP/1.1..Host: u\ns.archive.ubuntu.com..Connection\n: keep-alive..User-Agent: Ubuntu\n APT-HTTP/1.3 (0.7.25.3ubuntu9.5\n)....GET /ubuntu/pool/main/e/erl\nang/erlang-mnesia_13.b.3-dfsg-2u\nbuntu2.1_i386.deb HTTP/1.1..Host\n: us.archive.ubuntu.com..Connect\nion: keep-alive..User-Agent: Ubu\nntu APT-HTTP/1.3 (0.7.25.3ubuntu\n9.5)....GET /ubuntu/pool/main/e/\nerlang/erlang-runtime-tools_13.b\n.3-dfsg-2ubuntu2.1_i386.deb HTTP\n/1.1..Host: us.archive.ubuntu.co\nm..Connection: keep-alive..User-\nAgent: Ubuntu APT-HTTP/1.3 (0.7.\n25.3ubuntu9.5)....GET /ubuntu/po\nol/main/e/erlang/erlang-crypto_1\n3.b.3-dfsg-2ubuntu2.1_i386.deb H\nTTP/1.1..Host: us.archive.ubuntu\n.com..Connection: keep-alive..Us\ner-Agent: Ubuntu APT-HTTP/1.3 (0\n.7.25.3ubuntu9.5)....GET /ubuntu\n/pool/main/e/erlang/erlang-publi\nc-key_13.b.3-dfsg-2ubuntu2.1_i38\n6.deb HTTP/1.1..Host: us.archive\n.ubuntu.com..Connection: keep-al\nive..User-Agent: Ubuntu APT-HTTP\n/1.3 (0.7.25.3ubuntu9.5)....GET \n/ubuntu/pool/main/e/erlang/erlan\ng-ssl_13.b.3-dfsg-2ubuntu2.1_i38\n6.deb HTTP"},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E..\".`@.@.......[.\n\\....P.V......P......./1.1..Host\n: us.archive.ubuntu.com..Connect\nion: keep-alive..User-Agent: Ubu\nntu APT-HTTP/1.3 (0.7.25.3ubuntu\n9.5)....GET /ubuntu/pool/main/e/\nerlang/erlang-inets_13.b.3-dfsg-\n2ubuntu2.1_i386.deb HTTP/1.1..Ho\nst: us.archive.ubuntu.com..Conne\nction: keep-alive..User-Agent: U\nbuntu APT-HTTP/1.3 (0.7.25.3ubun\ntu9.5)....GET /ubuntu/pool/unive\nrse/e/erlang/erlang-corba_13.b.3\n-dfsg-2ubuntu2.1_i386.deb HTTP/1\n.1..Host: us.archive.ubuntu.com.\n.Connection: keep-alive..User-Ag\nent: Ubuntu APT-HTTP/1.3 (0.7.25\n.3ubuntu9.5)...."},
      {:src_ip_address => "91.189.92.177", :dest_ip_address => "10.0.2.15", :src_port => 80, :dest_port => 48780, :data => "\n..'AS.RT..5...E..(....@...[.\\...\n...P.......V..P............."},
      {:src_ip_address => "91.189.92.177", :dest_ip_address => "10.0.2.15", :src_port => 80, :dest_port => 48780, :data => "\n..'AS.RT..5...E.......@..-[.\\...\n...P.......V..P....N..HTTP/1.1 2\n00 OK..Date: Sun, 23 Oct 2011 00\n:44:35 GMT..Server: Apache/2.2.1\n4 (Ubuntu)..Last-Modified: Thu, \n07 Oct 2010 10:05:43 GMT..ETag: \n\"ae086d-3fa1d2-4920409748bc0\"..A\nccept-Ranges: bytes..Content-Len\ngth: 4170194..Keep-Alive: timeou\nt=15, max=100..Connection: Keep-\nAlive..Content-Type: application\n/x-debian-package....!\u003carch\u003e.deb\nian-binary   1286287208  0     0\n     100644  4         `.2.0.con\ntrol.tar.gz  1286287208  0     0\n     100644  15953     `........\n....}ks#...........=&..G...w....\n........M..&.#...`K......B....nd\n......I.u++.\u003e..y3......%pyk..q..\n.....*..5.=...df?.+\\..]..f.lV...\n.....'......n....f........'BJk.'\n3.\u003c....G.ev.........&U.m.f....j3\n..\"-..s......-..Y}s..K.E...|uv..\n.......77is7[.........v.W.r...,.\nT_........G.1+.e._.nh...|x..B...\n....z..6..j.....E=....j.;.]_oR..\n%}..],u1/......n....-.......n7hg\n*..k..=.....+.._........-..o.c..\n.7ej.....}.kx..........#7.a\u003c..v.\n.......v....r..:.x...iq9.....X..\nmV7.`..@..4..X........`./...o..n\n.u..\u003c....t...._vIu.[..Q.w...i...\nZ..YZ.I.......n.v.{3K,......EmYn\n..n..5..h..l7{..kZ...2.n.l;Jx...\n....~......u{l....d..@...?......\nc..x)_..g.7...?......5........}.\n)..7..?@.z1.....gu......u.N...y.\n..5./........B.s.b.S~....aT..f..\n...(m..A!.B[.....g....7.+tj.....\n...c......x...m./YI.x......=....\nq............/?...W...iW....z...\nf...Jo/....=.X..\u003e..\u003e.......o.bG.\nax.s.*|......_....C?..Zp$...o~.z\n...................g._.]~..?.`..\no_=....?y.K.6g.......w...7..}...\n..|.........?.r...V.o..}..P.._..\n.."},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E..(.a@.@.......[.\n\\....P.V......P.!Hx..."},
      {:src_ip_address => "91.189.92.177", :dest_ip_address => "10.0.2.15", :src_port => 80, :dest_port => 48780, :data => "\n..'AS.RT..5...E..D....@...[.\\...\n...P.......V..P...\\...]..~.j..ck\n~.R.......3Z@_...."},
      {:src_ip_address => "10.0.2.15", :dest_ip_address => "91.189.92.177", :src_port => 48780, :dest_port => 80, :data => "\nRT..5...'AS...E..(.b@.@.......[.\n\\....P.V......P.!Hx..."}]

  HTTP_REQUESTS = [{:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/universe/e/erlang/erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-ssl_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/main/e/erlang/erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb'},
                   {:host => '91.189.92.177', :method => :GET, :path => '/ubuntu/pool/universe/e/erlang/erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb'}]

  PACKAGES = [{:host => '91.189.92.177', :file_name => 'erlang-base_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-syntax-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-asn1_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-mnesia_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-runtime-tools_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-crypto_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-public-key_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-ssl_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-inets_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb},
              {:host => '91.189.92.177', :file_name => 'erlang-corba_13.b.3-dfsg-2ubuntu2.1_i386.deb', :format => :deb}]
end