require 'formula'

class CloogPpl < Formula
  version "015"
  homepage 'http://repo.or.cz/w/cloog-ppl.git'
  url 'ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz'
  mirror 'http://gcc.cybermirror.org/infrastructure/cloog-ppl-0.15.11.tar.gz'
  sha1 '42fa476a79a1d52da41608a946dcb47c70f7e3b9'

  keg_only 'Conflicts with cloog in main repository.'

  depends_on 'gmp@4'
  depends_on 'ppl@011'

  def install
    gmp4 = Formula.factory 'gmp4'
    ppl011 = Formula.factory 'ppl011'

    args = [
      "--prefix=#{prefix}",
      "--with-gmp=#{gmp4.opt_prefix}",
      "--with-ppl=#{ppl011.opt_prefix}"
    ]

    system "./configure", *args
    system "make", "install"
  end

end
