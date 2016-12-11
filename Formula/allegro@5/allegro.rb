require 'formula'

class Allegro < Formula
  version "5"
  homepage 'http://www.allegro.cc'
  url 'http://downloads.sourceforge.net/project/alleg/allegro/5.0.7/allegro-5.0.7.tar.gz'
  sha256 '47f29e564d9a4babfbbf024f34fc8a04eea932a073af921d17caffbec0c3ad9b'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
