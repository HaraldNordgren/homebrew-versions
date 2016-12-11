class Play < Formula
  version "13"
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.3.0/play-1.3.0.zip"
  sha1 "0637fc40bc98675f56d3f408e73be6e6c067c789"

  def install
    rm_rf "python" # we don't need the bundled Python for windows
    rm Dir["*.bat"]
    libexec.install Dir["*"]
    bin.mkpath
    chmod 0755, libexec+"play"
    ln_s libexec+"play", bin
  end
end
