class Gawk < Formula
  version "3"
  homepage "https://www.gnu.org/software/gawk/"
  url "http://ftpmirror.gnu.org/gawk/gawk-3.1.8.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gawk/gawk-3.1.8.tar.bz2"
  sha256 "5dbc7b2c4c328711337c2aacd09a122c7313122262e3ff034590f014067412b4"

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/gawk '{ gsub(/Macro/, \"Home\"); print }' -", "Macrobrew")
    assert_equal 'Homebrew', output.strip
  end
end
