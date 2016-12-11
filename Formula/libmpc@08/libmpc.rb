require 'formula'

class Libmpc < Formula
  version "08"
  homepage 'http://multiprecision.org'
  url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz'
  sha1 '5ef03ca7aee134fe7dfecb6c9d048799f0810278'

  keg_only 'Conflicts with libmpc in main repository.'

  depends_on 'gmp@4'
  depends_on 'mpfr@2'

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula.factory('gmp4').opt_prefix}",
      "--with-mpfr=#{Formula.factory('mpfr2').opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end
