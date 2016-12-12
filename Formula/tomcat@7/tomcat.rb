class Tomcat < Formula
  version "7"
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz"
  sha256 "2c1a02422f265607de733521e54f18613e9dd5efc2861914fe45a858227bb8e0"

  bottle :unneeded

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68-fulldocs.tar.gz"
    version "7.0.68"
    sha256 "c601d81217120ff2b645528ec579e33d1e5dc08cc27a7364aa5fad725b9b5f08"
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
