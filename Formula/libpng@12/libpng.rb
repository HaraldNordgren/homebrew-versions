class Libpng < Formula
  version "12"
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng12/libpng-1.2.54.tar.xz"
  mirror "https://dl.bintray.com/homebrew/mirror/libpng-1.2.54.tar.xz"
  sha256 "cf85516482780f2bc2c5b5073902f12b1519019d47bf473326c2018bdff1d272"

  bottle do
    cellar :any
    sha256 "5dce4e061796e9ba41112b3f0dfd2ede83eff085e2c5fa19ceb5839a63867a41" => :yosemite
    sha256 "88360558925258c5d2701088de404ac253952e572ed1917f3e6281f3b04d6732" => :mavericks
    sha256 "37b4c67b1a155c392fe0813924b8e8bae8eb0bce565bf70003d712a7a28bd41e" => :mountain_lion
  end

  keg_only :provided_by_osx

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <png.h>

      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
