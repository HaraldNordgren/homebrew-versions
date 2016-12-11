require 'formula'

class Play < Formula
  version "12"
  homepage 'http://www.playframework.org/'
  url 'http://downloads.typesafe.com/play/1.2.6/play-1.2.6.zip'
  sha1 '53f92eff7cc4c18c9f5fc399bb73351e7c7f18c5'

  def install
    rm_rf 'python' # we don't need the bundled Python for windows
    rm Dir['*.bat']
    libexec.install Dir['*']
    bin.mkpath
    ln_s libexec+'play', bin
  end
end
