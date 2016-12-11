require 'formula'

class Llvm < Formula
  version "32"
  homepage  'http://llvm.org/'
  url       'http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz'
  sha1      '42d139ab4c9f0c539c60f5ac07486e9d30fc1280'

  option :universal
  option 'with-clang', 'Build Clang C/ObjC/C++ frontend'
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'rtti', 'Build with C++ RTTI'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  depends_on :python => :recommended
  depends_on 'gmp@4'
  depends_on 'isl@011'
  depends_on 'cloog@018'

  resource 'clang' do
    url 'http://llvm.org/releases/3.2/clang-3.2.src.tar.gz'
    sha1 'b0515298c4088aa294edc08806bd671f8819f870'
  end

  resource 'compiler-rt' do
    url 'http://llvm.org/releases/3.2/compiler-rt-3.2.src.tar.gz'
    sha1 '718c0249a00e928f8bba32c84771da998ea4d42f'
  end

  resource 'polly' do
    url 'http://llvm.org/releases/3.2/polly-3.2.src.tar.gz'
    sha1 'b82b3650db710642dfce0c98a49fc0b866b6f152'
  end

  env :std if build.universal?

  def install
    if build.with? "python" and build.include? 'disable-shared'
      raise 'The Python bindings need the shared library.'
    end

    (buildpath/'tools/polly').install resource('polly')
    (buildpath/'tools/clang').install resource('clang') if build.with? 'clang'
    (buildpath/'projects/compiler-rt').install resource('compiler-rt') if build.with? 'asan'

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
      "--with-gmp=#{Formula.factory('gmp4').opt_prefix}",
      "--with-isl=#{Formula.factory('isl011').opt_prefix}",
      "--with-cloog=#{Formula.factory('cloog018').opt_prefix}"
    ]

    if build.include? 'all-targets'
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end
    args << "--enable-shared" unless build.include? 'disable-shared'

    args << "--disable-assertions" if build.include? 'disable-assertions'

    system './configure', *args
    system 'make', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    # Install Clang tools
    (share/"clang-#{version}/tools").install buildpath/'tools/clang/tools/scan-build', buildpath/'tools/clang/tools/scan-view' if build.with? 'clang'

    if build.with? "python"
      # Install llvm python bindings.
      mv buildpath/'bindings/python/llvm', buildpath/"bindings/python/llvm-#{version}"
      (lib+'python2.7/site-packages').install buildpath/"bindings/python/llvm-#{version}"
      # Install clang tools and bindings if requested.
      if build.with? 'clang'
        mv buildpath/'tools/clang/bindings/python/clang', buildpath/"tools/clang/bindings/python/clang-#{version}"
        (lib+'python2.7/site-packages').install buildpath/"tools/clang/bindings/python/clang-#{version}"
      end
    end

    # Link executables to bin and add suffix to avoid conflicts
    mkdir_p bin
    Dir.glob(install_prefix/'bin/*') do |exec_path|
      exec_file = File.basename(exec_path)
      ln_s exec_path, bin/"#{exec_file}-#{version}"
    end

    # Also link man pages
    mkdir_p man1
    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      manpage_base = File.basename(manpage, '.1')
      ln_s manpage, man1/"#{manpage_base}-#{version}.1"
    end
  end

  def test
    system "#{bin}/llvm-config-#{version}", "--version"
  end

  def caveats
    if build.with? 'clang'
      "Extra tools are installed in #{HOMEBREW_PREFIX/"share/clang-#{version}"}."
    end
  end
end
