class Jpeg < Formula
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v9.tar.gz"
  sha256 "c4e29e9375aaf60b4b79db87a58b063fb5b84f923bee97a88280b3d159e7e535"
  version "9.0"

  option :universal

  # https://trac.macports.org/ticket/37984
  patch :DATA

  def install
    ENV.universal_binary if build.universal?

    # Builds static and shared libraries.
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end

__END__
--- a/jmorecfg.h
+++ b/jmorecfg.h
@@ -252,17 +252,16 @@ typedef void noreturn_t;
  * Defining HAVE_BOOLEAN before including jpeglib.h should make it work.
  */
 
-#ifdef HAVE_BOOLEAN
+#ifndef HAVE_BOOLEAN
+typedef int boolean;
+#endif
+
 #ifndef FALSE			/* in case these macros already exist */
 #define FALSE	0		/* values of boolean */
 #endif
 #ifndef TRUE
 #define TRUE	1
 #endif
-#else
-typedef enum { FALSE = 0, TRUE = 1 } boolean;
-#endif
-
 
 /*
  * The remaining options affect code selection within the JPEG library,

