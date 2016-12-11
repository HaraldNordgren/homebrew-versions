class Libmongoclient < Formula
  version "legacy"
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.6.tar.gz"
  sha256 "fcdaade5ec8b32d66021a18ae2f2580f86d26a13a9bf57002e8c174a51637e9c"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    sha256 "fb2886f1ecad46bebeb2ac3ac2666f525e3e54feeaae01b8d05862529b04a5e0" => :yosemite
    sha256 "cd74b412de1018cf908e4c177b1db0be870ba015ee34f5507f966e6f57d4328b" => :mavericks
    sha256 "81ffc4dfe7fc6c6811897f282ee5859e394bd1ef0ea6e30b8e37885aa8b4d3ae" => :mountain_lion
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

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <mongo/client/dbclient.h>

      int main() {
          mongo::DBClientConnection c;
          mongo::client::initialize();
          return 0;
      }
    EOS
    system ENV.cxx, "-L#{lib}", "-lmongoclient",
           "-L#{Formula["boost"].opt_lib}", "-lboost_system",
           testpath/"test.cpp", "-o", testpath/"test"
    system "./test"
  end
end
