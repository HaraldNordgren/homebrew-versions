require 'formula'

class Antlr < Formula
  version "2"
  homepage 'http://www.antlr2.org'
  url 'http://www.antlr2.org/download/antlr-2.7.7.tar.gz'
  md5 '01cc9a2a454dd33dcd8c856ec89af090'

  def install
    # C Sharp is explicitly disabled because the antlr configure script will
    # confuse the Chicken Scheme compiler, csc, for a C sharp compiler.
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-csharp
    ]

    system "./configure", *args
    system "make"

    libexec.install "antlr.jar"
    include.install "lib/cpp/antlr"
    lib.install "lib/cpp/src/libantlr.a"

    (bin+"antlr2").write <<-EOS.undent
    #!/bin/sh
    java -classpath #{libexec}/antlr.jar antlr.Tool "$@"
    EOS
  end
end
