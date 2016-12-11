require 'formula'

class Jetty < Formula
  homepage 'http://www.eclipse.org/jetty/'
  url 'http://download.eclipse.org/jetty/stable-7/dist/jetty-distribution-7.6.9.v20130131.tar.gz'
  version '7.6.9'
  sha1 '2aaad044f9fd049cf3795268f209297911c64e53'

  def install
    rm_rf Dir['bin/*.{cmd,bat]}']

    libexec.install Dir['*']
    (libexec+'logs').mkpath

    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each do |f|
      scriptname = File.basename(f, '.sh')
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} $@
      EOS
      chmod 0755, bin+scriptname
    end
  end
end
