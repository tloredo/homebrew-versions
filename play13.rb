class Play13 < Formula
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.3.0/play-1.3.0.zip"
  sha1 "0637fc40bc98675f56d3f408e73be6e6c067c789"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "3b174ced1581252cef59d525bd62e892a0a67ba9" => :yosemite
    sha1 "5e13564741cabb45f709a4d59dbd1452a9808767" => :mavericks
    sha1 "260e3924f28c9f7df7b54a7e90d4a03a764691e7" => :mountain_lion
  end

  def install
    rm_rf "python" # we don't need the bundled Python for windows
    rm Dir["*.bat"]
    libexec.install Dir["*"]
    bin.mkpath
    chmod 0755, libexec+"play"
    ln_s libexec+"play", bin
  end
end
