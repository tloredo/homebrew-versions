class LibmongoclientLegacy < Formula
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.0.3.tar.gz"
  sha256 "9d1da2d5bc258ceb5f6a58cd5a8893aabdec768e7771ede270a36fbf4b4491d2"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "098e1f54a5ff0eefaa2f80bdb1c37792c9bfdebf49fc55f439a37143b6fa84bc" => :yosemite
    sha256 "016a9dff9e4f0d12919eb135976eba568d890476e9cfc53f95039e3e467df49f" => :mavericks
    sha256 "89f5e5dd0504b75c5d454536b0d604704c262e5791b0cc160e6a366eebcda827" => :mountain_lion
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
