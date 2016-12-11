class Leptonica < Formula
  version "169"
  homepage "http://www.leptonica.org/"
  url "http://www.leptonica.org/source/leptonica-1.69.tar.gz"
  sha256 "3eb7669dcda7e417f399bb3698414ea523270797dfd36c59b08ef37a3fe0a72d"

  depends_on "libpng" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "libtiff" => :optional

  conflicts_with "osxutils",
    :because => "both leptonica and osxutils ship a `fileinfo` executable."
  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/yuvtest"
  end
end
