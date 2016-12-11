class JsonC < Formula
  version "010"
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://github.com/downloads/json-c/json-c/json-c-0.10.tar.gz"
  sha256 "274fc9d47c1911fad9caab4db117e4be5d6b68c4547eab0c508d79c4768e170c"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"

    # The Makefile forgets to install this header.
    (include/"json").install "json_object_iterator.h"
  end
end
