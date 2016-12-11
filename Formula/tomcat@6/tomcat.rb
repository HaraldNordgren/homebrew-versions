require 'formula'

class Tomcat < Formula
  version "6"
  homepage 'http://tomcat.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz'
  sha1 '722e6e4f35983b28170002d6b89b4915db682db6'

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
