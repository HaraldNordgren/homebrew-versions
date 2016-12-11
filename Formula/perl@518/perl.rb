require 'formula'

class Perl < Formula
  version "518"
  homepage 'http://www.perl.org/'
  url 'http://www.cpan.org/src/5.0/perl-5.18.0.tar.gz'
  sha1 'f5a97a9fa4e9d0ef9c4b313c5b778a0e76291ee2'

  keg_only 'System provides Perl. Also conflicts with other Perl versions.'

  option 'use-dtrace', 'Build with DTrace probes'

  def install
    args = [
      '-des',
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      '-Duseshrplib',
      '-Duselargefiles',
      '-Dusethreads'
    ]

    args << '-Dusedtrace' if build.include? 'use-dtrace'

    system './Configure', *args
    system "make"
    system "make test"
    system "make install"
  end
end
