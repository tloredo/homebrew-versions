# The 0.9.0 tag in homebrew repository isn't working in OSX Mavericks
# this version fixes Cpp11 problems about syntax and tr1 headers
# All patches and this file can be found in this public gist:
# https://gist.githubusercontent.com/rafaelverger/58b6eeafaae7d28b06cc

class Thrift090 < Formula
  homepage "http://thrift.apache.org"
  url "https://archive.apache.org/dist/thrift/0.9.0/thrift-0.9.0.tar.gz"
  sha256 "71d129c49a2616069d9e7a93268cdba59518f77b3c41e763e09537cb3f3f0aac"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "dea7ccc0fb965a709abddfad87d5ecb886e0b5d2f4618622d320f259bccf7aed" => :yosemite
    sha256 "a9b9bf0bb4039b83d80b617d20f9a185b2f771c4e72284843c29253bd3fbbdcb" => :mavericks
    sha256 "9c83d58ec3c0b0dc1477dc5c3496ba793893441790e7827e5020a5e775e993d5" => :mountain_lion
  end

  # These patches are 0.9.0-specific and can go away once a newer version is release
  [
    # patch-tsocket.patch
    %w[ca4565122f0a1365f2409bce85dc0b8942459b18 a1dc9e54ffacf04c6ba6d1e37b734684ff09d149a88ca7425a4237267f674829],
    # patch-cxx11-compat.patch
    %w[8ab0d22b3df198e6b7a14e9da6fd34d2d6218cbf 74fd5282f159bf4d7ee5ca977b36534e2182709fe4c17cc5907c6bd615cfe0ef],
    # patch-use-boost-cpp-client-server.patch
    %w[50629b8ac1fb3d606185f39cfd7b6a4848e3a93d 2ea5a69c5358a56ef945d4fb127c11a7797afc751743b20f58dfff0955a68117],
    # patch-remove-tr1-dependency.patch
    %w[7bf1cd9deb7b483845458e901c37ad4d8404a8e7 c4419ce40b7fda9ffd58a5dad7856b64ee84e3c1b820f3a64fed0b01b4bc9c42],
  ].each do |hash, sha|
    patch do
      url "https://gist.githubusercontent.com/rafaelverger/58b6eeafaae7d28b06cc/raw/#{hash}"
      sha256 sha
    end
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "openssl"
  depends_on :python => :optional

  option "with-haskell", "Install Haskell binding"
  option "with-erlang", "Install Erlang binding"
  option "with-java", "Install Java binding"
  option "with-perl", "Install Perl binding"
  option "with-php", "Install Php binding"

  def install
    args = ["--without-ruby", "--without-tests", "--without-php_extension"]

    args << "--without-python" if build.without? "python"
    args << "--without-haskell" if build.without? "haskell"
    args << "--without-java" if build.without? "java"
    args << "--without-perl" if build.without? "perl"
    args << "--without-php" if build.without? "php"
    args << "--without-erlang" if build.without? "erlang"

    ENV.cxx11 if MacOS.version >= :mavericks && ENV.compiler == :clang

    # Don't install extensions to /usr:
    ENV["PY_PREFIX"] = prefix
    ENV["PHP_PREFIX"] = prefix

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          *args
    ENV.j1
    system "make", "install"
  end

  test do
    assert_match /Thrift/, shell_output("#{bin}/thrift --version", 1)
  end
end
