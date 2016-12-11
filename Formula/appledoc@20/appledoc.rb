require 'formula'

# The 2.1 series requires Lion or newer.
# 2.0.6 is provided for Snow Leopard compatibility.
class Appledoc < Formula
  version "20"
  homepage 'http://appledoc.gentlebytes.com/'
  url 'https://github.com/tomaz/appledoc/archive/v2.0.6.tar.gz'
  sha1 '3d76172339cbfea24ef53f55e2452cc78930413e'

  depends_on :xcode

  def install
    xcodebuild "-project", "appledoc.xcodeproj",
               "-target", "appledoc",
               "-configuration", "Release",
               "clean", "install",
               "SYMROOT=build",
               "DSTROOT=build",
               "INSTALL_PATH=/bin",
               "OTHER_CFLAGS='-DCOMPILE_TIME_DEFAULT_TEMPLATE_PATH=@\"#{prefix}/Templates\"'"
    bin.install "build/bin/appledoc"
    prefix.install "Templates/"
  end

  test do
    system "#{bin}/appledoc", "--version"
  end
end
