class Gnupg < Formula
  version "21"
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.3.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.3.tar.bz2"
  sha256 "213e7fb0d74bb4e53a2d3153f309ddc077528f2cfffa2af85f2a20cc7875c8ed"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "11e98150489f0f1b1d258b14c4121aa73140c98c" => :yosemite
    sha1 "1ea8b6ce35b84b6a51227ba51b1c9b137d19d04b" => :mavericks
    sha1 "60f2f5cef5068a1c4a1c0ffa79ffe04d74ca5615" => :mountain_lion
  end

  head do
    url "git://git.gnupg.org/gnupg.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "npth"
  depends_on "gnutls"
  depends_on "encfs" => :optional
  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pinentry"
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :optional
  depends_on "gettext"

  conflicts_with "gnupg2",
        :because => "GPG2.1.x is incompatible with the 2.0.x branch."
  conflicts_with "gpg-agent",
        :because => "GPG2.1.x ships an internal gpg-agent which it must use."
  conflicts_with "dirmngr",
        :because => "GPG2.1.x ships an internal dirmngr which it it must use."
  conflicts_with "fwknop",
        :because => "fwknop expects to use a `gpgme` with Homebrew/Homebrew's gnupg2."
  conflicts_with "gpgme",
        :because => "gpgme currently requires 1.x.x or 2.0.x."

  # https://lists.gnupg.org/pipermail/gnupg-users/2015-April/053428.html
  # GCC build doesn't fail. That was a mistaken labelling. Have notified upstream.
  fails_with :clang do
    cause "t-stringhelp.c:488:3: error: function definition is not allowed here"
  end

  fails_with :llvm do
    cause "t-stringhelp.c:488:3: error: function definition is not allowed here"
  end

  def install
    (var/"run").mkpath

    ENV.append "LDFLAGS", "-lresolv"

    ENV["gl_cv_absolute_stdint_h"] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sbindir=#{bin}
      --sysconfdir=#{etc}
      --enable-symcryptrun
    ]

    args << "--with-readline=#{Formula["readline"].opt_prefix}" if build.with? "readline"

    if build.head?
      args << "--enable-maintainer-mode"
      system "./autogen.sh", "--force"
      system "automake", "--add-missing"
    end

    # Adjust package name to fit our scheme of packaging both gnupg 1.x and
    # and 2.1.x and gpg-agent separately.
    inreplace "configure" do |s|
      s.gsub! "PACKAGE_NAME='gnupg'", "PACKAGE_NAME='gnupg2'"
      s.gsub! "PACKAGE_TARNAME='gnupg'", "PACKAGE_TARNAME='gnupg2'"
    end

    inreplace "tools/gpgkey2ssh.c", "gpg --list-keys", "gpg2 --list-keys"

    system "./configure", *args

    system "make"
    system "make", "check"
    system "make", "install"
    # Conflicts with a manpage from the 1.x formula, and
    # gpg-zip isn't installed by this formula anyway
    rm man1/"gpg-zip.1"
    # Move more man conflict out of 1.x's way.
    mv share/"doc/gnupg2/FAQ", share/"doc/gnupg2/FAQ21"
    mv share/"doc/gnupg2/examples/gpgconf.conf", share/"doc/gnupg2/examples/gpgconf21.conf"
    mv share/"info/gnupg.info", share/"info/gnupg21.info"
    mv "#{man7}/gnupg.7", "#{man7}/gnupg21.7"
  end

  def caveats; <<-EOS.undent
    Once you run the new gpg2 binary you will find it incredibly
    difficult to go back to using `gnupg2` from Homebrew/Homebrew.
    The new 2.1.x moves to a new keychain format that can't be
    and won't be understood by the 2.0.x branch or lower.

    If you use this `gnupg21` formula for a while and decide
    you don't like it, you will lose the keys you've imported since.
    For this reason, we strongly advise that you make a backup
    of your `~/.gnupg` directory.

    For full details of the changes, please visit:
      https://www.gnupg.org/faq/whats-new-in-2.1.html

    If you are upgrading to gnupg21 from gnupg2 you should execute:
      `killall gpg-agent && gpg-agent --daemon --use-standard-socket`
    After install. See:
      https://github.com/Homebrew/homebrew-versions/issues/681
    EOS
  end

  test do
    system "#{bin}/gpgconf"
  end
end
