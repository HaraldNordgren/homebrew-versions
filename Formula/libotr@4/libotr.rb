class Libotr < Formula
  version "4"
  homepage "https://otr.cypherpunks.ca/"
  url "https://otr.cypherpunks.ca/libotr-4.0.0.tar.gz"
  sha256 "3f911994409898e74527730745ef35ed75c352c695a1822a677a34b2cf0293b4"

  depends_on "libgcrypt"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end
