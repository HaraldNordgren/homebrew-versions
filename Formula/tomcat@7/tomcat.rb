class Tomcat < Formula
  version "7"
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.65/bin/apache-tomcat-7.0.65.tar.gz"
  sha256 "ef0edb1f560702adc4096097ddfba038086d62da77d0b247d927fd326bc637e9"

  bottle :unneeded

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.65/bin/apache-tomcat-7.0.65-fulldocs.tar.gz"
    version "7.0.65"
    sha256 "a6c3f6d63d4057cf23bf98d2c339ba1e48ceb67ea42a9d8bd097a0a502cdedfa"
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
