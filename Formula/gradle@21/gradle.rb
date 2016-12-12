class Gradle < Formula
  version "21"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.1-bin.zip"
  sha256 "3eee4f9ea2ab0221b89f8e4747a96d4554d00ae46d8d633f11cfda60988bf878"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
