class V8 < Formula
  version "315"
  homepage "https://code.google.com/p/v8/"
  # Use the official github mirror, it is easier to find tags there
  url "https://github.com/v8/v8-git-mirror/archive/3.15.11.18.tar.gz"
  sha256 "389c03f67731874342486536bd231c43281fe43d05001664000abd3ac48fd9cf"

  bottle do
    cellar :any
    sha1 "d2304e24d2fa6d6d499327d98755f4a0088d83d4" => :yosemite
    sha1 "1c3a4a0b45f0d5a706e048e80f5a497a6d2e02ec" => :mavericks
    sha1 "be82b18f5f267be5e11da92c62efb8a4c89f33c1" => :mountain_lion
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
