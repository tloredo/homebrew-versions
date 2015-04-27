class Phantomjs198 < Formula
  homepage "http://www.phantomjs.org/"
  url "https://github.com/ariya/phantomjs/archive/1.9.8.tar.gz"
  sha256 "3a321561677f678ca00137c47689e3379c7fe6b83f7597d2d5de187dd243f7be"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha1 "ad447564de81f1499795a6c8e2dd7b5db474f2dc" => :yosemite
    sha1 "ec47fc927a5ed38bb2c5802f661c635f6c15324d" => :mavericks
    sha1 "54348237528d076e12ffcc7ffb286fb0b5e02b61" => :mountain_lion
  end

  depends_on "openssl"

  def install
    if MacOS.prefer_64_bit?
      inreplace "src/qt/preconfig.sh", "-arch x86", "-arch x86_64"
    end
    system "./build.sh", "--confirm", "--jobs", ENV.make_jobs,
      "--qt-config", "-openssl-linked"
    bin.install "bin/phantomjs"
    (share+"phantomjs").install "examples"
  end

  test do
    path = testpath/"test.js"
    path.write <<-EOS
      console.log("hello");
      phantom.exit();
    EOS

    assert_equal "hello", shell_output("#{bin}/phantomjs #{path}").strip
  end
end
