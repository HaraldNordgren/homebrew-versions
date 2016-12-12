class Gradle < Formula
  version "110"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-1.10-bin.zip"
  sha256 "6e6db4fc595f27ceda059d23693b6f6848583950606112b37dfd0e97a0a0a4fe"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
