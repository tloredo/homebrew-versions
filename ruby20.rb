class Ruby20 < Formula
  homepage "https://www.ruby-lang.org/"
  url "http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p645.tar.bz2"
  sha256 "2dcdcf9900cb923a16d3662d067bc8c801997ac3e4a774775e387e883b3683e9"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "e9b01603d66cc5553ca7f9d3594fc0ce6d186aea4c85aaa1af1c241404452e39" => :yosemite
    sha256 "0e79ce291d4f661d7872f7deb1d809a419a7c6599483a422bc7787049f0cebb0" => :mavericks
    sha256 "6840f190b6a853a2fa885f24cf60b203424aa2a7eb887ab5f051848f072de30e" => :mountain_lion
  end

  option :universal
  option "with-suffix", "Suffix commands with '20'"
  option "with-doc", "Install documentation"
  option "with-tcltk", "Install with Tcl/Tk support"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "gdbm" => :optional
  depends_on "libffi" => :optional
  depends_on "libyaml"
  depends_on "openssl"
  depends_on :x11 if build.with? "tcltk"

  fails_with :llvm do
    build 2326
  end

  def install
    args = %W[--prefix=#{prefix} --enable-shared]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=20" if build.with? "suffix"
    args << "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    paths = []

    paths.concat %w[readline gdbm libffi].map { |dep|
      Formula[dep].opt_prefix if build.with? dep
    }.compact

    paths.concat %w[libyaml openssl].map { |dep|
      Formula[dep].opt_prefix
    }

    args << "--with-opt-dir=#{paths.join(":")}"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def post_install
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
  end

  def abi_version
    "2.0.0"
  end

  def rubygems_config; <<-EOS.undent
    module Gem
      class << self
        alias :old_default_dir :default_dir
        alias :old_default_path :default_path
        alias :old_default_bindir :default_bindir
        alias :old_ruby :ruby
      end

      def self.default_dir
        path = [
          "#{HOMEBREW_PREFIX}",
          "lib",
          "ruby",
          "gems",
          "#{abi_version}"
        ]

        @default_dir ||= File.join(*path)
      end

      def self.private_dir
        path = if defined? RUBY_FRAMEWORK_VERSION then
                 [
                   File.dirname(RbConfig::CONFIG['sitedir']),
                   'Gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               elsif RbConfig::CONFIG['rubylibprefix'] then
                 [
                  RbConfig::CONFIG['rubylibprefix'],
                  'gems',
                  RbConfig::CONFIG['ruby_version']
                 ]
               else
                 [
                   RbConfig::CONFIG['libdir'],
                   ruby_engine,
                   'gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               end

        @private_dir ||= File.join(*path)
      end

      def self.default_path
        if Gem.user_home && File.exist?(Gem.user_home)
          [user_dir, default_dir, private_dir]
        else
          [default_dir, private_dir]
        end
      end

      def self.default_bindir
        "#{HOMEBREW_PREFIX}/bin"
      end

      def self.ruby
        "#{opt_bin}/ruby#{"20" if build.with? "suffix"}"
      end
    end
    EOS
  end

  test do
    system bin/"ruby", "--version"
  end
end
