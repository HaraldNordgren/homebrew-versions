require 'formula'

class Ppl < Formula
  version "011"
  homepage 'http://bugseng.com/products/ppl/'
  url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/ppl-0.11.tar.gz'
  sha1 'b3b12de9bcd156ed9254f76259835f40e162afc8'

  keg_only 'Conflicts with ppl in main repository.'

  depends_on 'gmp@4'

  def install
    gmp4 = Formula.factory 'gmp4'

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--enable-optimization=sspeed",
      "--with-gmp=#{gmp4.opt_prefix}"
    ]

    system "./configure", *args
    system "make install"
  end
end
