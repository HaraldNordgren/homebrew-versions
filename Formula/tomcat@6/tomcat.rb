require 'formula'

class Tomcat < Formula
  version "6"
  homepage 'http://tomcat.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz'
  sha1 '34f35928d1067327f2aab874cdcea0660a4a3875'

  keg_only "Some scripts that are installed conflict with other software."

  option "with-fulldocs", "Install full documentation locally"

  resource 'fulldocs' do
    url 'http://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41-fulldocs.tar.gz'
    version '6.0.41'
    sha1 '35a4dd8090754cbe00a2fc4674cc9587b9e5eba1'
  end

  def install
    rm_rf Dir['bin/*.{cmd,bat]}']
    libexec.install Dir['*']
    (libexec+'logs').mkpath
    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each { |f| ln_s f, bin }
    (share/'fulldocs').install resource('fulldocs') if build.with? 'fulldocs'
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
