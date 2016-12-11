class Libuv < Formula
  version "0"
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v0.10.31.tar.gz"
  sha1 "9ab8ecb10f90ce13404ff58ff85cb774472e2cb9"
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
