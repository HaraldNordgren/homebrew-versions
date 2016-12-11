class Phantomjs < Formula
  version "198"
  homepage "http://www.phantomjs.org/"
  url "https://github.com/ariya/phantomjs/archive/1.9.8.tar.gz"
  sha256 "3a321561677f678ca00137c47689e3379c7fe6b83f7597d2d5de187dd243f7be"

  depends_on "openssl"

  def install
    if MacOS.prefer_64_bit?
      inreplace "src/qt/preconfig.sh", "-arch x86", "-arch x86_64"
    end
    system "./build.sh", "--confirm", "--jobs", ENV.make_jobs,
      "--qt-config", "-openssl-linked"
    bin.install "bin/phantomjs"
    (share+"phantomjs").install "examples"
  end

  test do
    path = testpath/"test.js"
    path.write <<-EOS
      console.log("hello");
      phantom.exit();
    EOS

    assert_equal "hello", shell_output("#{bin}/phantomjs #{path}").strip
  end
end
