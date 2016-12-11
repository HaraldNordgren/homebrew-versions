class Log4cplus < Formula
  version "10"
  homepage "http://log4cplus.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/log4cplus/log4cplus-stable/1.0.4/log4cplus-1.0.4.3.tar.bz2"
  sha256 "9af936fc4a25c3a59b7ae2c34ce95e08e8a705797ffe27e13272c01732649491"

  keg_only "Differing version of the same formula shipped in Homebrew/homebrew"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
