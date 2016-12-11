class Play < Formula
  version "13"
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.3.1/play-1.3.1.zip"
  sha256 "9dae87f659cca29cd0144ef58491b714072ccb786eef4ccfa7741da1a2301ec0"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "3b174ced1581252cef59d525bd62e892a0a67ba9" => :yosemite
    sha1 "5e13564741cabb45f709a4d59dbd1452a9808767" => :mavericks
    sha1 "260e3924f28c9f7df7b54a7e90d4a03a764691e7" => :mountain_lion
  end

  conflicts_with "sox", :because => "Both install a `play` executable"
  conflicts_with "play12", :because => "Both install a `play` executable"
  conflicts_with "play22", :because => "Both install a `play` executable"

  def install
    rm_rf "python" # we don't need the bundled Python for windows
    rm Dir["*.bat"]
    libexec.install Dir["*"]
    chmod 0755, libexec/"play"
    bin.install_symlink libexec/"play"
  end

  test do
    require "open3"
    Open3.popen3("#{bin}/play new #{testpath}/app") do |stdin, _, _|
      stdin.write "\n"
      stdin.close
    end
    %W[app conf lib public test].each do |d|
      File.directory? testpath/"app/#{d}"
    end
  end
end
