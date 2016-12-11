class Node < Formula
  version "06"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v0.6.21/node-v0.6.21.tar.gz"
  sha256 "22265fd07e09c22f1d058156d548e7398c9740210f534e2f848eeab5b9772117"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "81590f60b9165f186e8ebbff5453127fb1f4861b" => :yosemite
    sha1 "84e9e2e1e6f74e4b956ea334c43c2a73ffc7b97b" => :mavericks
    sha1 "4949d439daa73b284348aa63ed43266dd0d4a725" => :mountain_lion
  end

  option "with-debug", "Build with debugger hooks"

  deprecated_option "enable-debug" => "with-debug"

  depends_on "openssl"

  fails_with :llvm do
    build 2326
  end

  env :std

  def install
    inreplace "wscript" do |s|
      s.gsub! "/usr/local", HOMEBREW_PREFIX
      s.gsub! "/opt/local/lib", "/usr/lib"
    end

    args = ["--prefix=#{prefix}", "--without-npm"]
    args << "--debug" if build.with? "debug"
    args << "--openssl-includes=#{Formula["openssl"].include}"
    args << "--openssl-libpath=#{Formula["openssl"].lib}"

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
      Homebrew has NOT installed npm.

      After installing, add the following path to your NODE_PATH environment
      variable to have npm libraries picked up:
        #{HOMEBREW_PREFIX}/lib/node_modules
    EOS
  end
end
