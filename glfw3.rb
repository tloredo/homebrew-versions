class Glfw3 < Formula
  homepage "http://www.glfw.org/"
  url "https://downloads.sourceforge.net/project/glfw/glfw/3.1.1/glfw-3.1.1.tar.bz2"
  sha256 "4a8516223c1df079efb398754f4533af7e943188ea9b5222e7f27c25e4822d61"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "039df5a5929bdbdc6b20cf5fb3fffcff4d7a6360e76a2878e43152d993e7566c" => :yosemite
    sha256 "0784107860072dc0cbfc61fcf8cdd84110cb3e37a0da1e2ff4a60e4e4bbf1c6b" => :mavericks
    sha256 "e75bdc4478ee0510be626b78ff1f0862de8ff9fea26d9b4432ce2b7967c9b80c" => :mountain_lion
  end

  depends_on "cmake" => :build

  option :universal
  option "without-shared-library", "Build static library only (defaults to building dylib only)"
  option "with-examples", "Build examples"
  option "with-tests", "Build test programs"

  deprecated_option "build-examples" => "with-examples"
  deprecated_option "static" => "without-shared-library"
  deprecated_option "build-tests" => "with-tests"

  # make library name consistent
  patch :DATA

  def install
    ENV.universal_binary if build.universal?

    args = std_cmake_args + %W[
      -DGLFW_USE_CHDIR=TRUE
      -DGLFW_USE_MENUBAR=TRUE
    ]
    args << "-DGLFW_BUILD_UNIVERSAL=TRUE" if build.universal?
    args << "-DBUILD_SHARED_LIBS=TRUE" if build.with? "shared-library"
    args << "-DGLFW_BUILD_EXAMPLES=TRUE" if build.with? "examples"
    args << "-DGLFW_BUILD_TESTS=TRUE" if build.with? "tests"
    args << "."

    system "cmake", *args
    system "make", "install"
    libexec.install Dir["tests/*"] if build.with? "tests"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #define GLFW_INCLUDE_GLU
      #include <GLFW/glfw3.h>
      #include <stdlib.h>
      int main()
      {
        if (!glfwInit())
          exit(EXIT_FAILURE);
        glfwTerminate();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lglfw3",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end

__END__
diff -u a/CMakeLists.txt b/CMakeLists.txt
index
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -357,12 +357,7 @@
 #--------------------------------------------------------------------
 # Choose library output name
 #--------------------------------------------------------------------
-if (BUILD_SHARED_LIBS AND UNIX)
-    # On Unix-like systems, shared libraries can use the soname system.
-    set(GLFW_LIB_NAME glfw)
-else()
-    set(GLFW_LIB_NAME glfw3)
-endif()
+set(GLFW_LIB_NAME glfw3)

 #--------------------------------------------------------------------
 # Add subdirectories
