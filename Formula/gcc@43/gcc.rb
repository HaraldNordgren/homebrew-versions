require 'formula'

class Gcc < Formula
  version "43"
  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        'x86_64'
      else
        'i686'
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        'ppc64'
      else
        'ppc'
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  homepage 'http://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2'
  sha1 'df276018e3c664c7e6aa7ca88a180515eea61663'

  option 'enable-cxx', 'Build the g++ compiler'
  option 'enable-fortran', 'Build the gfortran compiler'
  option 'enable-java', 'Buld the gcj compiler'
  option 'enable-objc', 'Enable Objective-C language support'
  option 'enable-objcxx', 'Enable Objective-C++ language support'
  option 'enable-all-languages', 'Enable all compilers and languages, except Ada'
  option 'enable-nls', 'Build with native language support (localization)'
  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'enable-multilib', 'Build with multilib support'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  # Patches adapted from macports:
  # http://trac.macports.org/browser/trunk/dports/lang/gcc43/files
  def patches; DATA; end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete 'LD'

    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'

    if build.include? 'enable-all-languages'
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap.
      languages = %w[c c++ fortran java objc obj-c++]
    else
      # The C compiler is always built, but additional defaults can be added
      # here.
      languages = %w[c]

      languages << 'c++' if build.include? 'enable-cxx'
      languages << 'fortran' if build.include? 'enable-fortran'
      languages << 'java' if build.include? 'enable-java'
      languages << 'objc' if build.include? 'enable-objc'
      languages << 'obj-c++' if build.include? 'enable-objcxx'
    end

    # Sandbox the GCC lib, libexec and include directories so they don't wander
    # around telling small children there is no Santa Claus. This results in a
    # partially keg-only brew following suggestions outlined in the "How to
    # install multiple versions of GCC" section of the GCC FAQ:
    #     http://gcc.gnu.org/faq.html#multiple
    gcc_prefix = prefix + 'gcc'

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      # Sandbox everything...
      "--prefix=#{gcc_prefix}",
      # ...except the stuff in share...
      "--datadir=#{share}",
      "--mandir=#{man}",
      # ...and the binaries...
      "--bindir=#{bin}",
      # ...which are tagged with a suffix to distinguish them.
      "--enable-languages=#{languages.join(',')}",
      "--program-suffix=-#{version.to_s.slice(/\d\.\d/)}",
      "--with-gmp=#{gmp.opt_prefix}",
      "--with-mpfr=#{mpfr.opt_prefix}",
      "--with-system-zlib",
      "--enable-stage1-checking"
    ]

    args << '--disable-nls' unless build.include? 'enable-nls'

    if build.include? 'enable-java' or build.include? 'enable-all-languages'
      ecj = Formula.factory 'ecj'
      args << "--with-ecj-jar=#{ecj.opt_prefix}/share/java/ecj.jar"
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

      # Flags for Clang compatibility
      make_flags = 'BOOT_CFLAGS="$BOOT_CFLAGS -D_FORTIFY_SOURCE=0" STAGE1_CFLAGS="$STAGE1_CFLAGS -std=gnu89 -D_FORTIFY_SOURCE=0 -fkeep-inline-functions"'

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system "make #{make_flags} profiledbootstrap"
      else
        system "make #{make_flags} bootstrap"
      end

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu formula must be installed in order to do this.

      system 'make install'

      # Remove conflicting manpages in man7
      man7.rmtree
    end
  end
end

__END__
--- gcc-4.3.6/gcc/config.gcc.orig	2009-10-18 12:07:26.000000000 -0400
+++ gcc-4.3.6/gcc/config.gcc	2009-10-18 12:07:46.000000000 -0400
@@ -417,7 +417,7 @@
 *-*-darwin*)
   tm_file="${tm_file} darwin.h"
   case ${target} in
-  *-*-darwin9*)
+  *-*-darwin9* | *-*-darwin1[0-9]*)
     tm_file="${tm_file} darwin9.h"
     ;;
   esac
--- gcc-4.3.6/configure.orig	2009-10-18 12:09:09.000000000 -0400
+++ gcc-4.3.6/configure	2009-10-18 12:10:07.000000000 -0400
@@ -2133,7 +2133,7 @@
   *-*-chorusos)
     noconfigdirs="$noconfigdirs target-newlib target-libgloss ${libgcj}"
     ;;
-  powerpc-*-darwin* | i[3456789]86-*-darwin* | x86_64-*-darwin9*)
+  powerpc-*-darwin* | i[3456789]86-*-darwin* | x86_64-*-darwin9* | x86_64-*-darwin1[0-9]*)
     noconfigdirs="$noconfigdirs bfd binutils ld gas opcodes gdb gprof"
     noconfigdirs="$noconfigdirs sim target-rda"
     ;;
--- gcc-4.3.6/configure.ac.orig	2009-10-18 12:12:07.000000000 -0400
+++ gcc-4.3.6/configure.ac	2009-10-18 12:15:37.000000000 -0400
@@ -410,7 +410,7 @@
   *-*-chorusos)
     noconfigdirs="$noconfigdirs target-newlib target-libgloss ${libgcj}"
     ;;
-  powerpc-*-darwin* | i[[3456789]]86-*-darwin* | x86_64-*-darwin9*)
+  powerpc-*-darwin* | i[[3456789]]86-*-darwin* | x86_64-*-darwin9* | x86_64-*-darwin1[[0-9]]*)
     noconfigdirs="$noconfigdirs bfd binutils ld gas opcodes gdb gprof"
     noconfigdirs="$noconfigdirs sim target-rda"
     ;;
--- gcc-4.3.6/libjava/configure.orig	2009-10-18 12:17:53.000000000 -0400
+++ gcc-4.3.6/libjava/configure	2009-10-18 12:19:04.000000000 -0400
@@ -27297,7 +27297,7 @@
  m68*-*-linux*)
     SIGNAL_HANDLER=include/dwarf2-signal.h
     ;;
- powerpc*-*-darwin* | i?86-*-darwin9* | x86_64-*-darwin9*)
+ powerpc*-*-darwin* | i?86-*-darwin9* | i?86-*-darwin1[0-9]* | x86_64-*-darwin9* | x86_64-*-darwin1[0-9]*)
     SIGNAL_HANDLER=include/darwin-signal.h
     ;;
  *)
--- gcc-4.3.6/libjava/configure.ac.orig	2009-10-18 12:19:42.000000000 -0400
+++ gcc-4.3.6/libjava/configure.ac	2009-10-18 12:20:18.000000000 -0400
@@ -1563,7 +1563,7 @@
  m68*-*-linux*)
     SIGNAL_HANDLER=include/dwarf2-signal.h
     ;;
- powerpc*-*-darwin* | i?86-*-darwin9* | x86_64-*-darwin9*)
+ powerpc*-*-darwin* | i?86-*-darwin9* | i?86-*-darwin1[[0-9]]* | x86_64-*-darwin9* | x86_64-*-darwin1[[0-9]]*)
     SIGNAL_HANDLER=include/darwin-signal.h
     ;;
  *)
--- gcc-4.3.6/libjava/configure.host.orig	2009-10-18 12:38:02.000000000 -0400
+++ gcc-4.3.6/libjava/configure.host	2009-10-18 12:38:28.000000000 -0400
@@ -295,11 +295,11 @@
 	slow_pthread_self=
 	can_unwind_signal=no
 	;;
-  i?86-*-darwin9*)
+  i?86-*-darwin9* | i?86-*-darwin1[0-9]*)
 	can_unwind_signal=yes
 	DIVIDESPEC=-f%{m32:no-}%{!m32:%{!m64:no-}}%{m64:}use-divide-subroutine
         ;;
-  x86_64-*-darwin9*)
+  x86_64-*-darwin9* | x86_64-*-darwin1[0-9]*)
 	enable_hash_synchronization_default=yes
 	slow_pthread_self=
 	can_unwind_signal=yes
--- gcc-4.3.6/gcc/config/i386/t-darwin64.orig	2009-10-18 12:21:43.000000000 -0400
+++ gcc-4.3.6/gcc/config/i386/t-darwin64	2009-10-18 12:22:21.000000000 -0400
@@ -1,5 +1,11 @@
 LIB2_SIDITI_CONV_FUNCS=yes
 LIB2FUNCS_EXTRA = $(srcdir)/config/darwin-64.c
 
+MULTILIB_OPTIONS = m32
+MULTILIB_DIRNAMES = i386
+
+LIBGCC = stmp-multilib
+INSTALL_LIBGCC = install-multilib
+
 softfp_wrap_start := '\#ifdef __x86_64__'
 softfp_wrap_end := '\#endif'
--- gcc-4.3.6/gcc/cp/Make-lang.in	2009/09/09 08:14:36	151554
+++ gcc-4.3.6/gcc/cp/Make-lang.in	2009/09/09 08:46:32	151555
@@ -72,7 +72,7 @@
 CXX_C_OBJS = attribs.o c-common.o c-format.o c-pragma.o c-semantics.o c-lex.o \
 	c-dump.o $(CXX_TARGET_OBJS) c-pretty-print.o c-opts.o c-pch.o \
 	c-incpath.o cppdefault.o c-ppoutput.o c-cppbuiltin.o prefix.o \
-	c-gimplify.o c-omp.o tree-inline.o
+	c-gimplify.o c-omp.o
 
 # Language-specific object files for C++ and Objective C++.
 CXX_AND_OBJCXX_OBJS = cp/call.o cp/decl.o cp/expr.o cp/pt.o cp/typeck2.o \
diff --git src/powerpc/darwin.S src/powerpc/darwin.S
--- gcc-4.3.6/libffi/src/powerpc/darwin.S
+++ gcc-4.3.6/libffi/src/powerpc/darwin.S
@@ -191,17 +191,17 @@ EH_frame1:
 LSCIE1:
 	.long	0x0	; CIE Identifier Tag
 	.byte	0x1	; CIE Version
 	.ascii	"zR\0"	; CIE Augmentation
 	.byte	0x1	; uleb128 0x1; CIE Code Alignment Factor
 	.byte	0x7c	; sleb128 -4; CIE Data Alignment Factor
 	.byte	0x41	; CIE RA Column
 	.byte	0x1	; uleb128 0x1; Augmentation size
-	.byte	0x90	; FDE Encoding (indirect pcrel)
+	.byte	0x10	; FDE Encoding (pcrel)
 	.byte	0xc	; DW_CFA_def_cfa
 	.byte	0x1	; uleb128 0x1
 	.byte	0x0	; uleb128 0x0
 	.align	LOG2_GPR_BYTES
 LECIE1:
 .globl _ffi_call_DARWIN.eh
 _ffi_call_DARWIN.eh:
 LSFDE1:
diff --git src/powerpc/darwin_closure.S src/powerpc/darwin_closure.S
--- gcc-4.3.6/libffi/src/powerpc/darwin_closure.S
+++ gcc-4.3.6/libffi/src/powerpc/darwin_closure.S
@@ -253,17 +253,17 @@ EH_frame1:
 LSCIE1:
 	.long	0x0	; CIE Identifier Tag
 	.byte	0x1	; CIE Version
 	.ascii	"zR\0"	; CIE Augmentation
 	.byte	0x1	; uleb128 0x1; CIE Code Alignment Factor
 	.byte	0x7c	; sleb128 -4; CIE Data Alignment Factor
 	.byte	0x41	; CIE RA Column
 	.byte	0x1	; uleb128 0x1; Augmentation size
-	.byte	0x90	; FDE Encoding (indirect pcrel)
+	.byte	0x10	; FDE Encoding (pcrel)
 	.byte	0xc	; DW_CFA_def_cfa
 	.byte	0x1	; uleb128 0x1
 	.byte	0x0	; uleb128 0x0
 	.align	LOG2_GPR_BYTES
 LECIE1:
 .globl _ffi_closure_ASM.eh
 _ffi_closure_ASM.eh:
 LSFDE1:
