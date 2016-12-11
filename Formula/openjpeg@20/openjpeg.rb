class Openjpeg < Formula
  version "20"
  homepage "http://www.openjpeg.org/"
  url "https://downloads.sourceforge.net/project/openjpeg.mirror/2.0.0/openjpeg-2.0.0.tar.gz"
  sha256 "334df538051555381ee3bbbe3a804c9c028a021401ba2960d6f35da66bf605d8"

  depends_on "cmake" => :build
  depends_on "little-cms2"
  depends_on "libtiff"
  depends_on "libpng"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
