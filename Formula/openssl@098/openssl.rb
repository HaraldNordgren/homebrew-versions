class Openssl < Formula
  version "098"
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8ze.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/OpenSSL/openssl-0.9.8ze.tar.gz"
  sha256 "ee3da602826e975b47e4d7af8a27be8258c160876194898c58881eab814b55b8"

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
