require "language/haskell"

class PandocCiteproc05 < Formula
  include Language::Haskell::Cabal

  homepage "https://github.com/jgm/pandoc-citeproc"
  url "https://hackage.haskell.org/package/pandoc-citeproc-0.5/pandoc-citeproc-0.5.tar.gz"
  sha256 "83ff6d75cdf4a92d4f7fb4b7c70adcf53b30dd82831d38ad4dcb7640e9855f01"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "2bc9ccd580914bf0ab0c18489dc63d5eba688a602944c3861cea44175edd6377" => :yosemite
    sha256 "83d61ef94c02566e3d4c9441f513de774ce37221831821b579b2f1aff7efaa36" => :mavericks
    sha256 "ffdfdc0c3e02ecaa438cc4bec0c55de520dfc00bae50bda07c1a12f58bbc880f" => :mountain_lion
  end

  keg_only "Conflicts with pandoc-citeproc in main repository."

  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "gmp"
  depends_on "pandoc1131" => :recommended

  fails_with(:clang) { build 425 } # clang segfaults on Lion

  def install
    cabal_sandbox do
      cabal_install "--only-dependencies"
      cabal_install "--prefix=#{prefix}"
    end
    cabal_clean_lib
  end

  test do
    bib = testpath/"test.bib"
    bib.write <<-EOS.undent
      @Book{item1,
      author="John Doe",
      title="First Book",
      year="2005",
      address="Cambridge",
      publisher="Cambridge University Press"
      }
    EOS
    assert `#{bin}/pandoc-citeproc --bib2yaml #{bib}`.include? "- publisher-place: Cambridge"
  end
end
