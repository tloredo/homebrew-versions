class Gmp4 < Formula
  homepage 'http://gmplib.org/'
  # Track gcc infrastructure releases.
  url 'http://ftpmirror.gnu.org/gmp/gmp-4.3.2.tar.bz2'
  mirror 'https://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2'
  mirror 'ftp://ftp.gmplib.org/pub/gmp-4.3.2/gmp-4.3.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-4.3.2.tar.bz2'
  sha1 'c011e8feaf1bb89158bd55eaabd7ef8fdd101a2c'

  bottle do
    sha1 'ac18cca84840aac6d004d829bc1cea398ec09487' => :tiger_g3
    sha1 '33780b658a5f64d220fb64c07d4f6e859ddd94c5' => :tiger_altivec
    sha1 '71bf67992e28a0b48606db40df70f22d3414c5fd' => :leopard_g3
    sha1 '480b7c3848b069e0da3bb33331beacf9122baec3' => :leopard_altivec
  end

  keg_only "Conflicts with gmp in main repository."

  option '32-bit'
  option 'skip-check', 'Do not run `make check` to verify libraries'

  fails_with :gcc_4_0 do
    cause "Reports of problems using gcc 4.0 on Leopard: https://github.com/mxcl/homebrew/issues/issue/2302"
  end

  # Patches gmp.h to remove the __need_size_t define, which
  # was preventing libc++ builds from getting the ptrdiff_t type
  # Applied upstream in http://gmplib.org:8000/gmp/raw-rev/6cd3658f5621
  patch :DATA

  def install
    args = ["--prefix=#{prefix}", "--enable-cxx"]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    if MacOS.prefer_64_bit? and not build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--host=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Doesn't install in parallel on 8-core Mac Pro
    system "make install"

    # Different compilers and options can cause tests to fail even
    # if everything compiles, so yes, we want to do this step.
    system "make check" unless build.include? "skip-check"
  end
end

__END__
diff --git a/gmp-h.in b/gmp-h.in
index d7fbc34..3c57c48 100644
--- a/gmp-h.in
+++ b/gmp-h.in
@@ -46,13 +46,11 @@ along with the GNU MP Library.  If not, see http://www.gnu.org/licenses/.  */
 #ifndef __GNU_MP__
 #define __GNU_MP__ 4
 
-#define __need_size_t  /* tell gcc stddef.h we only want size_t */
 #if defined (__cplusplus)
 #include <cstddef>     /* for size_t */
 #else
 #include <stddef.h>    /* for size_t */
 #endif
-#undef __need_size_t
 
 /* Instantiated by configure. */
 #if ! defined (__GMP_WITHIN_CONFIGURE)
