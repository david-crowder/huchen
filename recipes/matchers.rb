huchen_matcher :debian do
  type :package
  path /\.deb$/
  ignore [/(Sources|Packages)\.(bz2|gz|lzma)$/, /Release(\.gpg)?$/]
end

huchen_matcher :perl do
  type :package
  path /\/authors\/id\/.*\.tar.gz$/
  ignore [/01mailrc\.txt\.gz$/, /02packages\.details\.txt\.gz$/, /03modlist\.data\.gz$/, /CHECKSUMS$/]
end

huchen_matcher :python do
  type :package
  path /\/packages\/source\/[a-z]\/.*\.tar\.gz$/
  ignore [/^\/distribute_setup.py$/, /\/simple\/.*/]
end

huchen_matcher :rubygem do
  type :package
  path /\.gem$/
  ignore [/\/(latest_)?specs\.[0-9]+.[0-9]+.gz$/, /.gemspec.rz$/]
end
