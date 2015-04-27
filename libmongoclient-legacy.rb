class LibmongoclientLegacy < Formula
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.1.tar.gz"
  sha256 "29ffbf3674192e1cb47af7ad620b9b0c1e60716033c6c342a3f935f3ce79c59e"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "b6224d2274abc491d9d7a2e300e2c537baa46c18e8c5b2223a6fb80ada7bcc3e" => :yosemite
    sha256 "0ffb747ad72a01f2e99bb6c305e4394a87fe64800c8287fca1ee36de13ec6ab7" => :mavericks
    sha256 "45832154ceff0acbbd3b31834fe7734d87b937815ae478534d9049e19668c931" => :mountain_lion
  end

  conflicts_with "libmongoclient", :because => "libmongoclient contains 26compat branch"

  option :cxx11

  depends_on "scons" => :build

  if build.cxx11?
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  def install
    ENV.cxx11 if build.cxx11?

    boost = Formula["boost"].opt_prefix

    args = [
      "--prefix=#{prefix}",
      "-j#{ENV.make_jobs}",
      "--cc=#{ENV.cc}",
      "--cxx=#{ENV.cxx}",
      "--extrapath=#{boost}",
      "--sharedclient",
      # --osx-version-min is required to override --osx-version-min=10.6 added
      # by SConstruct which causes "invalid deployment target for -stdlib=libc++"
      # when using libc++
      "--osx-version-min=#{MacOS.version}",
      "install",
    ]

    args << "--libc++" if MacOS.version >= :mavericks

    scons *args
  end
end
