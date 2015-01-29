require 'formula'

class ErlangR13 < Formula
  homepage 'http://www.erlang.org'
  # Download from GitHub. Much faster than official tarball.
  url "https://github.com/erlang/otp.git", :tag => "OTP_R13B04"
  version 'R13B04'

  option 'disable-hipe', 'Disable building hipe; fails on various OS X systems'

  fails_with :llvm do
    build 2326
    cause "See http://github.com/mxcl/homebrew/issues/issue/120"
  end

  resource 'man' do
    url 'http://www.erlang.org/download/otp_doc_man_R13B04.tar.gz'
    sha1 '660e52302d270138f8e9f2f2b6a562026998012c'
  end

  def install
    ENV.deparallelize

    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-smp-support"]

    unless build.include? 'disable-hipe'
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << '--enable-hipe'
    end

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?

    system "./configure", *args
    touch  "lib/wx/SKIP" if MacOS.version >= :snow_leopard
    system "make"
    system "make install"

    resource("man").stage { man.install Dir["man/*"] }
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
