require 'formula'

class LlvmGcc < Formula
  homepage 'http://llvm.org/docs/CommandGuide/html/llvmgcc.html'
  url 'http://llvm.org/releases/2.8/llvm-gcc-4.2-2.8-x86_64-apple-darwin10.tar.gz'
  version '2.8'
  sha1 'f387a5f774c36cd96ab378f919c5861351110941'

  skip_clean :all # This is a binary install
  keg_only :provided_by_osx

  def install
    prefix.install Dir['*']
  end
end
