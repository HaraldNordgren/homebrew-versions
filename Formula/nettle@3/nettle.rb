class Nettle < Formula
  version "3"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "http://ftpmirror.gnu.org/nettle/nettle-3.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/nettle/nettle-3.1.tar.gz"
  sha256 "f6859d4ec88e70805590af9862b4b8c43a2d1fc7991df0a7a711b1e7ca9fc9d3"

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
