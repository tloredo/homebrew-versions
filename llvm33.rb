class Llvm33 < Formula
  homepage  'http://llvm.org/'
  revision 1

  stable do
    url 'http://llvm.org/releases/3.3/llvm-3.3.src.tar.gz'
    sha1 'c6c22d5593419e3cb47cbcf16d967640e5cce133'

    resource 'clang' do
      url 'http://llvm.org/releases/3.3/cfe-3.3.src.tar.gz'
      sha1 'ccd6dbf2cdb1189a028b70bcb8a22509c25c74c8'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/releases/3.3/clang-tools-extra-3.3.src.tar.gz'
      sha1 '6f7af9ba8014f7e286a02e4ae2e3f2017b8bfac2'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/releases/3.3/compiler-rt-3.3.src.tar.gz'
      sha1 '745386ec046e3e49742e1ecb6912c560ccd0a002'
    end

    resource 'polly' do
      url 'http://llvm.org/releases/3.3/polly-3.3.src.tar.gz'
      sha1 'eb75f5674fedf77425d16c9c0caec04961f03e04'
    end

    resource 'libcxx' do
      url 'http://llvm.org/releases/3.3/libcxx-3.3.src.tar.gz'
      sha1 '7bea00bc1031bf3bf6c248e57c1f4e0874c18c04'
    end
  end

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    revision 1
    sha1 "4a3c9ec6d02d95dffa1a045d0819a0d7926c4890" => :yosemite
    sha1 "21e88b1a11acd209be8fd26238312b727e69e061" => :mavericks
    sha1 "7c6d6545a0e634edc1650d259d4f44f25bdb157c" => :mountain_lion
  end

  head do
    url 'http://llvm.org/git/llvm.git', :branch => 'release_33'

    resource 'clang' do
      url 'http://llvm.org/git/clang.git', :branch => 'release_33'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/git/clang-tools-extra.git', :branch => 'release_33'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/git/compiler-rt.git', :branch => 'release_33'
    end

    resource 'polly' do
      url 'http://llvm.org/git/polly.git', :branch => 'release_33'
    end

    resource 'libcxx' do
      url 'http://llvm.org/git/libcxx.git', :branch => 'release_33'
    end
  end

  if MacOS.version <= :snow_leopard
    # Not tarball release for libc++abi yet. Using latest branch.
    resource 'libcxxabi' do
      url 'http://llvm.org/git/libcxxabi.git', :branch => 'release_32'
    end

    resource 'clang-unwind-patch' do
      url 'http://llvm.org/viewvc/llvm-project/cfe/trunk/lib/Headers/unwind.h?r1=172666&r2=189535&view=patch', :using => :nounzip
      sha1 'b40f6dba4928add36945c50e5b89ca0988147cd2'
    end
  end

  # Fix Makefile bug concerning MacOSX >= 10.10
  # See: http://llvm.org/bugs/show_bug.cgi?id=19951
  patch :DATA

  option :universal
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  depends_on 'gmp4'
  depends_on 'isl011'
  depends_on 'cloog018'
  depends_on 'libffi' => :recommended

  def ver; '3.3'; end # version suffix

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  def install
    clang_buildpath = buildpath/"tools/clang"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"projects/compiler-rt").install resource("compiler-rt") if build.with? "asan"

    if MacOS.version <= :snow_leopard
      buildpath.install resource('clang-unwind-patch')
      cd clang_buildpath do
        system "patch -p2 -N < #{buildpath}/unwind.h"
      end
    end

    if build.universal?
      ENV.permit_arch_flags
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = Hardware::CPU.universal_archs.join(' ')
    end

    ENV['REQUIRES_RTTI'] = '1'

    install_prefix = lib/"llvm-#{ver}"

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--disable-bindings",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-isl=#{Formula["isl011"].opt_prefix}",
      "--with-cloog=#{Formula["cloog018"].opt_prefix}"
    ]

    if build.include? 'all-targets'
      args << '--enable-targets=all'
    else
      args << '--enable-targets=host'
    end

    args << "--enable-shared" unless build.include? 'disable-shared'

    args << "--disable-assertions" if build.include? 'disable-assertions'

    args << "--enable-libffi" if build.with? 'libffi'

    system './configure', *args
    system 'make', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/'lib' do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV['CC'] = "#{install_prefix}/bin/clang"
        ENV['CXX'] = "#{install_prefix}/bin/clang++"
        ENV['TRIPLE'] = "*-apple-*"
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
      "SYMROOT=#{libcxx_buildpath}"
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang-#{ver}/tools").install Dir["tools/clang/tools/scan-{build,view}"]

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
      clang_buildpath/"bindings/python/clang" => "clang-#{ver}"

    Dir.glob(install_prefix/'bin/*') do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
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
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/lib/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end
end

__END__
diff --git a/Makefile.rules b/Makefile.rules
index f0c542b..f4da038 100644
--- a/Makefile.rules
+++ b/Makefile.rules
@@ -571,9 +571,9 @@ ifeq ($(HOST_OS),Darwin)
   DARWIN_VERSION := `sw_vers -productVersion`
  endif
   # Strip a number like 10.4.7 to 10.4
-  DARWIN_VERSION := $(shell echo $(DARWIN_VERSION)| sed -E 's/(10.[0-9]).*/\1/')
+  DARWIN_VERSION := $(shell echo $(DARWIN_VERSION)| sed -E 's/(10.[0-9]+).*/\1/')
   # Get "4" out of 10.4 for later pieces in the makefile.
-  DARWIN_MAJVERS := $(shell echo $(DARWIN_VERSION)| sed -E 's/10.([0-9]).*/\1/')
+  DARWIN_MAJVERS := $(shell echo $(DARWIN_VERSION)| sed -E 's/10.([0-9]+).*/\1/')
 
   LoadableModuleOptions := -Wl,-flat_namespace -Wl,-undefined,suppress
   SharedLinkOptions := -dynamiclib
@@ -602,6 +602,17 @@ ifdef SHARED_LIBRARY
 ifneq ($(HOST_OS), $(filter $(HOST_OS), Cygwin MingW))
 ifneq ($(HOST_OS),Darwin)
   LD.Flags += $(RPATH) -Wl,'$$ORIGIN'
+else
+  ifeq ($(DARWIN_MAJVERS),4)
+    LD.Flags += -Wl,-dylib_install_name
+  else
+    LD.Flags += -Wl,-install_name
+  endif
+  ifdef LOADABLE_MODULE
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(LIBRARYNAME)$(SHLIBEXT)"
+  else
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)"
+  endif
 endif
 endif
 endif
diff --git a/tools/llvm-shlib/Makefile b/tools/llvm-shlib/Makefile
index 6d6c6e9..c3d4d67 100644
--- a/tools/llvm-shlib/Makefile
+++ b/tools/llvm-shlib/Makefile
@@ -53,14 +53,6 @@ ifeq ($(HOST_OS),Darwin)
     LLVMLibsOptions    := $(LLVMLibsOptions)  \
                          -Wl,-dead_strip \
                          -Wl,-seg1addr -Wl,0xE0000000 
-
-    # Mac OS X 10.4 and earlier tools do not allow a second -install_name on command line
-    DARWIN_VERS := $(shell echo $(TARGET_TRIPLE) | sed 's/.*darwin\([0-9]*\).*/\1/')
-    ifneq ($(DARWIN_VERS),8)
-       LLVMLibsOptions    := $(LLVMLibsOptions)  \
-                            -Wl,-install_name \
-                            -Wl,"@executable_path/../lib/lib$(LIBRARYNAME)$(SHLIBEXT)"
-    endif
 endif
 
 ifeq ($(HOST_OS), $(filter $(HOST_OS), Linux FreeBSD OpenBSD GNU Bitrig))
diff --git a/tools/lto/Makefile b/tools/lto/Makefile
index ab2e16e..dd2e13a 100644
--- a/tools/lto/Makefile
+++ b/tools/lto/Makefile
@@ -42,14 +42,6 @@ ifeq ($(HOST_OS),Darwin)
                          -Wl,-dead_strip \
                          -Wl,-seg1addr -Wl,0xE0000000 
 
-    # Mac OS X 10.4 and earlier tools do not allow a second -install_name on command line
-    DARWIN_VERS := $(shell echo $(TARGET_TRIPLE) | sed 's/.*darwin\([0-9]*\).*/\1/')
-    ifneq ($(DARWIN_VERS),8)
-       LLVMLibsOptions    := $(LLVMLibsOptions)  \
-                            -Wl,-install_name \
-                            -Wl,"@executable_path/../lib/lib$(LIBRARYNAME)$(SHLIBEXT)"
-    endif
-
     # If we're doing an Apple-style build, add the LTO object path.
     ifeq ($(RC_XBS),YES)
        TempFile        := $(shell mkdir -p ${OBJROOT}/dSYMs ; mktemp ${OBJROOT}/dSYMs/llvm-lto.XXXXXX)
