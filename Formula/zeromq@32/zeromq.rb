class Zeromq < Formula
  version "32"
  homepage "http://www.zeromq.org/"
  url "http://download.zeromq.org/zeromq-3.2.5.tar.gz"
  sha256 "09653e56a466683edb2f87ee025c4de55b8740df69481b9d7da98748f0c92124"

  option :universal
  option "with-pgm", "Build with PGM extension"

  depends_on "pkg-config" => :build
  depends_on "libpgm" if build.with? "pgm"

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    if build.with? "pgm"
      # Use HB libpgm-5.2 because their internal 5.1 is b0rked.
      ENV["OpenPGM_CFLAGS"] = `pkg-config --cflags openpgm-5.2`.chomp
      ENV["OpenPGM_LIBS"] = `pkg-config --libs openpgm-5.2`.chomp
      args << "--with-system-pgm"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    To install the zmq gem on 10.6 with the system Ruby on a 64-bit machine,
    you may need to do:

        ARCHFLAGS="-arch x86_64" gem install zmq -- --with-zmq-dir=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <zmq.h>
      #include <assert.h>

      int main (void)
      {
          void *context = zmq_ctx_new ();
          void *responder = zmq_socket (context, ZMQ_REP);
          int rc = zmq_bind (responder, "tcp://*:5555");
          assert (rc == 0);

          return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lzmq",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
