class Gradle < Formula
  version "18"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-1.8-bin.zip"
  sha256 "a342bbfa15fd18e2482287da4959588f45a41b60910970a16e6d97959aea5703"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
