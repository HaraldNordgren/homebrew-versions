class Libcouchbase < Formula
  version "1"
  homepage "http://couchbase.com/develop/c/current"
  url "http://packages.couchbase.com/clients/c/libcouchbase-1.0.6.tar.gz"
  sha256 "ff86530a0fc21a2a6b719b389163a1f5172e379630b7dc91cbd2d16b5d586dc7"

  depends_on "libevent"
  depends_on "libvbucket"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-couchbasemock"
    system "make", "install"
  end

  test do
    system "#{bin}/cbc-version"
  end
end
