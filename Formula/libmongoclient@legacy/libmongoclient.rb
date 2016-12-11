class Libmongoclient < Formula
  version "legacy"
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.5.tar.gz"
  sha256 "7e83927285f294ef5b98c4bad022c3dc8e0af5628595abfb676f3d027a8bbebe"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    sha256 "511fd5db4ff3cde759692f6b0ea6083f6383d47d2519a1fce076f5232ab9b89b" => :yosemite
    sha256 "c0b1bac49b6c5aae66253df3e2b58a63d46797d4ed059d717a96a2298bafed9f" => :mavericks
    sha256 "e6b1b93b2e32731a1f0d739143ad61590dde9fe8640d4b2b3c348cb2affcb1c2" => :mountain_lion
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
