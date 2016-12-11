class Tomcat < Formula
  version "7"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.tar.gz"
  sha256 "a787ea12e163e78ccebbb9662d7da78e707aef051d15af9ab5be20489adf1f6d"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "80ebcd42d337ab33d7bd0294193838e4d1a5945eafb44e07f254ba3e1229d725" => :yosemite
    sha256 "55c01b38aac5ec11ffcfbc5a8de7eff817afa4f964c4a50210f5a5021a611c06" => :mavericks
    sha256 "2f0d0aaa88b3a730d6c1b936c9251cba2968e15d89a5b1372e129870146969b3" => :mountain_lion
  end

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62-fulldocs.tar.gz"
    version "7.0.62"
    sha256 "46aa0412c1d0f041757e1e8dc9a0561507e3586a400165eafe4479e5adb5e86b"
  end

  # Keep log folders
  skip_clean "libexec"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w{ NOTICE LICENSE RELEASE-NOTES RUNNING.txt }
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
