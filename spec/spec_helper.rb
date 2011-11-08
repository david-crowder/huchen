require 'json'
require 'tmpdir'
%w{capture depends}.each{|lib| require File.join(File.dirname(__FILE__), '..', 'libraries', lib)}