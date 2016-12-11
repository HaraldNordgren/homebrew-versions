class CloogPpl < Formula
  version "015"
  homepage "http://repo.or.cz/w/cloog-ppl.git"
  url "ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz"
  mirror "http://gcc.cybermirror.org/infrastructure/cloog-ppl-0.15.11.tar.gz"
  sha256 "7cd634d0b2b401b04096b545915ac67f883556e9a524e8e803a6bf6217a84d5f"

  keg_only "Conflicts with cloog in main repository."

  depends_on "gmp@4"
  depends_on "ppl@011"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-gmp=#{Formula["gmp4"].opt_prefix}"
      --with-ppl=#{Formula["ppl011"].opt_prefix}"
    ]

    system "./configure", *args
    system "make", "install"
  end
end
