class Tomcat < Formula
  version "7"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz"
  sha256 "b5d878a17de2421a078d8907583076b507e67dbf1567c6f4346d70c88473f8ad"

  bottle do
    cellar :any
    sha256 "f6c06db34a30d321d153c6b45aa4b8c3b44e0d1e461f545e62d463736314f127" => :yosemite
    sha256 "a2f7bd36f8121948497cb2b77a1a25401e26a399ff825c0554d3a80eadd0dc43" => :mavericks
    sha256 "1ad8535333c5cc334c637127273255e1d2bb33a1976289e3a622531b78635383" => :mountain_lion
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
