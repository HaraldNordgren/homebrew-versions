# Ruby 1.8.6 requires a special version of imagemagick
# We simply revived an earlier version and added the suffix.
#   https://github.com/mxcl/homebrew/blob/685dbff9301c215ac6f7ca775bbe8eed2bf62662/Library/Formula/imagemagick.rb

require 'formula'

# some credit to http://github.com/maddox/magick-installer
# NOTE please be aware that the GraphicsMagick formula derives this formula

def ghostscript_srsly?
  ARGV.include? '--with-ghostscript'
end

class ImagemagickRuby < Formula
  version "186"
  homepage 'http://www.imagemagick.org'
  url 'http://image_magick.veidrodis.com/image_magick/ImageMagick-6.5.9-8.tar.bz2'
  md5 '89892e250e81fad51b4b2a1f816987e6'

  depends_on 'jpeg'
  depends_on 'libwmf' => :optional
  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'jasper' => :optional
  depends_on 'ghostscript' => :recommended if ghostscript_srsly?
  depends_on :libpng

  skip_clean :la

  def options
    [['--with-ghostscript', 'Enable ghostscript support']]
  end

  def fix_configure
    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'
  end

  def configure_args
    args = ["--prefix=#{prefix}",
     "--disable-dependency-tracking",
     "--enable-shared",
     "--disable-static",
     "--with-modules",
     "--without-magick-plus-plus"]

     args << "--disable-openmp" if MacOS.version < 10.6   # libgomp unavailable
     args << '--without-ghostscript' \
          << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" \
             unless ghostscript_srsly?
     return args
  end

  def install
    ENV.deparallelize

    fix_configure

    system "./configure", "--without-maximum-compile-warnings",
                          "--disable-osx-universal-binary",
                          "--without-perl", # I couldn't make this compile
                          *configure_args
    system "make install"

    # We already copy these into the keg root
    (share+"ImageMagick/NEWS.txt").unlink
    (share+"ImageMagick/LICENSE").unlink
    (share+"ImageMagick/ChangeLog").unlink
  end
end

