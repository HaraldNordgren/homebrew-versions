class Ppl < Formula
  version "10"
  homepage "http://bugseng.com/products/ppl/"
  url "http://bugseng.com/products/ppl/download/ftp/releases/1.0/ppl-1.0.tar.gz"
  sha256 "fd346687482ad51c1e98eb260bd61dd5a35a0cff5f580404380c88b0089a71b4"

  depends_on "homebrew/dupes/m4" => :build if MacOS.version < :leopard
  depends_on "gmp@4"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-ppl_lpsol",
                          "--disable-ppl_lcdd",
                          "--disable-ppl_pips",
                          "--with-gmp=#{Formula["gmp4"].opt_prefix}"
    system "make", "install"
  end

  test do
    system bin/"ppl-config", "--bindir", "--libdir", "--license"
  end
end
