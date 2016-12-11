require "formula"

class Openssl < Formula
  version "098"
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8zd.tar.gz"
  sha256 "59266dcfb0be0fbe6181edead044ac3edaf83bc58991f264dcf532b01d531ee3"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    sha1 "65c01f5377ddcb07b4addae5dc6239840bb2fe4b" => :yosemite
    sha1 "bfd9afdd4e9f4262341b53425e08727d44738aa2" => :mavericks
    sha1 "a0c17c20c2ac25bd44dccd90eb44b20033142dd9" => :mountain_lion
  end

  keg_only :provided_by_osx

  def install
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{etc}/openssl
      no-ssl2
      zlib-dynamic
      shared
    ]

    if MacOS.prefer_64_bit?
      args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
    else
      args << "darwin-i386-cc"
    end

    system "perl", "./Configure", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end
end
