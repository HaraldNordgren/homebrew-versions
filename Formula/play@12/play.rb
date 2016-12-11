require 'formula'

class Play < Formula
  version "12"
  homepage 'http://www.playframework.org/'
  url 'http://download.playframework.org/releases/play-1.2.5.zip'
  md5 '31d204bb105f67c5e418fad073e818a4'

  def install
    rm_rf 'python' # we don't need the bundled Python for windows
    rm Dir['*.bat']
    libexec.install Dir['*']
    bin.mkpath
    ln_s libexec+'play', bin
  end
end
