class Giflib < Formula
  version "5"
  homepage "http://giflib.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.0.5.tar.bz2"
  sha256 "606d8a366b1c625ab60d62faeca807a799a2b9e88cbdf2a02bfcdf4429bf8609"

  keg_only "Conflicts with giflib in main repository."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
