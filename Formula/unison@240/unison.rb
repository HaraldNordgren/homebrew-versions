class Unison < Formula
  version "240"
  homepage "http://www.cis.upenn.edu/~bcpierce/unison/"
  url "http://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-2.40.128/unison-2.40.128.tar.gz"
  sha256 "5a1ea828786b9602f2a42c2167c9e7643aba2c1e20066be7ce46de4779a5ca54"

  depends_on "objective-caml" => :build

  def install
    ENV.j1
    ENV.delete "CFLAGS" # ocamlopt reads CFLAGS but doesn't understand common options
    ENV.delete "NAME" # https://github.com/Homebrew/homebrew/issues/28642
    system "make", "./mkProjectInfo"
    system "make", "UISTYLE=text"
    bin.install "unison"
  end

  test do
    system bin/"unison", "-version"
  end
end
