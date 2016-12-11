require 'formula'

class Gcc < Formula
  version "48"
  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        'x86_64'
      else
        'i686'
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        'powerpc64'
      else
        'powerpc'
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  homepage 'http://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  sha1 '810fb70bd721e1d9f446b6503afe0a9088b62986'

  head 'svn://gcc.gnu.org/svn/gcc/branches/gcc-4_8-branch'

  option 'enable-fortran', 'Build the gfortran compiler'
  option 'enable-java', 'Build the gcj compiler'
  option 'enable-all-languages', 'Enable all compilers and languages, except Ada'
  option 'enable-nls', 'Build with native language support (localization)'
  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'enable-multilib', 'Build with multilib support'

  depends_on 'gmp@4'
  depends_on 'libmpc@08'
  depends_on 'mpfr@2'
  depends_on 'cloog@018'
  depends_on 'isl@011'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  # The as that comes with Tiger isn't capable of dealing with the
  # PPC asm that comes in libitm
  depends_on 'cctools' => :build if MacOS.version < :leopard

  fails_with :gcc_4_0

  # GCC 4.8.1 incorrectly determines that _Unwind_GetIPInfo is available on
  # Tiger, resulting in a failed build
  # Reported upstream: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58710
  def patches; DATA; end if MacOS.version < :leopard

  def install
    # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
    cxxstdlib_check :skip

    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete 'LD'

    if MacOS.version < :leopard
      as = Formula.factory('cctools').bin/'as'
      ENV['AS'] = as
      ENV['AS_FOR_TARGET'] = as
    end

    if build.include? 'enable-all-languages'
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap. GCC 4.6.0 add go as a language option, but it is
      # currently only compilable on Linux.
      languages = %w[c c++ fortran java objc obj-c++]
    else
      # C, C++, ObjC compilers are always built
      languages = %w[c c++ objc obj-c++]

      languages << 'fortran' if build.include? 'enable-fortran'
      languages << 'java' if build.include? 'enable-java'
    end

    version_suffix = version.to_s.slice(/\d\.\d/)

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(',')}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--with-gmp=#{Formula.factory('gmp4').opt_prefix}",
      "--with-mpfr=#{Formula.factory('mpfr2').opt_prefix}",
      "--with-mpc=#{Formula.factory('libmpc08').opt_prefix}",
      "--with-cloog=#{Formula.factory('cloog018').opt_prefix}",
      "--with-isl=#{Formula.factory('isl011').opt_prefix}",
      "--with-system-zlib",
      # This ensures lib, libexec, include are sandboxed so that they
      # don't wander around telling little children there is no Santa
      # Claus.
      "--enable-version-specific-runtime-libs",
      "--enable-libstdcxx-time=yes",
      "--enable-stage1-checking",
      "--enable-checking=release",
      "--enable-lto",
      # A no-op unless --HEAD is built because in head warnings will
      # raise errors. But still a good idea to include.
      "--disable-werror"
    ]

    # "Building GCC with plugin support requires a host that supports
    # -fPIC, -shared, -ldl and -rdynamic."
    args << "--enable-plugin" if MacOS.version > :tiger

    # Otherwise make fails during comparison at stage 3
    # See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=45248
    args << '--with-dwarf2' if MacOS.version < :leopard

    args << '--disable-nls' unless build.include? 'enable-nls'

    if build.include? 'enable-java' or build.include? 'enable-all-languages'
      args << "--with-ecj-jar=#{Formula.factory('ecj').opt_prefix}/share/java/ecj.jar"
    end

    if build.include? 'enable-multilib'
      args << '--enable-multilib'
    else
      args << '--disable-multilib'
    end

    mkdir 'build' do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # 'native-system-header's will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system '../configure', *args

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system 'make profiledbootstrap'
      else
        system 'make bootstrap'
      end

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu and autogen formulae must be installed in order to do this.

      system 'make install'
    end

    # Handle conflicts between GCC formulae

    # Since GCC 4.8 libffi stuff are no longer shipped.

    # Rename libiberty.a.
    Dir.glob(prefix/"**/libiberty.*") { |file| add_suffix file, version_suffix }

    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }

    # Rename java properties
    if build.include? 'enable-java' or build.include? 'enable-all-languages'
      config_files = [
        "#{lib}/logging.properties",
        "#{lib}/security/classpath.security",
        "#{lib}/i386/logging.properties",
        "#{lib}/i386/security/classpath.security"
      ]

      config_files.each do |file|
        add_suffix file, version_suffix if File.exists? file
      end
    end
  end

  def add_suffix file, suffix
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end
end

__END__
diff --git a/libbacktrace/backtrace.c b/libbacktrace/backtrace.c
index 428f53a..a165197 100644
--- a/libbacktrace/backtrace.c
+++ b/libbacktrace/backtrace.c
@@ -35,6 +35,14 @@ POSSIBILITY OF SUCH DAMAGE.  */
 #include "unwind.h"
 #include "backtrace.h"
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 /* The main backtrace_full routine.  */
 
 /* Data passed through _Unwind_Backtrace.  */
diff --git a/libbacktrace/simple.c b/libbacktrace/simple.c
index b03f039..9f3a945 100644
--- a/libbacktrace/simple.c
+++ b/libbacktrace/simple.c
@@ -35,6 +35,14 @@ POSSIBILITY OF SUCH DAMAGE.  */
 #include "unwind.h"
 #include "backtrace.h"
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 /* The simple_backtrace routine.  */
 
 /* Data passed through _Unwind_Backtrace.  */
diff --git a/libgcc/unwind-c.c b/libgcc/unwind-c.c
index b937d9d..1121dce 100644
--- a/libgcc/unwind-c.c
+++ b/libgcc/unwind-c.c
@@ -30,6 +30,14 @@ see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 #define NO_SIZE_OF_ENCODED_VALUE
 #include "unwind-pe.h"
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 typedef struct
 {
   _Unwind_Ptr Start;
diff --git a/libgfortran/runtime/backtrace.c b/libgfortran/runtime/backtrace.c
index 3b58118..9a00066 100644
--- a/libgfortran/runtime/backtrace.c
+++ b/libgfortran/runtime/backtrace.c
@@ -40,6 +40,14 @@ see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 #include "unwind.h"
 
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 /* Macros for common sets of capabilities: can we fork and exec, and
    can we use pipes to communicate with the subprocess.  */
 #define CAN_FORK (defined(HAVE_FORK) && defined(HAVE_EXECVE) \
diff --git a/libgo/runtime/go-unwind.c b/libgo/runtime/go-unwind.c
index c669a3c..9e848db 100644
--- a/libgo/runtime/go-unwind.c
+++ b/libgo/runtime/go-unwind.c
@@ -18,6 +18,14 @@
 #include "go-defer.h"
 #include "go-panic.h"
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 /* The code for a Go exception.  */
 
 #ifdef __ARM_EABI_UNWINDER__
diff --git a/libobjc/exception.c b/libobjc/exception.c
index 4b05611..8ff70f9 100644
--- a/libobjc/exception.c
+++ b/libobjc/exception.c
@@ -31,6 +31,14 @@ see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 #include "unwind-pe.h"
 #include <string.h> /* For memcpy */
 
+#ifdef __APPLE__
+/* On MacOS X, versions older than 10.5 don't export _Unwind_GetIPInfo.  */
+#undef HAVE_GETIPINFO
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#define HAVE_GETIPINFO 1
+#endif
+#endif
+
 /* 'is_kind_of_exception_matcher' is our default exception matcher -
    it determines if the object 'exception' is of class 'catch_class',
    or of a subclass.  */
