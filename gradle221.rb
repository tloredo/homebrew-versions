class Gradle221 < Formula
  homepage "http://www.gradle.org/"
  url "https://services.gradle.org/distributions/gradle-2.2.1-bin.zip"
  sha256 "420aa50738299327b611c10b8304b749e8d3a579407ee9e755b15921d95ff418"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end
end
