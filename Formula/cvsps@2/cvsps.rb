class Cvsps < Formula
  version "2"
  homepage "http://www.catb.org/~esr/cvsps/"
  url "http://www.cobite.com/cvsps/cvsps-2.1.tar.gz"
  sha256 "91d3198b33463861a581686d5fcf99a5c484e7c4d819384c04fda9cafec1075a"

  def install
    system "make", "all"
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    # an assert_match on shell_output hangs indefinitely, as does normal syntax usage.
    assert_match /special hack for parsing the/, pipe_output("#{bin}/cvsps -h 2>&1")
  end
end
