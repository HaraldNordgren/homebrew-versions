class Ppl < Formula
  version "011"
  homepage "http://bugseng.com/products/ppl/"
  # Track gcc infrastructure releases.
  url "http://bugseng.com/products/ppl/download/ftp/releases/0.11/ppl-0.11.tar.gz"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/ppl-0.11.tar.gz"
  sha256 "3453064ac192e095598576c5b59ecd81a26b268c597c53df05f18921a4f21c77"
  revision 1

  conflicts_with "ppl10", :because => "They install the same binaries"

  depends_on "homebrew/dupes/m4" => :build if MacOS.version < :leopard
  depends_on "gmp@4"

  # https://www.cs.unipr.it/mantis/view.php?id=596
  # https://github.com/Homebrew/homebrew/issues/27431
  # Using different patch from upstream bug report to avoid autoreconf.
  patch do
    url "https://gist.githubusercontent.com/manphiz/9507743/raw/45081e12c2f1faf81e8536f365af05173c6dab5c/patch-ppl-flexible-array-clang_v2.patch"
    sha256 "db8ced5366ec4c3efb6fd20d3b4e440de3f8b9ec1d930a33b6a23d006dc25944"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-ppl_lpsol",
                          "--disable-ppl_lcdd",
                          "--disable-ppl_pips",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make", "install"
  end

  test do
    system bin/"ppl-config", "--bindir", "--libdir", "--license"
  end
end
