class Jetty < Formula
  desc "Java servlet engine and webserver"
  homepage "https://www.eclipse.org/jetty/"
  url "http://download.eclipse.org/jetty/7.6.17.v20150415/dist/jetty-distribution-7.6.17.v20150415.tar.gz"
  version "7.6.17.v20150415"
  sha256 "57d6bbb48771944b8c2a3124240c0c4a78284a75db2b86018f543654dfd50eef"

  def install
    rm_rf Dir["bin/*.{cmd,bat]}"]

    libexec.install Dir["*"]
    (libexec+"logs").mkpath

    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each do |f|
      scriptname = File.basename(f, ".sh")
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} $@
      EOS
      chmod 0755, bin+scriptname
    end
  end
end
