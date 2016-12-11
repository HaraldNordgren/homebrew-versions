require 'formula'

class ScalaDocs < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/files/archive/scala-docs-2.9.3.zip'
  sha1 '633a31ca2eb87ce5b31b4f963bdfd1d4157282ad'
end

class ScalaCompletion < Formula
  homepage 'http://www.scala-lang.org/'
  url 'https://raw.github.com/scala/scala-dist/27bc0c25145a83691e3678c7dda602e765e13413/completion.d/2.9.1/scala'
  version '2.9.3'
  sha1 'e2fd99fe31a9fb687a2deaf049265c605692c997'
end

class Scala < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/files/archive/scala-2.9.3.tgz'
  sha1 '01bf9e2c854e2385b2bcef319840415867a00388'

  option 'with-docs', 'Also install library documentation'

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir['doc/*']
    man1.install Dir['man/man1/*']
    libexec.install Dir['*']
    bin.install_symlink Dir["#{libexec}/bin/*"]
    ScalaCompletion.new.brew { (prefix/'etc/bash_completion.d').install 'scala' }
    ScalaDocs.new.brew { doc.install Dir['*'] } if build.include? 'with-docs'
  end
end
