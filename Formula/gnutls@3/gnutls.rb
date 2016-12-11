require 'formula'

class Gnutls < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gnutls/gnutls.html'
  url 'http://ftpmirror.gnu.org/gnutls/gnutls-3.0.21.tar.xz'
  mirror 'http://ftp.gnu.org/gnu/gnutls/gnutls-3.0.21.tar.xz'
  sha256 '6901b0203a613869cf475f18d44acd47b36adf714c67d1f9ad29c26ab7bec410'

  depends_on 'xz' => :build
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
