class Camlp5 < Formula
  version "606"
  homepage "http://pauillac.inria.fr/~ddr/camlp5/"
  url "http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.06.tgz"
  sha256 "763f89ee6cde4ca063a50708c3fe252d55ea9f8037e3ae9801690411ea6180c5"

  option "with-strict", "Compile in strict mode"

  depends_on "objective-caml@312"

  def install
    if build.with? "strict"
      strictness = "-strict"
    else
      strictness = "-transitional"
    end

    system "./configure", "-prefix", prefix, "-mandir", man, strictness
    # this build fails if jobs are parallelized
    ENV.deparallelize
    system "make", "world.opt"
    system "make", "install"
  end

  test do
    system bin/"camlp5", "-v"
  end
end
