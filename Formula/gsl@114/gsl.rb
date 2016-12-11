class Gsl < Formula
  version "114"
  homepage "https://www.gnu.org/software/gsl/"
  url "http://ftpmirror.gnu.org/gsl/gsl-1.14.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz"
  sha256 "3d4a47afd9a1e7c73b97791b4180d8cc4d5f0e5db6027fe06437f1f3f957fafb"

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make" # "make" and "make install" *must* be done separately
    system "make", "install"
  end

  test do
    system bin/"gsl-config", "--prefix", "--cflags", "--version"
  end
end

