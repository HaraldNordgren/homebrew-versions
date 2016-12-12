class Mongodb < Formula
  version "26"
  desc "High-performance document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r2.6.11.tar.gz"
  sha256 "e1a64a1ef7114f3e8ed3c7acaa4e97ffe30e2b57a1a5f2a40f0018bad3b8d12f"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "5f2e34e3f6a1d3baaba6d07544142f9d9965be14a4b35ea5453ce4c3049d2a94" => :el_capitan
    sha256 "045396065bbd37697d3a2c71cbfc9f2be49210c660a69719a353396cabfd6e61" => :yosemite
    sha256 "f16c1cae041a6479bf50bf4a269e4a2097f1fd6cd0a3758ed448294c217e1d6e" => :mavericks
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "boost" => :optional
  depends_on "openssl" => :optional

  # Review this patch with each release.
  # This modifies the SConstruct file to include 10.10 and 10.11 as accepted build options.
  if MacOS.version >= :yosemite
    patch do
      url "https://gist.githubusercontent.com/asmarques/4e4e66121dbe46a08933/raw/d6753551ff3849bf0fb5ca87c0a96e1255f4254d/mongodb26-elcapitan.diff"
      sha256 "2f79588a8a15660908d8d071655541c9ab0ac425550b02dc454c861c75f86606"
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
      --full
    ]

    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

    # Pass the --disable-warnings-as-errors flag to Scons when on Yosemite
    # or later, otherwise 2.6.x won't build from source due to a Clang 3.5+
    # error - https://github.com/mongodb/mongo/pull/956#issuecomment-94545753
    args << "--disable-warnings-as-errors" if MacOS.version >= :yosemite

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var/"mongodb").mkpath
    (var/"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
