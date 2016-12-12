class Mpfr < Formula
  version "2"
  desc "Multiple-precision floating-point computations C lib"
  homepage "http://www.mpfr.org/"
  # Track gcc infrastructure releases.
  url "http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2"
  sha256 "c7e75a08a8d49d2082e4caee1591a05d11b9d5627514e678f02d66a124bcf2ba"

  bottle do
    cellar :any
    sha256 "b567a28e0d55497325ab97f73e302414bd66e48068c8dbb1092d453704ffe523" => :yosemite
    sha256 "3f195ad79022a35840e46f0726f623c932ad5ef72516a873615078f053867aef" => :mavericks
    sha256 "ab7c5d3f5aa1adb76d27b66389c9aa65ee4a52c7c23d40dee30b8ca78653ca17" => :mountain_lion
    sha1 "d146a7ec89d73a64906ed3fa930d1062b0cb5479" => :tiger_g3
    sha1 "87ea4788e631dd447a92e78cc183093ecf4157be" => :tiger_altivec
    sha1 "6ffec69dca10ac3cb40a6dc7d1221200eb7d888a" => :leopard_g3
    sha1 "39c667af86e969336c904afb55ad7b25f81a4140" => :leopard_altivec
  end

  option "with-32-bit"

  deprecated_option "32-bit" => "with-32-bit"

  depends_on "gmp@4"

  keg_only "Conflicts with mpfr in main repository."

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/mxcl/homebrew/issues/15061
      EOS
  end

  def install
    gmp4 = Formula["gmp4"]

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-gmp=#{gmp4.opt_prefix}
    ]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    # Note: This logic should match what the GMP formula does.
    if MacOS.prefer_64_bit? && !build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--build=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
