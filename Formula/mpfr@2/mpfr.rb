require 'formula'

class Mpfr < Formula
  version "2"
  homepage 'http://www.mpfr.org/'
  # Tracking legacy version on gcc ftp
  url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2'
  sha1 '7ca93006e38ae6e53a995af836173cf10ee7c18c'

  depends_on 'gmp@4'

  keg_only 'Conflicts with mpfr in main repository.'

  option '32-bit'

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/mxcl/homebrew/issues/15061
      EOS
  end

  def install
    gmp4 = Formula.factory 'gmp4'

    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--with-gmp=#{gmp4.opt_prefix}"
    ]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    # Note: This logic should match what the GMP formula does.
    if MacOS.prefer_64_bit? and not build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--build=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end
