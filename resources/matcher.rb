actions :nothing

attribute :name, :name_attribute => true
attribute :type
attribute :path, :kind_of => Regexp
attribute :ignore, :kind_of => Array, :default => []
