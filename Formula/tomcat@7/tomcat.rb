class Tomcat < Formula
  version "7"
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.64/bin/apache-tomcat-7.0.64.tar.gz"
  sha256 "76c729037f9fd6a0f44fa41c147c4c7291e68f74b79ec474c0bcef8a57661306"

  bottle do
    cellar :any
    sha256 "9de99ef0c276d781b7f0221c4869af47f5cddf7cbb234a1496254149810a6bc1" => :yosemite
    sha256 "9afff974b90c8c52beaf6b6f91b529fb0b241c6af64b31c358db4a4ad204999a" => :mavericks
    sha256 "24ef38275d081c6b405ee2b45cf6e56ef7910402e9a1464a5e614de2127be066" => :mountain_lion
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
