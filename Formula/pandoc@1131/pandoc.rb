require "language/haskell"

class Pandoc < Formula
  version "1131"
  include Language::Haskell::Cabal

  homepage "http://johnmacfarlane.net/pandoc/"
  url "https://hackage.haskell.org/package/pandoc-1.13.1/pandoc-1.13.1.tar.gz"
  sha256 "7b1bb9b7d66edfbac33796a3f5d3218c2add786b95ea9dfbd497dc0e8ed27e6f"

  keg_only "Conflicts with pandoc in main repository."

  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "gmp"

  fails_with(:clang) { build 425 } # clang segfaults on Lion

  def install
    cabal_sandbox do
      cabal_install "--only-dependencies"
      cabal_install "--prefix=#{prefix}"
    end
    cabal_clean_lib
  end

  test do
    system bin/"pandoc", "-o", "output.html", prefix/"README"
    assert (Pathname.pwd/"output.html").read.include? '<h1 id="synopsis">Synopsis</h1>'
  end
end
