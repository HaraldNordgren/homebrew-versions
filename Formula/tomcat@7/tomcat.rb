require 'formula'

class Tomcat < Formula
  version "7"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61.tar.gz"
  sha256 "2528ad7434e44ab1198b5692d5f831ac605051129119fd81a00d4c75abe1c0e0"

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.61/bin/apache-tomcat-7.0.61-fulldocs.tar.gz"
    version "7.0.61"
    sha256 "30f0ccc080a46dd7fc2dfaccd3f3b8efdec5d5d42e235637e1de518a77ea86f3"
  end

  # Keep log folders
  skip_clean 'libexec'

  def install
    # Remove Windows scripts
    rm_rf Dir['bin/*.bat']

    # Install files
    prefix.install %w{ NOTICE LICENSE RELEASE-NOTES RUNNING.txt }
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/'fulldocs').install resource('fulldocs') if build.with? 'fulldocs'
  end
end
