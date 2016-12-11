require 'formula'

class Libpng < Formula
  version "12"
  homepage 'http://www.libpng.org/pub/png/libpng.html'
  url 'http://sourceforge.net/projects/libpng/files/libpng12/1.2.50/libpng-1.2.50.tar.gz'
  sha1 'aeb8afdfed3a8be46c9a7be4aa853bce73f03d9e'

  keg_only :provided_by_osx

  option :universal

  def install
    ENV.universal_binary if build.universal?
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
