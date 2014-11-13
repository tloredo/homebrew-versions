require "formula"

class Play22 < Formula
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/2.2.5/play-2.2.5.zip"
  sha1 "e4358fbf77e81de83bd2abbddf14af10d3cff15b"

  conflicts_with "sox", :because => "both install `play` binaries"

  def install
    rm_rf Dir["**/*.bat"]
    libexec.install Dir["*"]
    bin.install_symlink libexec/"play"
  end
end
