require 'formula'

class Gcc46 < Formula
  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        'x86_64'
      else
        'i686'
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        'powerpc64'
      else
        'powerpc'
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  homepage 'http://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.6.4/gcc-4.6.4.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.6.4/gcc-4.6.4.tar.bz2'
  sha1 '63933a8a5cf725626585dbba993c8b0f6db1335d'

  option 'enable-fortran', 'Build the gfortran compiler'
  option 'enable-java', 'Build the gcj compiler'
  option 'enable-all-languages', 'Enable all compilers and languages, except Ada'
  option 'enable-nls', 'Build with native language support (localization)'
  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  # enabling multilib on a host that can't run 64-bit results in build failures
  option 'disable-multilib', 'Build without multilib support' if MacOS.prefer_64_bit?

  depends_on 'gmp4'
  depends_on 'libmpc08'
  depends_on 'mpfr2'
  depends_on 'ppl011'
  depends_on 'cloog-ppl015'
  depends_on 'ecj' if build.include? 'enable-java' or build.include? 'enable-all-languages'

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete 'LD'

    if build.include? 'enable-all-languages'
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap. GCC 4.6.0 add go as a language option, but it is
      # currently only compilable on Linux.
      languages = %w[c c++ fortran java objc obj-c++]
    else
      # C, C++, ObjC compilers are always built
      languages = %w[c c++ objc obj-c++]

      languages << 'fortran' if build.include? 'enable-fortran'
      languages << 'java' if build.include? 'enable-java'
    end

    version_suffix = version.to_s.slice(/\d\.\d/)

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(',')}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc08"].opt_prefix}",
      "--with-ppl=#{Formula["ppl011"].opt_prefix}",
      "--with-cloog=#{Formula["cloog-ppl015"].opt_prefix}",
      "--with-system-zlib",
      # This ensures lib, libexec, include are sandboxed so that they
      # don't wander around telling little children there is no Santa
      # Claus.
      "--enable-version-specific-runtime-libs",
      "--enable-libstdcxx-time=yes",
      "--enable-stage1-checking",
      "--enable-checking=release",
      "--enable-lto",
      # A no-op unless --HEAD is built because in head warnings will
      # raise errors. But still a good idea to include.
      "--disable-werror",
      "--with-pkgversion=Homebrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/Homebrew/homebrew-versions/issues",
    ]

    # "Building GCC with plugin support requires a host that supports
    # -fPIC, -shared, -ldl and -rdynamic."
    args << "--enable-plugin" if MacOS.version > :tiger

    # Otherwise make fails during comparison at stage 3
    # See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=45248
    args << '--with-dwarf2' if MacOS.version < :leopard

    args << '--disable-nls' unless build.include? 'enable-nls'

    if build.include? 'enable-java' or build.include? 'enable-all-languages'
      args << "--with-ecj-jar=#{Formula["ecj"].opt_prefix}/share/java/ecj.jar"
    end

    if !MacOS.prefer_64_bit? || build.include?('disable-multilib')
      args << '--disable-multilib'
    else
      args << '--enable-multilib'
    end

    mkdir 'build' do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # 'native-system-header's will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system '../configure', *args

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system 'make profiledbootstrap'
      else
        system 'make bootstrap'
      end

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu and autogen formulae must be installed in order to do this.

      system 'make install'
    end

    # Handle conflicts between GCC formulae.

    # Remove libffi stuff, which is not needed after GCC is built.
    Dir.glob(prefix/"**/libffi.*") { |file| File.delete file }

    # Rename libiberty.a.
    Dir.glob(prefix/"**/libiberty.*") { |file| add_suffix file, version_suffix }

    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. TODO fix this.
    info.rmtree

    # Rename java properties
    if build.include? 'enable-java' or build.include? 'enable-all-languages'
      config_files = [
        "#{lib}/logging.properties",
        "#{lib}/security/classpath.security",
        "#{lib}/i386/logging.properties",
        "#{lib}/i386/security/classpath.security"
      ]

      config_files.each do |file|
        add_suffix file, version_suffix if File.exist? file
      end
    end
  end

  def add_suffix file, suffix
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end
end
