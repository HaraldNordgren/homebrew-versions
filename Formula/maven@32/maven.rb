class Maven < Formula
  version "32"
  desc "Java-based project management"
  homepage "https://maven.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz"
  mirror "https://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz"
  sha256 "8c190264bdf591ff9f1268dc0ad940a2726f9e958e367716a09b8aaa7e74a755"

  depends_on :java

  conflicts_with "maven", because: "Differing versions of same formula"
  conflicts_with "mvnvm", because: "Also installs a 'mvn' executable"

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Fix the permissions on the global settings file.
    chmod 0644, "conf/settings.xml"

    prefix.install_metafiles
    libexec.install Dir["*"]

    # Leave conf file in libexec. The mvn symlink will be resolved and the conf
    # file will be found relative to it
    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?
      basename = file.basename
      next if basename.to_s == "m2.conf"
      (bin/basename).write_env_script file, Language::Java.overridable_java_home_env
    end
  end

  test do
    (testpath/"pom.xml").write <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <project xmlns="https://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="https://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
        <modelVersion>4.0.0</modelVersion>
        <groupId>org.homebrew</groupId>
        <artifactId>maven-test</artifactId>
        <version>1.0.0-SNAPSHOT</version>
      </project>
    EOS
    (testpath/"src/main/java/org/homebrew/MavenTest.java").write <<-EOS.undent
      package org.homebrew;
      public class MavenTest {
        public static void main(String[] args) {
          System.out.println("Testing Maven with Homebrew!");
        }
      }
    EOS
    system "#{bin}/mvn", "compile"
  end
end
