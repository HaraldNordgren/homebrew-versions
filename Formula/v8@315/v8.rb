class V8 < Formula
  version "315"
  homepage "https://code.google.com/p/v8/"
  # Use the official github mirror, it is easier to find tags there
  url "https://github.com/v8/v8-git-mirror/archive/3.15.11.18.tar.gz"
  sha256 "389c03f67731874342486536bd231c43281fe43d05001664000abd3ac48fd9cf"

  bottle do
    cellar :any
    sha256 "bed2afae1630434447484cbb92115f672b10c7ce87261ed8995a941e72ff8ab6" => :yosemite
    sha256 "dc6075d9424ed14a7755290e042a6932eef2ef133d2f9b2700fafb604fc177fc" => :mavericks
    sha256 "1694a71ceebcb40161161984ceeb0c2c8c0683a99e294a4a2d7f353d2cf2675f" => :mountain_lion
  end

  keg_only "Conflicts with V8 in Homebrew/homebrew."

  def install
    system "make", "dependencies"
    system "make", "native",
                   "-j#{ENV.make_jobs}",
                   "library=shared",
                   "snapshot=on",
                   "console=readline"

    prefix.install "include"
    cd "out/native" do
      lib.install Dir["lib*"]
      bin.install "d8", "lineprocessor", "mksnapshot", "preparser", "process", "shell" => "v8"
    end
  end
end
