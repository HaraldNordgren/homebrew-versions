class Libuv < Formula
  version "0"
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v0.10.36.tar.gz"
  sha1 "0991836d1dbf9419f448bc3459559181505e29c5"
  head "https://github.com/libuv/libuv.git", :branch => "v0.10"

  conflicts_with "libuv"

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "make", "libuv.dylib"
    prefix.install "include"
    lib.install "libuv.dylib"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <uv.h>

      int main()
      {
        uv_loop_t* loop = uv_loop_new();
        uv_loop_delete(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-luv", "-o", "test"
    system "./test"
  end
end
