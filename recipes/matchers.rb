huchen_matcher :debian do
  type :package
  path /.deb$/
  ignore [/(Sources|Packages).(bz2|gz|lzma)$/, /Release$/, /Release.gpg/]
end
