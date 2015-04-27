class Openssl098 < Formula
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8zf.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/OpenSSL/openssl-0.9.8zf.tar.gz"
  sha256 "d5245a29128984192acc5b1fc01e37429b7a01c53cadcb2645e546718b300edb"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "4ab0ca109e4064418e0f710ba0e4aa287ab27794fac44957620d491bc61046e1" => :yosemite
    sha256 "481cf9dfb006915bace31fdc82535e1a31da1f174743ce0050e14d3e604d3d73" => :mavericks
    sha256 "bc8c827e07112a0146350a47b4d8928a51200aed39bd9880bba2ddb4b53c0b63" => :mountain_lion
  end

  keg_only :provided_by_osx

  def install
    args = %W[
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

    system "perl", "./Configure", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", "dgst", "-sha1", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
