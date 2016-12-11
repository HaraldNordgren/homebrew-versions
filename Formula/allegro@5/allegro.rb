require 'formula'

class Allegro < Formula
  version "5"
  homepage 'http://www.allegro.cc'
  url 'http://downloads.sourceforge.net/project/alleg/allegro/5.0.8/allegro-5.0.8.tar.gz'
  sha1 '87249aa8dcc6070a425dcaa1aabdd0bbe0a881b3'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional
  depends_on 'freetype' => :optional
  depends_on 'flac' => :optional
  depends_on 'libpng' => :optional
  depends_on 'jpeg' => :optional
  depends_on 'physfs' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
