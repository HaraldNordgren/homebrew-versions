class Gecode < Formula
  version "373"
  homepage "http://www.gecode.org/"
  url "http://www.gecode.org/download/gecode-3.7.3.tar.gz"
  sha256 "e7cc8bcc18b49195fef0544061bdd2e484a1240923e4e85fa39e8d6bb492854c"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-examples"
    system "make", "install"
  end

  test do
    system "#{bin}/fz", "-help"
  end
end
