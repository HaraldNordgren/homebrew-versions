require 'formula'

class Libpng < Formula
  version "12"
  homepage 'http://www.libpng.org/pub/png/libpng.html'
  url 'http://sourceforge.net/projects/libpng/files/libpng12/1.2.49/libpng-1.2.49.tar.gz'
  md5 '39a35257cd888d29f1d000c2ffcc79eb'

  keg_only :provided_by_osx

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
    system "make test"

    # Move included test programs into libexec for later use
    libexec.install 'pngtest.png', '.libs/pngtest'
  end

  def test
    mktemp do
      system "#{libexec}/pngtest", "#{libexec}/pngtest.png"
      system "/usr/bin/qlmanage", "-p", "pngout.png"
    end
  end
end
