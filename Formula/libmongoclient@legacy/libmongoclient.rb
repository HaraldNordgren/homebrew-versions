class Libmongoclient < Formula
  version "legacy"
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.3.tar.gz"
  sha256 "9d1da2d5bc258ceb5f6a58cd5a8893aabdec768e7771ede270a36fbf4b4491d2"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "347dacd430b05815ea1270eb6355f54134e5171b15c140da475235f045060c13" => :yosemite
    sha256 "06d04228c6bd53c7a2634228d4c8b3b19a4d765a9a10c20554b6bb1b019fe4d4" => :mavericks
    sha256 "3a73c4e2a01e30f064c600f6bfcf723e47516cb2dba2debe566dbe4c56bab730" => :mountain_lion
  end

  option :cxx11

  depends_on "scons" => :build

  if build.cxx11?
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  def install
    ENV.cxx11 if build.cxx11?

    boost = Formula["boost"].opt_prefix

    args = [
      "--prefix=#{prefix}",
      "-j#{ENV.make_jobs}",
      "--cc=#{ENV.cc}",
      "--cxx=#{ENV.cxx}",
      "--extrapath=#{boost}",
      "--sharedclient",
      # --osx-version-min is required to override --osx-version-min=10.6 added
      # by SConstruct which causes "invalid deployment target for -stdlib=libc++"
      # when using libc++
      "--osx-version-min=#{MacOS.version}",
      "install",
    ]

    args << "--libc++" if MacOS.version >= :mavericks

    scons *args
  end
end
