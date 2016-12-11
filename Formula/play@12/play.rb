require 'formula'

class Play < Formula
  version "12"
  homepage 'http://www.playframework.org/'
  url 'http://download.playframework.org/releases/play-1.2.4.zip'
  md5 'ec8789f8cc02927ece536d102f5e649e'

  def install
    rm_rf 'python' # we don't need the bundled Python for windows
    rm Dir['*.bat']
    libexec.install Dir['*']
    bin.mkpath
    ln_s libexec+'play', bin
  end
end
