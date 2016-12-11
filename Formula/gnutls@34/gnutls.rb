# This formula tracks GnuTLS stable-next. This is currently the 3.4.x branch.
class Gnutls < Formula
  version "34"
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.5.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.4/gnutls-3.4.5.tar.xz"
  sha256 "af88b8e0460728d034ff3f454f7851a09b7f0959a93531b6f8d35658ef0f7aae"

  bottle do
    cellar :any
    sha256 "30f3453447fc6f4851a42d444aaa18a2d2711af294a5f0b02ae5552d8573cb18" => :yosemite
    sha256 "27e42b369dd48e7f9efde2eaba9d226cdbedea39221fff7a028f81dea1dabb49" => :mavericks
    sha256 "2016e94ef9a5ebbfd10ce9afac4965afd78197cccfe9e9fb9e82048af2d3222d" => :mountain_lion
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
