require 'formula'

class GstFfmpeg < Formula
  version "010"
  homepage 'http://gstreamer.freedesktop.org/'
  url 'http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2'
  sha1 '8de5c848638c16c6c6c14ce3b22eecd61ddeed44'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'homebrew/versions/gst-plugins-base@010'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ffmpeg-extra-configure=--cc=#{ENV.cc}"
    system "make install"
  end
end
