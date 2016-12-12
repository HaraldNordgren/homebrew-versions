class Gradle < Formula
  version "20"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.0-bin.zip"
  sha256 "a1eb880c8755333c4d33c4351b269bebe517002532d3142c0b6164c9e8c081c3"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
