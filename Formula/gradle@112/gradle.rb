class Gradle < Formula
  version "112"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-1.12-bin.zip"
  sha256 "8734b13a401f4311ee418173ed6ca8662d2b0a535be8ff2a43ecb1c13cd406ea"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
