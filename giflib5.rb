class Giflib5 < Formula
  homepage "http://giflib.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.0.5.tar.bz2"
  sha256 "606d8a366b1c625ab60d62faeca807a799a2b9e88cbdf2a02bfcdf4429bf8609"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "6ed13aadad66c923b480c7c2298fd7d1857dc58c260f972fb9e28aa45e08869d" => :yosemite
    sha256 "04858ea96297f92679f93c92a37e6081b059ac0bdfce34c9eb99a4c823d746d5" => :mavericks
    sha256 "d03bd0eeedfc5036fdb396478d63396b2d032dec2fd38c6ff4d4b0d636f4f5d8" => :mountain_lion
  end

  keg_only "Conflicts with giflib in main repository."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
