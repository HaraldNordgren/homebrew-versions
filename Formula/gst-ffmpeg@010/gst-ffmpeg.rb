class GstFfmpeg < Formula
  version "010"
  homepage "http://gstreamer.freedesktop.org/"
  url "http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2"
  sha256 "76fca05b08e00134e3cb92fa347507f42cbd48ddb08ed3343a912def187fbb62"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base@010"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-ffmpeg-extra-configure=--cc=#{ENV.cc}
    ]

    system "./configure", *args
    system "make", "install"
  end
end
