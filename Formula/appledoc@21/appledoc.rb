require 'formula'

# The 2.2 series introduces support for documenting enumerated and
# bitmask types, but will emit warnings on encountering undocumented
# instances of those types.  2.1 (build 840) is provided to allow
# projects to successfully build with undocumented enumerated and
# bitmask types.
class Appledoc < Formula
  version "21"
  homepage 'http://appledoc.gentlebytes.com/'
  url "https://github.com/tomaz/appledoc/archive/v2.1.tar.gz"
  sha1 'c30675e340d2ae1334e3d9254701de6f40d6658c'

  keg_only %{
This formula is keg-only to avoid conflicts with the core Appledoc formula.
The executable installed by this formula may be invoked explicitly,
or (if it is the only version installed) linked after it is installed.
  }

  depends_on :xcode
  depends_on :macos => :lion

  def install
    system "xcodebuild", "-project", "appledoc.xcodeproj",
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
