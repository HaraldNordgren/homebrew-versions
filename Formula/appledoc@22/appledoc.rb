require 'formula'

# 2.2 (build 961) introduces support for documenting enumerated and
# bitmask types, and will emit warnings on encountering undocumented
# instances of those types.  An archived release is provided as a stable
# dependency for e.g. continuous integration environments.
class Appledoc < Formula
  version "22"
  homepage 'http://appledoc.gentlebytes.com/'
  url "https://github.com/tomaz/appledoc/archive/v2.2.tar.gz"
  sha1 '4ad475ee6bdc2e34d6053c4e384aad1781349f5e'

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
