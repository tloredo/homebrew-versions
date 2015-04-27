class Nettle3 < Formula
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "http://ftpmirror.gnu.org/nettle/nettle-3.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/nettle/nettle-3.1.tar.gz"
  sha256 "f6859d4ec88e70805590af9862b4b8c43a2d1fc7991df0a7a711b1e7ca9fc9d3"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "e50d9eab1bbc727db7176ce14e64583e10305edf29f58478f44e81e67129f6fb" => :yosemite
    sha256 "793f30f7cb3773776ad460a6cb65c63828d2030ebc6b09596f93c6925c22e95a" => :mavericks
    sha256 "24923b41a6bd4a1c126dbc5ff2d202e7a49ff79d360654691b40503be06e5886" => :mountain_lion
  end

  depends_on "gmp"

  keg_only "Conflicts with nettle in main repository and is not API compatible."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    system "make", "check"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected = /91b7b0b1e27bfbf7 bc646946f35fa972 c47c2d32/

    assert_match expected, shell_output("#{bin}/nettle-hash --a sha1 testfile.txt")
  end
end
