require "formula"

class Play < Formula
  version "22"
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/2.2.3/play-2.2.3.zip"
  sha1 "16beea55568a6b5876439ffbf908ba6448c5c713"

  conflicts_with "sox", :because => "both install `play` binaries"

  def install
    rm_rf Dir["**/*.bat"]
    libexec.install Dir["*"]
    bin.install_symlink libexec/"play"
  end
end
