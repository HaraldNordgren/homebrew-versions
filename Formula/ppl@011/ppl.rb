require 'formula'

class Ppl < Formula
  version "011"
  homepage 'http://bugseng.com/products/ppl/'
  # Track gcc infrastructure releases.
  url 'http://bugseng.com/products/ppl/download/ftp/releases/0.11/ppl-0.11.tar.gz'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/ppl-0.11.tar.gz'
  sha1 'b3b12de9bcd156ed9254f76259835f40e162afc8'

  keg_only 'Conflicts with ppl in main repository.'

  depends_on 'homebrew/dupes/m4' => :build if MacOS.version < :leopard
  depends_on 'gmp@4'

  def install
    gmp4 = Formula.factory 'gmp4'

    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp-prefix=#{gmp4.opt_prefix}"
    ]

    system "./configure", *args
    system "make install"
  end
end
