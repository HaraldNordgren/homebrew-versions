require 'formula'

class Gnutls < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'http://ftpmirror.gnu.org/gnutls/gnutls-3.0.20.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/gnutls/gnutls-3.0.20.tar.xz'
  sha256 '7e3f431a43e5366ff5a9b7646d2a79892a905237ef18cb147b945ec99012686d'

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
