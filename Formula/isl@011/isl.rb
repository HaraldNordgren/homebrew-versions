require 'formula'

class Isl < Formula
  version "011"
  homepage 'http://freecode.com/projects/isl'
  url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.1.tar.bz2'
  sha1 'd7936929c3937e03f09b64c3c54e49422fa8ddb3'

  keg_only 'Conflicts with isl in main repository.'

  depends_on 'gmp@4'

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--with-gmp=system",
      "--with-gmp-prefix=#{Formula.factory('gmp4').opt_prefix}"
    ]

    system "./configure", *args
    system "make install"
  end
end
