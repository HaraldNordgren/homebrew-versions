require 'formula'

class Gnutls < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'http://ftpmirror.gnu.org/gnutls/gnutls-3.0.18.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/gnutls/gnutls-3.0.18.tar.xz'
  sha1 '2aeac620a26e6c8f266954110578d8817939b084'

  depends_on 'pkg-config' => :build
  depends_on 'p11-kit'
  depends_on 'nettle'
  depends_on 'libidn'
  depends_on 'gmp'
  depends_on 'libtasn1' => :optional

  def install
    ENV.append 'LDFLAGS', '-ltasn1'

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
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
