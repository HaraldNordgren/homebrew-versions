class Nettle < Formula
  version "3"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "http://ftpmirror.gnu.org/nettle/nettle-3.1.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/nettle/nettle-3.1.1.tar.gz"
  sha256 "5fd4d25d64d8ddcb85d0d897572af73b05b4d163c6cc49438a5bfbb8ff293d4c"

  bottle do
    cellar :any
    sha256 "2db3415ff6544faed8598feabfc475f3ea957d07d33827aef6aeed4113ddde12" => :yosemite
    sha256 "7cb14ed90e62a313c8142bc4859d9f2ec96a7361d9333a8c6dcf03313969c110" => :mavericks
    sha256 "3da69c796e7dd4b4bcce4d5612806388ab0d5c5badfae82b0d2be8138525ff8d" => :mountain_lion
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
