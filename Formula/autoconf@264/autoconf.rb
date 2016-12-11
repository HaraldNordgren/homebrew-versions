require 'formula'

class Autoconf < Formula
  version "264"
  homepage 'http://www.gnu.org/software/autoconf/'
  url 'http://ftpmirror.gnu.org/autoconf/autoconf-2.64.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.64.tar.gz'
  sha1 '4341f861dac1ec79aecd36ff14df618b55b4e52b'

  def install
    system "./configure", "--program-suffix=264",
                          "--prefix=#{prefix}",
                          "--datadir=#{share}/autoconf264"
    system "make install"
  end
end
