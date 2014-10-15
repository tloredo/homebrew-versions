require 'formula'

class Allegro5 < Formula
  homepage 'http://www.allegro.cc'
  url 'https://downloads.sourceforge.net/project/alleg/allegro/5.0.10/allegro-5.0.10.tar.gz'
  sha1 'f2b4535ac6fc6810f915dd7e75b27f967161726f'

  head 'git://git.code.sf.net/p/alleg/allegro', :branch => '5.1'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional
  depends_on 'freetype' => :optional
  depends_on 'flac' => :optional
  depends_on 'libpng' => :optional
  depends_on 'jpeg' => :optional
  depends_on 'physfs' => :optional

  def install
    args = std_cmake_args + ["-DWANT_DOCS=OFF"]
    system "cmake", ".", *args
    system "make install"
  end

  test do
    (testpath/'allegro_test.cpp').write <<-EOS
    #include <assert.h>
    #include <allegro5/allegro5.h>

    int main(int n, char** c) {
      if (!al_init()) {
        return 1;
      }
      return 0;
    }
    EOS

    system ENV.cxx, "-I#{include}", "-L#{lib}", "-lallegro", "-lallegro_main", "-o", "allegro_test", "allegro_test.cpp"
    system "./allegro_test"
  end
end
