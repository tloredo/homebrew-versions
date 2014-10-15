require 'formula'

class Openssl098 < Formula
  homepage 'https://www.openssl.org'
  url 'https://www.openssl.org/source/openssl-0.9.8zb.tar.gz'
  sha256 '950e2298237de1697168debd42860bf41ead618e0c03dc9a3a56e23258e435be'

  keg_only :provided_by_osx

  def install
    args = %W[./Configure
               --prefix=#{prefix}
               --openssldir=#{etc}/openssl
               no-ssl2
               zlib-dynamic
               shared
             ]

    if MacOS.prefer_64_bit?
      args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
    else
      args << "darwin-i386-cc"
    end

    system "perl", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end
end
