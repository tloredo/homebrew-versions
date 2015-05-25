class Ruby187 < Formula
  homepage "https://www.ruby-lang.org/en/"
  url "http://cache.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p374.tar.bz2"
  sha256 "b4e34703137f7bfb8761c4ea474f7438d6ccf440b3d35f39cc5e4d4e239c07e3"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "9169de1b6e0b913d950a0e25640d65cc707355b660f2742b8fbfa0b4001a83cc" => :yosemite
    sha256 "cc65723819e16bb61dfcac8f09cee14e559b9ed69d8461e040d65a47697ff00f" => :mavericks
    sha256 "62e380e8125f84e1e0978d44a50025c285d3a308d91ae3f1be36551ab0ec1c56" => :mountain_lion
  end

  # Otherwise it fails when building bigdecimal by trying to load
  # files from the system ruby instead of the one it's building
  env :std

  keg_only :provided_by_osx

  option :universal
  option "with-suffix", "Suffix commands with '187'"
  option "with-doc", "Install documentation"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "gdbm" => :optional
  depends_on "libyaml"
  depends_on "openssl" if MacOS.version >= :mountain_lion
  depends_on :x11

  fails_with :llvm do
    build 2326
  end

  def install
    args = %W[--prefix=#{prefix} --enable-shared]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=187" if build.with? "suffix"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    # OpenSSL is deprecated on OS X 10.8 and Ruby can't find the outdated
    # version (0.9.8r 8 Feb 2011) that ships with the system.
    # See discussion https://github.com/sstephenson/ruby-build/issues/304
    # and https://github.com/homebrew/homebrew/pull/18054
    if MacOS.version >= :mountain_lion
      args << "--with-openssl-dir=#{Formula["openssl"].opt_prefix}"
    end

    # Put gem, site and vendor folders in the HOMEBREW_PREFIX
    ruby_lib = HOMEBREW_PREFIX/"lib/ruby"
    (ruby_lib/"site_ruby").mkpath
    (ruby_lib/"vendor_ruby").mkpath
    (ruby_lib/"gems").mkpath

    (lib/"ruby").install_symlink ruby_lib/"site_ruby",
                                 ruby_lib/"vendor_ruby",
                                 ruby_lib/"gems"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end

  test do
    output = `#{bin}/ruby -e "puts 'hello'"`
    assert_equal "hello\n", output
    assert_equal 0, $?.exitstatus
  end
end
