require 'formula'

class Ruby < Formula
  version "182"
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.2.tar.gz'
  mirror 'http://mirrorservice.org/sites/ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.2.tar.bz2'
  sha256 '34cf95791323c96dc92c672c16daaef69f00a0ba69e1c43bab893ae38b7eeb3e'

  keg_only :provided_by_osx

  option :universal
  option 'with-suffix', 'Suffix commands with "20"'
  option 'with-doc', 'Install documentation'
  option 'with-tcltk', 'Install with Tcl/Tk support'

  depends_on 'pkg-config' => :build
  depends_on 'readline' => :recommended
  depends_on 'gdbm' => :optional
  depends_on 'libyaml'
  depends_on 'openssl' if MacOS.version >= :mountain_lion
  depends_on :x11 if build.with? 'tcltk'

  fails_with :llvm do
    build 2326
  end

  # Fixes up a few incompatibilities with modern OpenSSL
  # ossl_x509stctx_set_time() definition taken from 1.8.6
  def patches; DATA; end

  def install
    # Otherwise it will try to link against some other libruby,
    # instead of the one it just built
    ENV.prepend 'LDFLAGS', '-L.'

    system "autoconf" if build.head?

    args = %W[--prefix=#{prefix} --mandir=#{man} --enable-shared]
    args << "--program-suffix=20" if build.with? "suffix"
    args << "--with-arch=#{Hardware::CPU.universal_archs.join(',')}" if build.universal?
    args << "--with-out-ext=tk" unless build.with? "tcltk"
    args << "--disable-install-doc" unless build.with? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    # OpenSSL is deprecated on OS X 10.8 and Ruby can't find the outdated
    # version (0.9.8r 8 Feb 2011) that ships with the system.
    # See discussion https://github.com/sstephenson/ruby-build/issues/304
    # and https://github.com/mxcl/homebrew/pull/18054
    if MacOS.version >= :mountain_lion
      args << "--with-openssl-dir=#{Formula.factory('openssl').opt_prefix}"
    end

    # Put gem, site and vendor folders in the HOMEBREW_PREFIX
    ruby_lib = HOMEBREW_PREFIX/"lib/ruby"
    (ruby_lib/'site_ruby').mkpath
    (ruby_lib/'vendor_ruby').mkpath
    (ruby_lib/'gems').mkpath

    (lib/'ruby').install_symlink ruby_lib/'site_ruby',
                                 ruby_lib/'vendor_ruby',
                                 ruby_lib/'gems'

    system "./configure", *args
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end
end

__END__
diff --git a/ext/openssl/openssl_missing.h b/ext/openssl/openssl_missing.h
index caf1bfe..cde9c6f 100644
--- a/ext/openssl/openssl_missing.h
+++ b/ext/openssl/openssl_missing.h
@@ -112,8 +112,8 @@ int X509_CRL_add0_revoked(X509_CRL *crl, X509_REVOKED *rev);
 int BN_mod_sqr(BIGNUM *r, const BIGNUM *a, const BIGNUM *m, BN_CTX *ctx);
 int BN_mod_add(BIGNUM *r, const BIGNUM *a, const BIGNUM *b, const BIGNUM *m, BN_CTX *ctx);
 int BN_mod_sub(BIGNUM *r, const BIGNUM *a, const BIGNUM *b, const BIGNUM *m, BN_CTX *ctx);
-int BN_rand_range(BIGNUM *r, BIGNUM *range);
-int BN_pseudo_rand_range(BIGNUM *r, BIGNUM *range);
+int BN_rand_range(BIGNUM *r, const BIGNUM *range);
+int BN_pseudo_rand_range(BIGNUM *r, const BIGNUM *range);
 char *CONF_get1_default_config_file(void);
 int PEM_def_callback(char *buf, int num, int w, void *key);
 
diff --git a/ext/openssl/ossl_x509store.c b/ext/openssl/ossl_x509store.c
index 138e710..79fa341 100644
--- a/ext/openssl/ossl_x509store.c
+++ b/ext/openssl/ossl_x509store.c
@@ -535,17 +535,11 @@ static VALUE
 ossl_x509stctx_set_time(VALUE self, VALUE time)
 {
     X509_STORE_CTX *store;
+    long t;
 
-    if(NIL_P(time)) {
-	GetX509StCtx(self, store);
-	store->flags &= ~X509_V_FLAG_USE_CHECK_TIME;
-    }
-    else {
-	long t = NUM2LONG(rb_Integer(time));
-
-	GetX509StCtx(self, store);
-	X509_STORE_CTX_set_time(store, 0, t);
-    }
+    t = NUM2LONG(rb_Integer(time));
+    GetX509StCtx(self, store);
+    X509_STORE_CTX_set_time(store, 0, t);
 
     return time;
 }

