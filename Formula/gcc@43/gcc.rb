class Gcc < Formula
  version "43"
  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        "x86_64"
      else
        "i686"
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        "powerpc64"
      else
        "powerpc"
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  desc "GNU compiler collection"
  homepage "https://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-4.3.6/gcc-4.3.6.tar.bz2"
  sha256 "f3765cd4dcceb4d42d46f0d53471d7cedbad50f2112f0312c1dcc9c41eea9810"

  bottle do
    sha256 "8bf79083ea4ad049f9c11a0bb2b46de64e54e9ae064c280e9af4b1cfdf44c912" => :mavericks
    sha256 "99ea8382997d8c0d67a950d5fe26b79b18ec56dc359eb8ef3d0f16bbcb77d3d5" => :mountain_lion
  end

  option "with-fortran", "Build the gfortran compiler"
  option "with-java", "Build the gcj compiler"
  option "with-all-languages", "Enable all compilers and languages, except Ada"
  option "with-nls", "Build with native language support (localization)"
  option "with-profiled-build", "Make use of profile guided optimization when bootstrapping GCC"

  deprecated_option "enable-fortran" => "with-fortran"
  deprecated_option "enable-java" => "with-java"
  deprecated_option "enable-all-languages" => "with-all-languages"
  deprecated_option "enable-nls" => "with-nls"
  deprecated_option "enable-profiled-build" => "with-profiled-build"

  depends_on MaximumMacOSRequirement => :mavericks
  depends_on "gmp@4"
  depends_on "mpfr@2"
  depends_on "ecj" if build.with?("java") || build.with?("all-languages")

  # Fix building on darwin10
  patch :p0 do
    url "https://trac.macports.org/export/110576/trunk/dports/lang/gcc43/files/darwin10.diff"
    sha256 "df1019b634f4e1b28c8a62f98374a1acc67e4540c65372fb87e84914d56c6daf"
  end

  # Fix multilib
  patch :p0 do
    url "https://trac.macports.org/export/110576/trunk/dports/lang/gcc43/files/i386_multilib.diff"
    sha256 "e5e94df259db4cc5c14a61f2553fc1a496052cbd306d23ba95dccf9f01517795"
  end

  # Build fix for Snow Leopard
  patch :p0 do
    url "https://trac.macports.org/export/110576/trunk/dports/lang/gcc43/files/Make-lang.in.diff"
    sha256 "3e4e860b1a718fc43005681025448f7f6fd820f892a20419a723b887c588075e"
  end

  # Fix libffi fix for ppc
  patch :p0 do
    url "https://trac.macports.org/export/110576/trunk/dports/lang/gcc43/files/ppc_fde_encoding.diff"
    sha256 "9c5f6fd30d089e97e0364af322272bb06f3d107f357d2b621503ebfbbb4a5af7"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    if build.with? "all-languages"
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap.
      languages = %w[c c++ fortran java objc obj-c++]
    else
      # C, C++, ObjC compilers are always built
      languages = %w[c c++ objc obj-c++]

      languages << "fortran" if build.with? "fortran"
      languages << "java" if build.with? "java"
    end

    version_suffix = version.to_s.slice(/\d\.\d/)

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--infodir=#{info}",
      "--enable-languages=#{languages.join(",")}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}",
      "--with-system-zlib",
      # This ensures lib, libexec, include are sandboxed so that they
      # don't wander around telling little children there is no Santa
      # Claus.
      "--enable-version-specific-runtime-libs",
      "--enable-stage1-checking",
      "--enable-checking=release",
      # Multilib building is broken in GCC 4.3 on Darwin.
      "--disable-multilib",
      # A no-op unless --HEAD is built because in head warnings will
      # raise errors. But still a good idea to include.
      "--disable-werror",
      "--with-pkgversion=Homebrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/Homebrew/homebrew-versions/issues",
    ]

    args << "--disable-nls" if build.without? "nls"

    if build.with?("java") || build.with?("all-languages")
      args << "--with-ecj-jar=#{Formula["ecj"].opt_prefix}/share/java/ecj.jar"
    end

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args

      # Flags for Clang compatibility
      make_flags = 'BOOT_CFLAGS="$BOOT_CFLAGS -D_FORTIFY_SOURCE=0" STAGE1_CFLAGS="$STAGE1_CFLAGS -std=gnu89 -D_FORTIFY_SOURCE=0 -fkeep-inline-functions"'

      if build.with? "profiled-build"
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system "make", make_flags, "profiledbootstrap"
      else
        system "make", make_flags, "bootstrap"
      end

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu formula must be installed in order to do this.
      system "make", "install"
    end

    # Handle conflicts between GCC formulae.
    # Remove libffi stuff, which is not needed after GCC is built.
    Dir.glob(prefix/"**/libffi.*") { |file| File.delete file }
    # Rename libiberty.a.
    Dir.glob(prefix/"**/libiberty.*") { |file| add_suffix file, version_suffix }
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. Fix this.
    info.rmtree

    # Rename java properties
    if build.with?("java") || build.with?("all-languages")
      config_files = [
        "#{lib}/logging.properties",
        "#{lib}/security/classpath.security",
        "#{lib}/i386/logging.properties",
        "#{lib}/i386/security/classpath.security",
      ]

      config_files.each do |file|
        add_suffix file, version_suffix if File.exist? file
      end
    end
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end

  test do
    (testpath/"hello-c.c").write <<-EOS.undent
      #include <stdio.h>
      int main()
      {
        puts("Hello, world!");
        return 0;
      }
    EOS
    system bin/"gcc-4.3", "-o", "hello-c", "hello-c.c"
    assert_equal "Hello, world!\n", `./hello-c`
  end
end
