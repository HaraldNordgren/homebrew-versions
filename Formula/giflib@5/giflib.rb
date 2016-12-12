class Giflib < Formula
  version "5"
  desc "Library and utilities for processing GIFs"
  homepage "http://giflib.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/giflib/giflib-5.1.1.tar.bz2"
  sha256 "391014aceb21c8b489dc7b0d0b6a917c4e32cc014ce2426d47ca376d02fe2ffc"

  bottle do
    cellar :any
    sha256 "6ed13aadad66c923b480c7c2298fd7d1857dc58c260f972fb9e28aa45e08869d" => :yosemite
    sha256 "04858ea96297f92679f93c92a37e6081b059ac0bdfce34c9eb99a4c823d746d5" => :mavericks
    sha256 "d03bd0eeedfc5036fdb396478d63396b2d032dec2fd38c6ff4d4b0d636f4f5d8" => :mountain_lion
  end

  keg_only "Conflicts with giflib in main repository."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    assert_match /Screen Size - Width = 1, Height = 1/, shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
  end
end
