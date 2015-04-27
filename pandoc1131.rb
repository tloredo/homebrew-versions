require "language/haskell"

class Pandoc1131 < Formula
  include Language::Haskell::Cabal

  homepage "http://johnmacfarlane.net/pandoc/"
  url "https://hackage.haskell.org/package/pandoc-1.13.1/pandoc-1.13.1.tar.gz"
  sha256 "7b1bb9b7d66edfbac33796a3f5d3218c2add786b95ea9dfbd497dc0e8ed27e6f"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "51316e68de6eebd7890e6d97ffc10f429b6bf1ac88a4347949a90da00f4114a5" => :yosemite
    sha256 "2a4f1c8dc251f6188413668f1c4a0f4fffc4fa4ee75555ce4c1405f7128ff351" => :mavericks
    sha256 "0befd5bd233a1a2755c3c2348b2a82234fcbbaa2f10222788fd9bd98f5a2f0d3" => :mountain_lion
  end

  keg_only "Conflicts with pandoc in main repository."

  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "gmp"

  fails_with(:clang) { build 425 } # clang segfaults on Lion

  def install
    cabal_sandbox do
      cabal_install "--only-dependencies"
      cabal_install "--prefix=#{prefix}"
    end
    cabal_clean_lib
  end

  test do
    system bin/"pandoc", "-o", "output.html", prefix/"README"
    assert (Pathname.pwd/"output.html").read.include? '<h1 id="synopsis">Synopsis</h1>'
  end
end
