require 'formula'

class Llvm35 < Formula
  homepage  'http://llvm.org/'

  stable do
    url 'http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz'
    sha1 '58d817ac2ff573386941e7735d30702fe71267d5'

    resource 'clang' do
      url 'http://llvm.org/releases/3.5.0/cfe-3.5.0.src.tar.xz'
      sha1 '834cee2ed8dc6638a486d8d886b6dce3db675ffa'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/releases/3.5.0/clang-tools-extra-3.5.0.src.tar.xz'
      sha1 '74a84493e3313c180490a4affbb92d61ee4f0d21'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/releases/3.5.0/compiler-rt-3.5.0.src.tar.xz'
      sha1 '61f3e78088ce4a0787835036f2d3c61ede11e928'
    end

    resource 'polly' do
      url 'http://llvm.org/releases/3.5.0/polly-3.5.0.src.tar.xz'
      sha1 '74a2c80f12dc2645e4e77d330c8b7e0f53a5709c'
    end

    resource 'lld' do
      url 'http://llvm.org/releases/3.5.0/lld-3.5.0.src.tar.xz'
      sha1 '13c88e1442b482b3ffaff5934f0a2b51cab067e5'
    end

    resource 'libcxx' do
      url 'http://llvm.org/releases/3.5.0/libcxx-3.5.0.src.tar.xz'
      sha1 'c98beed86ae1adf9ab7132aeae8fd3b0893ea995'
    end

    resource 'libcxxabi' do
      url 'http://llvm.org/releases/3.5.0/libcxxabi-3.5.0.src.tar.xz'
      sha1 '31ffde04899449ae754a39c3b4e331a73a51a831'
    end if MacOS.version <= :snow_leopard
  end

  head do
    url 'http://llvm.org/git/llvm.git'

    resource 'clang' do
      url 'http://llvm.org/git/clang.git', :branch => 'release_35'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/git/clang-tools-extra.git', :branch => 'release_35'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/git/compiler-rt.git', :branch => 'release_35'
    end

    resource 'polly' do
      url 'http://llvm.org/git/polly.git', :branch => 'release_35'
    end

    resource 'lld' do
      url 'http://llvm.org/git/lld.git'
    end

    resource 'libcxx' do
      url 'http://llvm.org/git/libcxx.git', :branch => 'release_35'
    end

    resource 'libcxxabi' do
      url 'http://llvm.org/git/libcxxabi.git'
    end if MacOS.version <= :snow_leopard
  end

  resource 'isl' do
    url 'http://isl.gforge.inria.fr/isl-0.13.tar.bz2'
    sha1 '3904274c84fb3068e4f59b6a6b0fe29e7a2b7010'
  end

  resource 'cloog' do
    url 'http://repo.or.cz/w/cloog.git/snapshot/22643c94eba7b010ae4401c347289f4f52b9cd2b.tar.gz'
    sha1 '5409629e2fbe38035e8071c81601317a1a699309'
  end

  option :universal
  option 'with-libcxx', 'Build libc++ standard library support'
  option 'with-clang', 'Build Clang C/ObjC/C++ frontend'
  option 'with-lld', 'Build LLD linker'
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'rtti', 'Build with C++ RTTI'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  # required to build cloog
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build
  depends_on "pkg-config" => :build

  depends_on :python => :recommended
  depends_on 'gmp'
  depends_on 'libffi' => :recommended

  def ver; '3.5'; end # version suffix

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    if build.with? "python" and build.include? 'disable-shared'
      raise 'The Python bindings need the shared library.'
    end

    if build.with? 'libcxx' and build.without? 'clang'
      raise '"--with-libcxx" requires "--with-clang".'
    end

    if build.with? 'libcxx' and not build.include? 'rtti'
      raise '"--with-libcxx" requires "rtti".'
    end

    polly_buildpath = buildpath/'tools/polly'
    clang_buildpath = buildpath/'tools/clang'
    clang_tools_extra_buildpath = buildpath/'tools/clang/tools/extra'
    lld_buildpath = buildpath/'tools/lld'
    compiler_rt_buildpath = buildpath/'projects/compiler-rt'
    libcxx_buildpath = buildpath/'projects/libcxx'
    libcxxabi_buildpath = buildpath/'libcxxabi' # build failure if put in projects due to no Makefile

    polly_buildpath.install resource('polly')
    clang_buildpath.install resource('clang') if build.with? 'clang'
    clang_tools_extra_buildpath.install resource('clang-tools-extra') if build.with? 'clang'
    lld_buildpath.install resource('lld') if build.with? 'lld'
    compiler_rt_buildpath.install resource('compiler-rt') if build.with? 'asan'
    libcxx_buildpath.install resource('libcxx') if build.with? 'libcxx'

    # On Snow Leopard and below libc++abi is not shipped but needed for libc++.
    libcxxabi_buildpath.install resource('libcxxabi') if MacOS.version <= :snow_leopard and build.with? 'libcxx'

    if build.universal?
      ENV.permit_arch_flags
      ENV['UNIVERSAL'] = '1'
      ENV['UNIVERSAL_ARCH'] = Hardware::CPU.universal_archs.join(' ')
    end

    ENV['REQUIRES_RTTI'] = '1' if build.include? 'rtti'

    install_prefix = lib/"llvm-#{ver}"

    gmp_prefix = Formula["gmp"].opt_prefix
    isl_prefix = install_prefix/'libexec/isl'
    cloog_prefix = install_prefix/'libexec/cloog'

    resource('isl').stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{isl_prefix}",
                            "--with-gmp=system",
                            "--with-gmp-prefix=#{gmp_prefix}"
      system "make"
      system "make", "install"
    end

    resource('cloog').stage do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{cloog_prefix}",
                            "--with-gmp-prefix=#{gmp_prefix}",
                            "--with-isl-prefix=#{isl_prefix}"
      system "make"
      system "make", "install"
    end

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      # As of LLVM 3.1, attempting to build ocaml bindings with Homebrew's
      # OCaml 3.12.1 results in errors.
      "--disable-bindings",
      "--with-gmp=#{gmp_prefix}",
      "--with-isl=#{isl_prefix}",
      "--with-cloog=#{cloog_prefix}"
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

    # Snow Leopard is not shipped with libc++abi. Manually build here.
    cd libcxxabi_buildpath/'lib' do
      # Set rpath to save user from setting DYLD_LIBRARY_PATH
      inreplace libcxxabi_buildpath/'lib/buildit', '-install_name /usr/lib/libc++abi.dylib', "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

      ENV['CC'] = "#{install_prefix}/bin/clang"
      ENV['CXX'] = "#{install_prefix}/bin/clang++"
      ENV['TRIPLE'] = "*-apple-*"
      system "./buildit"
      # Install libs.
      (install_prefix/'usr/lib/').install libcxxabi_buildpath/'lib/libc++abi.dylib'
      # Install headers.
      cp libcxxabi_buildpath/'include/cxxabi.h', install_prefix/'lib/c++/v1/'
    end if MacOS.version <= :snow_leopard and build.with? 'libcxx'

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    cd libcxx_buildpath do
      if MacOS.version <= :snow_leopard
        # Snow Leopard make rules hardcode libc++ and libc++abi path.
        # Change to Cellar path here.
        inreplace libcxx_buildpath/'lib/buildit', '-install_name /usr/lib/libc++.1.dylib', "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        inreplace libcxx_buildpath/'lib/buildit', '-Wl,-reexport_library,/usr/lib/libc++abi.dylib', "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

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

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/'include/cxxabi.h', libcxx_buildpath/'include' if MacOS.version <= :snow_leopard

      system 'make', 'install', *libcxx_make_args
    end if build.with? 'libcxx'

    # Install Clang tools
    (share/"clang-#{ver}/tools").install buildpath/'tools/clang/tools/scan-build', buildpath/'tools/clang/tools/scan-view' if build.with? 'clang'

    if build.with? "python"
      # Install llvm python bindings.
      mv buildpath/'bindings/python/llvm', buildpath/"bindings/python/llvm-#{ver}"
      (lib+'python2.7/site-packages').install buildpath/"bindings/python/llvm-#{ver}"
      # Install clang tools and bindings if requested.
      if build.with? 'clang'
        mv clang_buildpath/'bindings/python/clang', clang_buildpath/"bindings/python/clang-#{ver}"
        (lib+'python2.7/site-packages').install clang_buildpath/"bindings/python/clang-#{ver}"
      end
    end

    # Link executables to bin and add suffix to avoid conflicts
    Dir.glob(install_prefix/'bin/*') do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    # Also link man pages
    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  test do
    system "#{bin}/llvm-config-#{ver}", "--version"
  end

  def caveats
    s = ''

    if build.with? 'clang'
      s += "Extra tools are installed in #{HOMEBREW_PREFIX/"share/clang-#{ver}"}."
    end

    if build.with? 'libcxx'
      include_path = HOMEBREW_PREFIX/"lib/llvm-#{ver}/include/c++/v1"
      libs_path = HOMEBREW_PREFIX/"lib/llvm-#{ver}/usr/lib"
      s += <<-EOS.undent

      To link to libc++ built here, please adjust your environment as follow:

        CXX="clang++-#{ver} -stdlib=libc++"
        CXXFLAGS="${CXXFLAGS} -nostdinc++ -I#{include_path}"
        LDFLAGS="${LDFLAGS} -L#{libs_path}"
      EOS
    end
    s
  end
end
