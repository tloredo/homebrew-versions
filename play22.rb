require "formula"

class Play22 < Formula
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/2.2.4/play-2.2.4.zip"
  sha1 "b3eb067bfe96b4177028cb2660f7b17d5ea47bed"

  conflicts_with "sox", :because => "both install `play` binaries"

  def install
    rm_rf Dir["**/*.bat"]
    libexec.install Dir["*"]
    bin.install_symlink libexec/"play"
  end
end
