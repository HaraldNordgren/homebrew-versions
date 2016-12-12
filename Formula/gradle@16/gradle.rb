class Gradle < Formula
  version "16"
  desc "Build system based on the Groovy language"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-1.6-bin.zip"
  sha256 "de3e89d2113923dcc2e0def62d69be0947ceac910abd38b75ec333230183fac4"

  bottle :unneeded

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    ENV["GRADLE_USER_HOME"] = testpath
    assert_match "Gradle #{version}", shell_output("#{bin}/gradle --version")
  end
end
