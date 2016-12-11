class Node < Formula
  version "04"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/node-v0.4.12.tar.gz"
  sha1 "1c6e34b90ad6b989658ee85e0d0cb16797b16460"
  revision 1

  option "with-debug", "Build with debugger hooks"

  deprecated_option "enable-debug" => "with-debug"

  depends_on "openssl"
  depends_on MaximumMacOSRequirement => :mountain_lion

  fails_with :llvm do
    build 2326
  end

  # Fixes the build on 10.8, but 10.9 onwards is dead.
  # https://github.com/Homebrew/homebrew-versions/pull/665
  env :std

  def install
    inreplace "wscript" do |s|
      s.gsub! "/usr/local", HOMEBREW_PREFIX
      s.gsub! "/opt/local/lib", "/usr/lib"
    end

    args = ["--prefix=#{prefix}"]
    args << "--debug" if build.with? "debug"
    args << "--openssl-includes=#{Formula["openssl"].include}"
    args << "--openssl-libpath=#{Formula["openssl"].lib}"

    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    For node to pick up installed libraries, add this to your profile:
      export NODE_PATH=#{HOMEBREW_PREFIX}/lib/node_modules
    EOS
  end
end
