require 'formula'

class Allegro < Formula
  version "4"
  homepage 'http://www.allegro.cc'
  url 'http://downloads.sourceforge.net/project/alleg/allegro/4.4.1.1/allegro-4.4.1.1.tar.gz'
  md5 '0f1cfff8f2cf88e5c91a667d9fd386ec'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
