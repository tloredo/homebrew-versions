require "formula"

class Gradle20 < Formula
  homepage "http://www.gradle.org/"
  url "http://services.gradle.org/distributions/gradle-2.0-bin.zip"
  sha1 "171d2290257c061a96410297f2596596862a847a"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
