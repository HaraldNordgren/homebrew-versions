require 'formula'

class Gcc < Formula
  homepage 'http://gcc.gnu.org'
  url 'ftp://gcc.gnu.org/pub/gcc/snapshots/4.8.0-RC-20130316/gcc-4.8.0-RC-20130316.tar.bz2'
  version '4.8-RC'
  sha1 '390a283980f2a1752b4084fd756f739f6ed5b0e1'

  head 'svn://gcc.gnu.org/svn/gcc/branches/gcc-4_8-branch'

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
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  def install
    # Force 64-bit on systems that use it. Build failures reported for some
    # systems when this is not done.
    ENV.m64 if MacOS.prefer_64_bit?

    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete 'LD'

    # This is required on systems running a version newer than 10.6, and
    # it's probably a good idea regardless.
    #
    # https://trac.macports.org/ticket/27237
    ENV.append 'CXXFLAGS', '-U_GLIBCXX_DEBUG -U_GLIBCXX_DEBUG_PEDANTIC'

    gmp = Formula.factory 'gmp'
    mpfr = Formula.factory 'mpfr'
    libmpc = Formula.factory 'libmpc'
    cloog = Formula.factory 'cloog'
    isl = Formula.factory 'isl'

    # Sandbox the GCC lib, libexec and include directories so they don't wander
    # around telling small children there is no Santa Claus. This results in a
    # partially keg-only brew following suggestions outlined in the "How to
    # install multiple versions of GCC" section of the GCC FAQ:
    #     http://gcc.gnu.org/faq.html#multiple
    gcc_prefix = prefix + 'gcc'

    args = [
      # Sandbox everything...
      "--prefix=#{gcc_prefix}",
      # ...except the stuff in share...
      "--datarootdir=#{share}",
      # ...and the binaries...
      "--bindir=#{bin}",
      # ...which are tagged with a suffix to distinguish them.
      "--program-suffix=-#{version.to_s.slice(/\d\.\d/)}",
      "--with-gmp=#{gmp.opt_prefix}",
      "--with-mpfr=#{mpfr.opt_prefix}",
      "--with-mpc=#{libmpc.opt_prefix}",
      "--with-cloog=#{cloog.opt_prefix}",
      "--with-isl=#{isl.opt_prefix}",
      "--with-system-zlib",
      "--enable-stage1-checking",
      "--enable-plugin",
      "--enable-lto",
      # a no-op unless --HEAD is built because in head warnings will raise errs.
      "--disable-werror"
    ]

    args << '--disable-nls' unless build.include? 'enable-nls'

    if build.include? 'enable-all-languages'
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap. GCC 4.6.0 add go as a language option, but it is
      # currently only compilable on Linux.
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

      system '../configure', "--enable-languages=#{languages.join(',')}", *args

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

      # Remove conflicting manpages in man7
      man7.rmtree
    end
  end
end
