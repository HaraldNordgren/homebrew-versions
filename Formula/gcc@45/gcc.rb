require 'formula'

class Gcc < Formula
  version "45"
  homepage 'http://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.5.3/gcc-4.5.3.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.5.3/gcc-4.5.3.tar.bz2'
  sha1 '73c45dfda5eef6b124be53e56828b5925198cc1b'

  option 'enable-cxx', 'Build the g++ compiler'
  option 'enable-fortran', 'Build the gfortran compiler'
  option 'enable-java', 'Buld the gcj compiler'
  option 'enable-objc', 'Enable Objective-C language support'
  option 'enable-objcxx', 'Enable Objective-C++ language support'
  option 'enable-all-languages', 'Enable all compilers and languages, except Ada'
  option 'enable-nls', 'Build with native language support'
  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'enable-multilib', 'Build with multilib support'

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  # Dont strip compilers.
  skip_clean :all

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
      "--with-gmp=#{gmp.prefix}",
      "--with-mpfr=#{mpfr.prefix}",
      "--with-mpc=#{libmpc.prefix}",
      "--with-system-zlib",
      "--enable-stage1-checking",
      "--enable-plugin",
      "--disable-lto"
    ]

    args << '--disable-nls' unless build.include? 'enable-nls'

    if build_everything?
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
      # deja-gnu formula must be installed in order to do this.

      system 'make install'

      # `make install` neglects to transfer an essential plugin header file.
      Pathname.new(Dir[gcc_prefix.join *%w[** plugin include config]].first).install '../gcc/config/darwin-sections.def'

      # Remove conflicting manpages in man7
      man7.rmtree
    end
  end
end
