class Gradle < Formula
  version "27"
  desc "Gradle build automation tool"
  homepage "https://www.gradle.org/"
  url "https://services.gradle.org/distributions/gradle-2.7-bin.zip"
  sha256 "cde43b90945b5304c43ee36e58aab4cc6fb3a3d5f9bd9449bb1709a68371cb06"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    system "#{bin}/gradle", "-version"
  end
end
