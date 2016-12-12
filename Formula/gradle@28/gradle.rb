class Gradle < Formula
  version "28"
  desc "Gradle build automation tool"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.8-bin.zip"
  sha256 "a88db9c2f104defdaa8011c58cf6cda6c114298ae3695ecfb8beb30da3a903cb"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    system "#{bin}/gradle", "-version"
  end
end
