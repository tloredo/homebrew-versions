# This formula tracks GnuTLS stable-next. This is currently the 3.4.x branch.
class Gnutls34 < Formula
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.1.tar.xz"
  mirror "http://mirrors.dotsrc.org/gcrypt/gnutls/v3.4/gnutls-3.4.1.tar.xz"
  sha256 "e9b5f58becf34756464216056cd5abbf04315eda80a374d02699dee83f80b12e"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "15ede4ba5c02fa5dcc9e7edee0ce1df29dd5acd6d5ecc57ae0eea62ae1a692ac" => :yosemite
    sha256 "387b22e785931178c6c5cf979ef19708136ed6babcd6596fcc31a39abb68a4a5" => :mavericks
    sha256 "4c9792290c1b8f0ae3d39f3c8378844c8e0aa601d12dd536d4507cfe742fd0c9" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "libtasn1"
  depends_on "gmp"
  depends_on "nettle3"
  depends_on "guile" => :optional
  depends_on "unbound" => :optional
  depends_on "libidn" => :optional

  keg_only "Conflicts with GnuTLS in main repository and is not API compatible."

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-default-trust-store-file=#{etc}/openssl/cert.pem
      --disable-heartbeat-support
      --without-p11-kit
    ]

    if build.with? "guile"
      args << "--enable-guile"
      args << "--with-guile-site-dir=no"
    end

    system "./configure", *args
    system "make", "install"

    # certtool shadows the OS X certtool utility
    mv bin+"certtool", bin+"gnutls-certtool"
    mv man1+"certtool.1", man1+"gnutls-certtool.1"
  end

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    openssldir = etc/"openssl"
    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write `security find-certificate -a -p #{keychains.join(" ")}`
  end

  test do
    system bin/"gnutls-cli", "--version"
  end
end
