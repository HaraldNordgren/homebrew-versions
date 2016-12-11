require 'formula'

class Ruby < Formula
  version "192"
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.bz2'
  sha256 '403b3093fbe8a08dc69c269753b8c6e7bd8f87fb79a7dd7d676913efe7642487'

  head 'http://svn.ruby-lang.org/repos/ruby/trunk/'

  depends_on :autoconf if build.head?
  depends_on 'pkg-config' => :build
  depends_on 'readline'
  depends_on 'gdbm'
  depends_on 'libyaml'

  option :universal
  option 'with-suffix', 'Suffix commands with "192"'
  option 'with-doc', 'Install documentation'

  fails_with :llvm do
    build 2326
  end

  def install
    system "autoconf" if build.head?

    args = %W[--prefix=#{prefix}
              --enable-shared]

    args << "--program-suffix=192" if build.include? 'with-suffix'
    args << "--with-arch=x86_64,i386" if build.universal?

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
    system "make install-doc" if build.include? 'with-doc'

  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end
end
