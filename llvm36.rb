class Llvm36 < Formula
  homepage "http://llvm.org/"

  stable do
    url "http://llvm.org/releases/3.6.0/llvm-3.6.0.src.tar.xz"
    sha256 "b39a69e501b49e8f73ff75c9ad72313681ee58d6f430bfad4d81846fe92eb9ce"

    resource "clang" do
      url "http://llvm.org/releases/3.6.0/cfe-3.6.0.src.tar.xz"
      sha256 "be0e69378119fe26f0f2f74cffe82b7c26da840c9733fe522ed3c1b66b11082d"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/releases/3.6.0/clang-tools-extra-3.6.0.src.tar.xz"
      sha256 "3aa949ba82913490a75697287d9ee8598c619fae0aa6bb8fddf0095ff51bc812"
    end

    resource "compiler-rt" do
      url "http://llvm.org/releases/3.6.0/compiler-rt-3.6.0.src.tar.xz"
      sha256 "7f49fb79e5adcdce7dddaf973f1db130228dfb19e37a99a7f5365a6948b26b11"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.6.0/polly-3.6.0.src.tar.xz"
      sha256 "b6926fb0a63a497ecf8a229cd8630fe1c981e020728454d343a8f0d8a60c92f3"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.6.0/lld-3.6.0.src.tar.xz"
      sha256 "fb6f787188485b1fac17b73eed9db1dbc0481d6d1fbc273ea1fcd51fdb49a230"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.6.0/lldb-3.6.0.src.tar.xz"
      sha256 "2b1ad1d42c4ea3fa2f9dd6db7c522d86e80891659b24dbb3d0d80386d8eaf0b2"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.6.0/libcxx-3.6.0.src.tar.xz"
      sha256 "299c1e82b0086a79c5c1aa1885ea3be3bbce6979aaa9b886409b14f9b387fbb7"
    end

    resource "libcxxabi" do
      url "http://llvm.org/releases/3.6.0/libcxxabi-3.6.0.src.tar.xz"
      sha256 "f78bcfdb8015272f28d70f5546a544b5bdae5d92862711e8ecb9b24387d994f5"
    end if MacOS.version <= :snow_leopard
  end

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    revision 2
    sha256 "7f43f41440ea8353a80bd0a3b0db1983d4f67e2eba7e082d50619225fee6fe54" => :yosemite
    sha256 "7cb21aa6e888579b429c649a4c4f554c20fe0c52250c2c147a060142b5a8f8be" => :mavericks
    sha256 "198d29b41465177a31cf4daffd8b37a3c94adf9bf7c8074f325ed8d9075c0d61" => :mountain_lion
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_36"

    resource "clang" do
      url "http://llvm.org/git/clang.git", :branch => "release_36"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/git/clang-tools-extra.git", :branch => "release_36"
    end

    resource "compiler-rt" do
      url "http://llvm.org/git/compiler-rt.git", :branch => "release_36"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git", :branch => "release_36"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git", :branch => "release_36"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git", :branch => "release_36"
    end

    resource "libcxxabi" do
      url "http://llvm.org/git/libcxxabi.git", :branch => "release_36"
    end if MacOS.version <= :snow_leopard
  end

  resource "isl" do
    url "http://isl.gforge.inria.fr/isl-0.14.1.tar.gz"
    sha256 "bd15d06d050a92a6720fc7e2a58022a3fd1a73c4996cc358ba50864fd5e86c35"
  end

  patch :DATA

  option :universal
  option "with-lld", "Build LLD linker"
  option "with-lldb", "Build LLDB debugger"
  option "with-asan", "Include support for -faddress-sanitizer (from compiler-rt)"
  option "with-all-targets", "Build all target backends"
  option "with-python", "Build lldb bindings against the python in PATH instead of system Python"
  option "without-shared", "Don't build LLVM as a shared library"
  option "without-assertions", "Speeds up LLVM, but provides less debug information"

  # required to build isl
  depends_on "libtool"  => :build
  depends_on "pkg-config" => :build

  depends_on "gmp"
  depends_on "libffi" => :recommended

  depends_on "swig" if build.with? "lldb"
  depends_on :python => :optional

  # version suffix
  def ver
    "3.6"
  end

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    clang_buildpath = buildpath/"tools/clang"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"tools/lld").install resource("lld") if build.with? "lld"
    (buildpath/"tools/lldb").install resource("lldb") if build.with? "lldb"
    (buildpath/"projects/compiler-rt").install resource("compiler-rt") if build.with? "asan"

    if build.universal?
      ENV.permit_arch_flags
      ENV["UNIVERSAL"] = "1"
      ENV["UNIVERSAL_ARCH"] = Hardware::CPU.universal_archs.join(" ")
    end

    ENV["REQUIRES_RTTI"] = "1"

    install_prefix = lib/"llvm-#{ver}"

    gmp_prefix = Formula["gmp"].opt_prefix
    isl_prefix = install_prefix/"libexec/isl"

    resource("isl").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{isl_prefix}",
                            "--with-gmp=system",
                            "--with-gmp-prefix=#{gmp_prefix}"
      system "make"
      system "make", "install"
    end

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--disable-bindings",
      "--with-gmp=#{gmp_prefix}",
      "--with-isl=#{isl_prefix}",
    ]

    if build.with? "all-targets"
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end

    args << "--enable-shared" if build.with? "shared"

    args << "--disable-assertions" if build.without? "assertions"

    args << "--enable-libffi" if build.with? "libffi"

    system "./configure", *args
    system "make", "VERBOSE=1"
    system "make", "VERBOSE=1", "install"

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/"lib" do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV["CC"] = "#{install_prefix}/bin/clang"
        ENV["CXX"] = "#{install_prefix}/bin/clang++"
        ENV["TRIPLE"] = "*-apple-*"
        system "./buildit"
        (install_prefix/"usr/lib").install "libc++abi.dylib"
        cp libcxxabi_buildpath/"include/cxxabi.h", install_prefix/"lib/c++/v1"
      end

      # Snow Leopard make rules hardcode libc++ and libc++abi path.
      # Change to Cellar path here.
      inreplace "#{libcxx_buildpath}/lib/buildit" do |s|
        s.gsub! "-install_name /usr/lib/libc++.1.dylib", "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        s.gsub! "-Wl,-reexport_library,/usr/lib/libc++abi.dylib", "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/"include/cxxabi.h", libcxx_buildpath/"include"
    end

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    libcxx_make_args = [
      # Use the built clang for building
      "CC=#{install_prefix}/bin/clang",
      "CXX=#{install_prefix}/bin/clang++",
      # Properly set deployment target, which is needed for Snow Leopard
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      # The following flags are needed so it can be installed correctly.
      "DSTROOT=#{install_prefix}",
      "SYMROOT=#{libcxx_buildpath}",
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang-#{ver}/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    inreplace share/"clang-#{ver}/tools/scan-build/scan-build", "$RealBin/bin/clang", install_prefix/"bin/clang"
    ln_s share/"clang-#{ver}/tools/scan-build/scan-build", install_prefix/"bin"
    ln_s share/"clang-#{ver}/tools/scan-view/scan-view", install_prefix/"bin"
    (install_prefix/"share/man/man1").install share/"clang-#{ver}/tools/scan-build/scan-build.1"

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
                                            clang_buildpath/"bindings/python/clang" => "clang-#{ver}"
    (lib/"python2.7/site-packages").install_symlink install_prefix/"lib/python2.7/site-packages/lldb" => "lldb-#{ver}" if build.with? "lldb"

    Dir.glob(install_prefix/"bin/*") do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/"share/man/man1/*") do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  test do
    system "#{bin}/llvm-config-#{ver}", "--version"
  end

  def caveats; <<-EOS.undent
    Extra tools are installed in #{opt_share}/clang-#{ver}

    To link to libc++, something like the following is required:
      CXX="clang++-#{ver} -stdlib=libc++"
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/include/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end
end

__END__
diff --git a/Makefile.rules b/Makefile.rules
index ebebc0a..b0bb378 100644
--- a/Makefile.rules
+++ b/Makefile.rules
@@ -599,7 +599,12 @@ ifneq ($(HOST_OS), $(filter $(HOST_OS), Cygwin MingW))
 ifneq ($(HOST_OS),Darwin)
   LD.Flags += $(RPATH) -Wl,'$$ORIGIN'
 else
-  LD.Flags += -Wl,-install_name  -Wl,"@rpath/lib$(LIBRARYNAME)$(SHLIBEXT)"
+  LD.Flags += -Wl,-install_name
+  ifdef LOADABLE_MODULE
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(LIBRARYNAME)$(SHLIBEXT)"
+  else
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)"
+  endif
 endif
 endif
 endif
