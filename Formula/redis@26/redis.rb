class Redis < Formula
  version "26"
  desc "Persistent key-value database, built-in net interface"
  homepage "http://redis.io/"
  url "http://download.redis.io/releases/redis-2.6.17.tar.gz"
  sha256 "5a65b54bb6deef2a8a4fabd7bd6962654a5d35787e68f732f471bbf117f4768e"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "7cb8c533eb6613e8e52484acc47808c2442a38f9" => :yosemite
    sha1 "bac0ebd6021a55d0e0076d0e3ceb38c101ec1238" => :mavericks
    sha1 "ddf4f2f99e96d58ffa7f816af6e93076ea7adf10" => :mountain_lion
  end

  fails_with :llvm do
    build 2334
    cause "Fails with 'reference out of range from _linenoise'"
  end

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = MacOS.prefer_64_bit? ? "-arch x86_64" : "-arch i386"

    # Head and stable have different code layouts
    src = (buildpath/"src/Makefile").exist? ? buildpath/"src" : buildpath
    system "make", "-C", src, "CC=#{ENV.cc}"

    %w[benchmark cli server check-dump check-aof].each { |p| bin.install src/"redis-#{p}" }
    %w[run db/redis log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end

    etc.install "redis.conf" unless (etc/"redis.conf").exist?
  end

  plist_options :manual => "redis-server #{HOMEBREW_PREFIX}/etc/redis.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/redis-server</string>
          <string>#{etc}/redis.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/redis.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/redis.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/redis-server", "--version"
  end
end
