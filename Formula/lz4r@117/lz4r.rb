class Lz4r < Formula
  desc "Lossless compression algorithm"
  homepage "http://www.lz4.info/"
  url "https://github.com/Cyan4973/lz4/archive/r117.tar.gz"
  version "r117"
  sha256 "c4ca70bf6711021d5ae64e79469a619a4e5899a4c7e07e665f3eb3a517cd029d"

  conflicts_with "lz4", :because => "Differing versions of the same formulae"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    input = "testing compression and decompression"
    input_file = testpath/"in"
    input_file.write input
    output_file = testpath/"out"
    system "sh", "-c", "cat #{input_file} | #{bin}/lz4 | #{bin}/lz4 -d > #{output_file}"
    assert_equal output_file.read, input
  end
end
