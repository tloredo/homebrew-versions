require "formula"

class Ledger26 < Formula
  homepage "http://ledger-cli.org"
  url "https://github.com/ledger/ledger/archive/v2.6.3.tar.gz"
  sha1 "b04a69f10de9970a15e4e85abd515457904fc5a4"

  depends_on "gettext"
  depends_on "pcre"
  depends_on "expat"
  depends_on "boost"
  depends_on "gmp"
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "libofx" => :optional
  depends_on :python => :optional

  option "debug", "Build with debugging symbols enabled"

  def install
    # find Homebrew"s libpcre
    ENV.append "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"

    args = []
    if build.with? "libofx"
      args << "--enable-ofx"
      # the libofx.h appears to have moved to a subdirectory
      ENV.append "CXXFLAGS", "-I#{Formula["libofx"].opt_include}/libofx"
    end
    args << "--enable-python" if build.with? "python"
    args << "--enable-debug" if build.include?("debug")
    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", *args
    system "make"
    ENV.deparallelize
    system "make install"
    (share+"ledger/examples").install "sample.dat", "scripts"
  end

  test do
    balance = testpath/"output"
    system bin/"ledger",
      "--file", share/"ledger/examples/sample.dat",
      "--output", balance,
      "balance", "--collapse", "equity"
    assert_equal "          $-2,500.00  Equity", balance.read.chomp
    assert_equal 0, $?.exitstatus

    if build.with? "python"
      system "python", "#{share}/ledger/demo.py"
    end
  end
end
