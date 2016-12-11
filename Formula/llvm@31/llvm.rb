require 'formula'

class Clang < Formula
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.1/clang-3.1.src.tar.gz'
  sha1      '19f33b187a50d22fda2a6f9ed989699a9a9efd62'
end

class Llvm < Formula
  version "31"
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.1/llvm-3.1.src.tar.gz'
  sha1      '234c96e73ef81aec9a54da92fc2a9024d653b059'

  option :universal
  option 'with-clang', 'Build Clang C/ObjC/C++ frontend'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'rtti', 'Build with C++ RTTI'

  depends_on :python => :recommended

  env :std if build.universal?

  def install
    if python and build.include? 'disable-shared'
      raise 'The Python bindings need the shared library.'
    end

    Clang.new('clang').brew do
      (buildpath/'tools/clang').install Dir['*']
    end if build.with? 'clang'

    if build.universal?
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = Hardware::CPU.universal_archs.join(' ')
    end

    ENV['REQUIRES_RTTI'] = '1' if build.include? 'rtti'

    install_prefix = lib/"llvm-#{version}"

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      # As of LLVM 3.1, attempting to build ocaml bindings with Homebrew's
      # OCaml 3.12.1 results in errors.
      "--disable-bindings",
    ]

    if build.include? 'all-targets'
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end
    args << "--enable-shared" if not build.include? 'disable-shared'

    system "./configure", *args
    system 'make', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    # Install Clang tools
    (share/"clang-#{version}/tools").install buildpath/'tools/clang/tools/scan-build', buildpath/'tools/clang/tools/scan-view' if build.with? 'clang'

    if python
      # Install llvm python bindings.
      mv buildpath/'bindings/python/llvm', buildpath/"bindings/python/llvm-#{version}"
      python.site_packages.install buildpath/"bindings/python/llvm-#{version}"
      # Install clang tools and bindings if requested.
      if build.with? 'clang'
        mv buildpath/'tools/clang/bindings/python/clang', buildpath/"tools/clang/bindings/python/clang-#{version}"
        python.site_packages.install buildpath/"tools/clang/bindings/python/clang-#{version}"
      end
    end

    # Link executables to bin and add suffix to avoid conflicts
    mkdir_p bin
    Dir.glob(install_prefix/'bin/*') do |exec_path|
      exec_file = File.basename(exec_path)
      ln_s exec_path, bin/"#{exec_file}-#{version}"
    end

    # Also link man pages
    mkdir_p share/'man/man1'
    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      manpage_base = File.basename(manpage, '.1')
      ln_s manpage, share/"man/man1/#{manpage_base}-#{version}.1"
    end
  end

  def test
    system "#{bin}/llvm-config-#{version}", "--version"
  end

  def caveats
    s = ''
    s += python.standard_caveats if python

    if build.with? 'clang'
      clang_tools_path = HOMEBREW_PREFIX/"share/clang-#{version}"
      s += <<-EOS.undent

      Extra tools are installed in #{clang_tools_path}.
      EOS
    end
    s
  end

end
