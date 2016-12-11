# This formula tracks GnuTLS stable-next. This is currently the 3.4.x branch.
class Gnutls < Formula
  version "34"
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.4.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.4/gnutls-3.4.4.tar.xz"
  sha256 "06dacb1352792b9f05200eff33c9a9093ba3c706f4f88cb29ecbfb784b24b34a"

  bottle do
    cellar :any
    sha256 "15ede4ba5c02fa5dcc9e7edee0ce1df29dd5acd6d5ecc57ae0eea62ae1a692ac" => :yosemite
    sha256 "387b22e785931178c6c5cf979ef19708136ed6babcd6596fcc31a39abb68a4a5" => :mavericks
    sha256 "4c9792290c1b8f0ae3d39f3c8378844c8e0aa601d12dd536d4507cfe742fd0c9" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "autogen"
  depends_on "libtasn1"
  depends_on "gmp"
  depends_on "nettle@3"
  depends_on "guile" => :optional
  depends_on "unbound" => :optional
  depends_on "libidn" => :optional

  keg_only "Conflicts with GnuTLS in main repository and is not API compatible."

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}/gnutls34
      --with-default-trust-store-file=#{etc}/openssl/cert.pem
      --disable-heartbeat-support
      --without-p11-kit
    ]

    if build.with? "guile"
      args << "--enable-guile"
      args << "--with-guile-site-dir=no"
    end

    system "./configure", *args
    system "make", "install"

    # certtool shadows the OS X certtool utility
    mv bin/"certtool", bin/"gnutls-certtool"
    mv man1/"certtool.1", man1/"gnutls-certtool.1"
  end

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
    )

    valid_certs = certs.select do |cert|
      IO.popen("openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
        openssl_io.write(cert)
        openssl_io.close_write
      end

      $?.success?
    end

    openssldir = etc/"openssl"
    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(valid_certs.join("\n"))
  end

  test do
    system bin/"gnutls-cli", "--version"
  end
end
