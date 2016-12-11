class Autoconf < Formula
  version "213"
  homepage "https://www.gnu.org/software/autoconf/"
  url "http://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz"
  sha256 "f0611136bee505811e9ca11ca7ac188ef5323a8e2ef19cffd3edb3cf08fd791e"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--program-suffix=213",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--datadir=#{share}/autoconf213"
    system "make", "install"
  end
end
