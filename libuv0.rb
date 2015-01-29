class Libuv0 < Formula
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v0.10.32.tar.gz"
  sha1 "9f06392ebcbfd25e029d700c869ade8581ec2895"
  head "https://github.com/libuv/libuv.git", :branch => "v0.10"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    cellar :any
    sha1 "772fe584a53138a540ceefb469592c2c5279035e" => :yosemite
    sha1 "fd8edf4c95c801eb474566ca7980c759929f4a64" => :mavericks
    sha1 "89bab70004d9e2458c2664caaaadcd49163839e2" => :mountain_lion
  end

  conflicts_with "libuv"

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "make", "libuv.dylib"
    prefix.install "include"
    lib.install "libuv.dylib"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <uv.h>

      int main()
      {
        uv_loop_t* loop = uv_loop_new();
        uv_loop_delete(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-luv", "-o", "test"
    system "./test"
  end
end
