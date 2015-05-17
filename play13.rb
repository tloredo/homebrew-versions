class Play13 < Formula
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.3.1/play-1.3.1.zip"
  sha256 "9dae87f659cca29cd0144ef58491b714072ccb786eef4ccfa7741da1a2301ec0"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "341d8fb3a7d0ff51913fe9524c585560342e2705b7b291c25493125836da6890" => :yosemite
    sha256 "e745f863eac2cf9de688c5a832f9d7cd6d07fcbc67147c9135ecbd41b6276e2d" => :mavericks
    sha256 "d255f3f91e8394d3f71e275b92099c8d7c0e72554af4a2aacd4138d5aa5128fb" => :mountain_lion
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
