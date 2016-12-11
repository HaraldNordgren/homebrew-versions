require 'formula'

class Play < Formula
  version "12"
  homepage 'http://www.playframework.org/'
  url 'http://download.playframework.org/releases/play-1.2.5.zip'
  sha1 'e675241b97ad19032569cd7b36b09c3b7f45bbc5'

  def install
    rm_rf 'python' # we don't need the bundled Python for windows
    rm Dir['*.bat']
    libexec.install Dir['*']
    bin.mkpath
    ln_s libexec+'play', bin
  end
end
