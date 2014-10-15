require "formula"

class ErlangR16 < Formula
  homepage "http://www.erlang.org"
  url "http://www.erlang.org/download/otp_src_R16B03-1.tar.gz"
  sha1 "c2634ea0c078500f1c6a1369f4be59a6d14673e0"
  revision 1

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl"
  depends_on "unixodbc" if MacOS.version >= :mavericks
  depends_on "fop" => :optional # enables building PDF docs
  depends_on "wxmac" => :recommended # for GUI apps like observer

  fails_with :llvm

  option 'disable-hipe', "Disable building hipe; fails on various OS X systems"
  option 'halfword', 'Enable halfword emulator (64-bit builds only)'
  option 'no-docs', 'Do not install documentation'

  resource 'man' do
    url 'http://erlang.org/download/otp_doc_man_R16B03-1.tar.gz'
    sha1 'afde5507a389734adadcd4807595f8bc76ebde1b'
  end

  resource 'html' do
    url 'http://erlang.org/download/otp_doc_html_R16B03-1.tar.gz'
    sha1 'a2c0d2b7b9abe6214aff4c75ecc6be62042924e6'
  end

  def install
    ohai "Compilation takes a long time; use `brew install -v erlang-r16` to see progress" unless ARGV.verbose?

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-shared-zlib",
            "--enable-smp-support"]

    args << "--with-dynamic-trace=dtrace" unless MacOS.version == :leopard or not MacOS::CLT.installed?

    unless build.include? 'disable-hipe'
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << '--enable-hipe'
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.include? 'halfword' # Does not work with HIPE yet. Added for testing only
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Install is not thread-safe; can try to create folder twice and fail
    system "make install"

    unless build.include? 'no-docs'
      resource("man").stage { man.install Dir["man/*"] }
      resource("html").stage { doc.install Dir["*"] }
    end
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
