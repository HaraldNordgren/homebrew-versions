class Play < Formula
  version "12"
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.2.7.2/play-1.2.7.2.zip"
  sha256 "4fc610e2db0993fee3daf01527ba5ca57a9ad970c429733415ee59b55064b322"

  conflicts_with "sox", :because => "Both install a `play` executable"

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
