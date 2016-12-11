class Tomcat < Formula
  version "7"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz"
  sha256 "b5d878a17de2421a078d8907583076b507e67dbf1567c6f4346d70c88473f8ad"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "9f44bf780148b5f9a46b8a7e23243157c563d1405ad883e52113379e9ac73f96" => :yosemite
    sha256 "51d1d46ea51a1e843f2bc960250ee3bbe3d1e309aa31044d4bcea7f63558a007" => :mavericks
    sha256 "4bb7d4bd8c153963eaaf83c79d6c947bc83b264d7c380389f9696e2740412f05" => :mountain_lion
  end

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63-fulldocs.tar.gz"
    version "7.0.63"
    sha256 "a86abb866733565a054adaf02ccfb77fdea08d71c17978e1c1bc942090f63353"
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
