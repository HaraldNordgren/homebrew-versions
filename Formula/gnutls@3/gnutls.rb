require 'formula'

class Gnutls < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'http://ftpmirror.gnu.org/gnutls/gnutls-3.1.3.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/gnutls/gnutls-3.1.3.tar.xz'
  sha256 'fcb236c663489d3dba5a3f41486810f3889eb4508403ebeeb58b79f0b34bce39'

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
