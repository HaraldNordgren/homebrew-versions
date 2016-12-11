require 'formula'

class Gnutls < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'http://ftpmirror.gnu.org/gnutls/gnutls-3.1.0.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/gnutls/gnutls-3.1.0.tar.xz'
  sha256 '4fdb58572fb91fc0afbdfcd7845d4467d4b13ef2f9141bdaa955b959a319f8cc'

  depends_on 'xz' => :build
  depends_on 'pkg-config' => :build
  depends_on 'p11-kit'
  depends_on 'nettle'
  depends_on 'libidn'
  depends_on 'gmp'
  depends_on 'libtasn1'

  conflicts_with 'gnutls',
    :because => <<-EOS.undent
      GnuTLS 2.x and 3.x install identically named libraries,
      headers, executables, and other files.
      EOS

  # Fix an "undeclared identifier" error with clang
  def patches
    "http://git.savannah.gnu.org/cgit/gnutls.git/patch/?id=3b91334247"
  end

  def install
    ENV.append 'LDFLAGS', '-ltasn1'

    system "./configure", "--disable-dependency-tracking",
                          "--disable-guile",
                          "--disable-static",
                          "--disable-hardware-acceleration",
                          "--prefix=#{prefix}"
    system "make install"

    # certtool shadows the OS X certtool utility
    mv bin/'certtool', bin/'gnutls-certtool'
    mv man1/'certtool.1', man1/'gnutls-certtool.1'
  end
end
