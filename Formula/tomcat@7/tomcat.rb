class Tomcat < Formula
  version "7"
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.64/bin/apache-tomcat-7.0.64.tar.gz"
  sha256 "76c729037f9fd6a0f44fa41c147c4c7291e68f74b79ec474c0bcef8a57661306"

  bottle do
    cellar :any
    sha256 "f6c06db34a30d321d153c6b45aa4b8c3b44e0d1e461f545e62d463736314f127" => :yosemite
    sha256 "a2f7bd36f8121948497cb2b77a1a25401e26a399ff825c0554d3a80eadd0dc43" => :mavericks
    sha256 "1ad8535333c5cc334c637127273255e1d2bb33a1976289e3a622531b78635383" => :mountain_lion
  end

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.64/bin/apache-tomcat-7.0.64-fulldocs.tar.gz"
    version "7.0.64"
    sha256 "72ee358e6da7fc02772ae4a6d78a24290d4693f30294c76557639c4c5c29b8a5"
  end

  # Keep log folders
  skip_clean "libexec"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[NOTICE LICENSE RELEASE-NOTES RUNNING.txt]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
