class Libmongoclient < Formula
  version "legacy"
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.6.tar.gz"
  sha256 "fcdaade5ec8b32d66021a18ae2f2580f86d26a13a9bf57002e8c174a51637e9c"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    sha256 "7914c62076e4d4b461ed82f0c44208b8cc22c84e33666915ea6647d13edbd995" => :el_capitan
    sha256 "94c5aa46b91a696521aa9f941fd3e820559ee388b96aa97d5a4edc77163e88f2" => :yosemite
    sha256 "0210ee728a5c684368f4ac2f3a1e7dade663995eb464f758c59f0a54bfa69bec" => :mavericks
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
