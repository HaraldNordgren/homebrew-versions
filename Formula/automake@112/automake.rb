class Automake < Formula
  version "112"
  homepage "https://www.gnu.org/software/automake/"
  url "http://ftpmirror.gnu.org/automake/automake-1.12.6.tar.gz"
  mirror "https://ftp.gnu.org/gnu/automake/automake-1.12.6.tar.gz"
  sha256 "0cbe570db487908e70af7119da85ba04f7e28656b26f717df0265ae08defd9ef"

  depends_on "autoconf" => :run

  keg_only :provided_until_xcode43

  def install
    system "./configure", "--prefix=#{prefix}", "--program-suffix=112"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/mxcl/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<-EOS.undent
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    system bin/"automake112", "--version"
  end
end
