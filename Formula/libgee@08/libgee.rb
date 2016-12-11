class Libgee < Formula
  version "08"
  homepage "https://wiki.gnome.org/Projects/Libgee"
  url "http://ftp.gnome.org/pub/GNOME/sources/libgee/0.8/libgee-0.8.0.tar.xz"
  sha256 "5e3707cbc1cebea86ab8865682cb28f8f80273869551c3698e396b5dc57831ea"

  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gobject-introspection"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
