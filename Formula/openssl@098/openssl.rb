class Openssl < Formula
  version "098"
  desc "SSL/TLS cryptography library"
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8zh.tar.gz"
  sha256 "f1d9f3ed1b85a82ecf80d0e2d389e1fda3fca9a4dba0bf07adbf231e1a5e2fd6"

  bottle do
    sha256 "625b28afafa9e0cfb69c1d1ebf19f9f4f93ae2b92c54727ead0833b15a677465" => :el_capitan
    sha256 "51777b4e0896b69c3c336fbc18234ccf0f0b0e4b423dae7bcba45a3ca742950a" => :yosemite
    sha256 "23142a869f86d9334476b54136eac3dbaaac3db0120554afe88e67c5d91f31e7" => :mavericks
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

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", "dgst", "-sha1", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
