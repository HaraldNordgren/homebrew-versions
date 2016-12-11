class Allegro < Formula
  version "4"
  homepage "http://www.allegro.cc"
  url "https://downloads.sourceforge.net/project/alleg/allegro/4.4.2/allegro-4.4.2.tar.gz"
  sha256 "1b21e7577dbfada02d85ca4510bd22fedaa6ce76fde7f4838c7c1276eb840fdc"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libvorbis" => :optional

  # Uses APIs no longer present on 10.9+
  depends_on MaximumMacOSRequirement => :mountain_lion

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
