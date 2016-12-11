# This formula tracks GnuTLS stable-next. This is currently the 3.4.x branch.
class Gnutls < Formula
  version "34"
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.6.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.4/gnutls-3.4.6.tar.xz"
  sha256 "feb559ed7fffa24d5aa40527054fae5cb7f7b66e9f2bebc2383a781dfa4d20ec"

  bottle do
    cellar :any
    sha256 "eb82e740ab5bb76caaf2de047f4831602f9ea475b2839fc1a110f546519bc5b0" => :el_capitan
    sha256 "65dbd60424d3825ca0ccd2f9dd0401319edf93eaa2e082eb06fad3f685a95b4d" => :yosemite
    sha256 "bafcdc69c16325974570902fce010dfb13e7fd8ad118d39695ebfd41ecd30404" => :mavericks
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
