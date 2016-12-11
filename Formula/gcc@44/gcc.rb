require 'formula'

class Gcc < Formula
  version "44"
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
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.4.7/gcc-4.4.7.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.4.7/gcc-4.4.7.tar.bz2'
  sha1 'a6c834b0c2f58583da1d093de7a81a20ede9af75'

  option 'enable-cxx', 'Build the g++ compiler'
  option 'enable-fortran', 'Build the gfortran compiler'
  option 'enable-java', 'Buld the gcj compiler'
  option 'enable-objc', 'Enable Objective-C language support'
  option 'enable-objcxx', 'Enable Objective-C++ language support'
  option 'enable-all-languages', 'Enable all compilers and languages, except Ada'
  option 'enable-nls', 'Build with native language support (localization)'
  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'enable-multilib', 'Build with multilib support'

  depends_on 'gmp@4'
  depends_on 'mpfr@2'
  depends_on 'ppl@011'
  depends_on 'cloog-ppl@015'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  # Patches adapted from macports:
  # http://trac.macports.org/browser/trunk/dports/lang/gcc44/files
  def patches; DATA; end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete 'LD'

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
      "--with-datarootdir=#{share}",
      "--mandir=#{man}",
      # ...and the binaries...
      "--bindir=#{bin}",
      # ...which are tagged with a suffix to distinguish them.
      "--enable-languages=#{languages.join(',')}",
      "--program-suffix=-#{version.to_s.slice(/\d\.\d/)}",
      "--with-gmp=#{Formula.factory('gmp4').opt_prefix}",
      "--with-mpfr=#{Formula.factory('mpfr2').opt_prefix}",
      "--with-ppl=#{Formula.factory('ppl011').opt_prefix}",
      "--disable-ppl-version-check",
      "--with-cloog=#{Formula.factory('cloog-ppl015').opt_prefix}",
      "--with-system-zlib",
      "--enable-libstdcxx-time=yes",
      "--enable-stage1-checking",
      "--enable-checking=release",
      # a no-op unless --HEAD is built because in head warnings will raise errs.
      "--disable-werror"
    ]

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
diff --git src/powerpc/darwin.S src/powerpc/darwin.S
--- gcc-4.4.7.orig/libffi/src/powerpc/darwin.S
+++ gcc-4.4.7/libffi/src/powerpc/darwin.S
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
--- gcc-4.4.7.orig/libffi/src/powerpc/darwin_closure.S
+++ gcc-4.4.7/libffi/src/powerpc/darwin_closure.S
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
