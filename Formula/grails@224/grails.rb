require 'formula'

class Grails < Formula
  version "224"
  homepage 'http://grails.org'
  url 'http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.2.4.zip'
  sha1 'ac9568e71bd98d0459e97278bf56fce06627c23e'

  def install
    rm_f Dir["bin/*.bat", "bin/cygrails", "*.bat"]
    prefix.install %w[LICENSE README]
    libexec.install Dir['*']
    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      next unless File.extname(f).empty?
      ln_s f, bin+File.basename(f)
    end
  end
end
