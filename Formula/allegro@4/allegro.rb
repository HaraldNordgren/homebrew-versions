require "formula"

class Allegro < Formula
  version "4"
  homepage "http://www.allegro.cc"
  url "https://downloads.sourceforge.net/project/alleg/allegro/4.4.2/allegro-4.4.2.tar.gz"
  sha1 "ae0c15d2cb6b0337ef388dc98cefc620883720df"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libvorbis" => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
