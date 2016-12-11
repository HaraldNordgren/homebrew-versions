require 'formula'

class Ruby < Formula
  version "193"
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p545.tar.bz2'
  sha256 '2533de9f56d62f11c06a02dd32b5ab6d22a8f268c94b8e1e1ade6536adfd1aab'

  option :universal
  option 'with-suffix', 'Suffix commands with "193"'
  option 'with-doc', 'Install documentation'
  option 'with-tcltk', 'Install with Tcl/Tk support'

  depends_on 'pkg-config' => :build
  depends_on 'readline'
  depends_on 'gdbm'
  depends_on 'libyaml'
  depends_on :x11 if build.with? 'tcltk'

  fails_with :llvm do
    build 2326
  end

  def install
    args = ["--prefix=#{prefix}",
            "--enable-shared"]

    args << "--program-suffix=193" if build.with? "suffix"
    args << "--with-arch=x86_64,i386" if build.universal?
    args << "--disable-tcltk-framework" <<  "--with-out-ext=tcl" <<  "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"

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
    system "make install-doc" if build.with? "doc"

  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end
end
