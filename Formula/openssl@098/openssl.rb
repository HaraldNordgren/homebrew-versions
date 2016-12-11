require 'formula'

class Openssl < Formula
  version "098"
  homepage 'http://www.openssl.org'
  url 'http://www.openssl.org/source/openssl-0.9.8za.tar.gz'
  sha1 'aadca1eb1a103a5536b24e1ed7e45051e2939731'

  keg_only :provided_by_osx

  def install
    args = %W[./Configure
               --prefix=#{prefix}
               --openssldir=#{etc}/openssl
               zlib-dynamic
               shared
             ]

    if MacOS.prefer_64_bit?
      args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
    else
      args << "darwin-i386-cc"
    end

    system "perl", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def caveats; <<-EOS.undent
    Note that the libraries built tend to be 32-bit only, even on Snow Leopard.
    EOS
  end
end
