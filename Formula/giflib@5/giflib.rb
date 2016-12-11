require 'formula'

class Giflib < Formula
  version "5"
  homepage 'http://giflib.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.0.4.tar.bz2'
  sha1 'af3fdf84e2b9ac5c18e7102835a92e2066c7c9f1'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end
