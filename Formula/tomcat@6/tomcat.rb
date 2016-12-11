require 'formula'

class Tomcat < Formula
  version "6"
  homepage 'http://tomcat.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz'
  sha1 'bfbc3944f0b2f87890e61bf31583ddb7cdf20fc0'

  keg_only "Some scripts that are installed conflict with other software."

  def install
    rm_rf Dir['bin/*.{cmd,bat]}']
    libexec.install Dir['*']
    (libexec+'logs').mkpath
    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each { |f| ln_s f, bin }
  end

  def caveats; <<-EOS.undent
    Some of the support scripts used by Tomcat have very generic names.
    These are likely to conflict with support scripts used by other Java-based
    server software.

    You can link Tomcat into PATH with:

      brew link tomcat@6

    or add #{bin} to your PATH instead.
    EOS
  end
end
