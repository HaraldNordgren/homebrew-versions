class Nettle < Formula
  version "3"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "http://ftpmirror.gnu.org/nettle/nettle-3.1.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/nettle/nettle-3.1.1.tar.gz"
  sha256 "5fd4d25d64d8ddcb85d0d897572af73b05b4d163c6cc49438a5bfbb8ff293d4c"

  bottle do
    cellar :any
    sha256 "e50d9eab1bbc727db7176ce14e64583e10305edf29f58478f44e81e67129f6fb" => :yosemite
    sha256 "793f30f7cb3773776ad460a6cb65c63828d2030ebc6b09596f93c6925c22e95a" => :mavericks
    sha256 "24923b41a6bd4a1c126dbc5ff2d202e7a49ff79d360654691b40503be06e5886" => :mountain_lion
  end

  depends_on "gmp"

  keg_only "Conflicts with nettle in main repository and is not API compatible."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    system "make", "check"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected = /91b7b0b1e27bfbf7 bc646946f35fa972 c47c2d32/

    assert_match expected, shell_output("#{bin}/nettle-hash --a sha1 testfile.txt")
  end
end
