# 2.2 (build 961) introduces support for documenting enumerated and
# bitmask types, and will emit warnings on encountering undocumented
# instances of those types.  An archived release is provided as a stable
# dependency for e.g. continuous integration environments.
class Appledoc22 < Formula
  homepage "http://appledoc.gentlebytes.com/"
  url "https://github.com/tomaz/appledoc/archive/2.2.1.tar.gz"
  sha1 "a25d9ce876c4f7ee88d82b4532956d2c94b5d2e9"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    revision 1
    sha1 "e21eff6c8e1d59dda1aaaf4e052b46342c046a11" => :yosemite
    sha1 "1e21c233ab7e4ec4783f32d08b22553fa82baddf" => :mavericks
    sha1 "5f2f551c1ac6c2dd86ba9a9f98806262513849da" => :mountain_lion
  end

  keg_only :provided_by_osx, <<-EOS.undent
   The executable installed by this formula may be invoked explicitly,
   or (if it is the only version installed) linked after it is installed.
  EOS

  depends_on :xcode
  depends_on :macos => :lion

  # Actually works with pre-503 clang, but we don't have a way to
  # express this yet.
  # It's actually possible to build with GC disabled, but not advisable.
  # See: https://github.com/tomaz/appledoc/issues/439
  fails_with :clang do
    cause <<-EOS.undent
      clang 5.1 (build 503) removed support for Objective C GC
      which appledoc 2.2 requires to build.
    EOS
  end

  def install
    xcodebuild "-project", "appledoc.xcodeproj",
               "-target", "appledoc",
               "-configuration", "Release",
               "clean", "install",
               "SYMROOT=build",
               "DSTROOT=build",
               "INSTALL_PATH=/bin",
               "OTHER_CFLAGS='-DCOMPILE_TIME_DEFAULT_TEMPLATE_PATH=@\"#{prefix}/Templates\"'"
    bin.install "build/bin/appledoc"
    prefix.install "Templates/"
  end

  test do
    system "#{bin}/appledoc", "--version"
  end
end
