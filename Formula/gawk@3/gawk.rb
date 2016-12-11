require 'formula'

class Gawk < Formula
  version "3"
  homepage 'http://www.gnu.org/software/gawk/'
  url 'http://ftpmirror.gnu.org/gawk/gawk-3.1.8.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gawk/gawk-3.1.8.tar.bz2'
  sha1 'da1091cc39089c320f53d21fd2112bd7ce407de5'

  fails_with_llvm "Undefined symbols when linking", :build => "2326"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
