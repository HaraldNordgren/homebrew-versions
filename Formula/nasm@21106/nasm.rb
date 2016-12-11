class Nasm < Formula
  version "21106"
  desc "Nasm 2.11.06 Formula"
  homepage "http://www.nasm.us/"
  url "http://www.nasm.us/pub/nasm/releasebuilds/2.11.06/nasm-2.11.06.tar.xz"
  sha256 "90f60d95a15b8a54bf34d87b9be53da89ee3d6213ea739fb2305846f4585868a"

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install", "install_rdf"
  end

  test do
    (testpath/"foo.s").write <<-EOS
      mov eax, 0
      mov ebx, 0
      int 0x80
    EOS

    system "#{bin}/nasm", "foo.s"
    code = File.open("foo", "rb") { |f| f.read.unpack("C*") }
    expected = [0x66, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x66, 0xbb,
                0x00, 0x00, 0x00, 0x00, 0xcd, 0x80]
    assert_equal expected, code
  end
end
