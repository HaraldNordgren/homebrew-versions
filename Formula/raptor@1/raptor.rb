class Raptor < Formula
  version "1"
  homepage "http://librdf.org/raptor/"
  url "http://download.librdf.org/source/raptor-1.4.21.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/r/raptor/raptor_1.4.21.orig.tar.gz"
  sha256 "db3172d6f3c432623ed87d7d609161973d2f7098e3d2233d0702fbcc22cfd8ca"

  # Modern cURL versions don't have a types header. Compile fails
  # as it looks for it in make. Patched the header out here, borrowing
  # a chunk of the fix from harbour.rb in Homebrew/homebrew.
  patch :DATA

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"raptor-config", "--libs", "--cflags", "--options"
  end
end

__END__
diff --git a/src/raptor_internal.h b/src/raptor_internal.h
index f7944db..1a55047 100644
--- a/src/raptor_internal.h
+++ b/src/raptor_internal.h
@@ -852,9 +852,13 @@ int raptor_utf8_is_nfc(const unsigned char *input, size_t length);

 #ifdef RAPTOR_WWW_LIBCURL
 #include <curl/curl.h>
-#include <curl/types.h>
+#if LIBCURL_VERSION_NUM < 0x070A03
 #include <curl/easy.h>
 #endif
+#if LIBCURL_VERSION_NUM < 0x070C00
+#include <curl/types.h>
+#endif
+#endif

 /* Size of buffer used in various raptor_www places for I/O  */
 #ifndef RAPTOR_WWW_BUFFER_SIZE
