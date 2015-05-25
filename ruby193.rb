class Ruby193 < Formula
  homepage "https://www.ruby-lang.org/en/"
  url "http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p551.tar.bz2"
  sha256 "b0c5e37e3431d58613a160504b39542ec687d473de1d4da983dabcf3c5de771e"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "331f6f131245fbd345a409ed4eddd92600465678a0b053b59b58d7beb9ea7139" => :yosemite
    sha256 "9f766d333e06d6c92eb40b4370a02fb0c54e29cff51adb4338050dc667a6c14d" => :mavericks
    sha256 "1b1df99ceae1a5c4b779bf6975c63d9f36620040a7703e7f6bb769a249cc508a" => :mountain_lion
  end

  option :universal
  option "with-suffix", "Suffix commands with '193'"
  option "with-doc", "Install documentation"
  option "with-tcltk", "Install with Tcl/Tk support"

  depends_on "pkg-config" => :build
  depends_on "readline"
  depends_on "gdbm"
  depends_on "libyaml"
  depends_on "openssl"
  depends_on :x11 if build.with? "tcltk"

  fails_with :llvm do
    build 2326
  end

  def install
    args = ["--prefix=#{prefix}", "--enable-shared"]

    paths = [
      Formula["libyaml"].opt_prefix,
      Formula["openssl"].opt_prefix
    ]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=193" if build.with? "suffix"
    args << "--disable-tcltk-framework" <<  "--with-out-ext=tcl" <<  "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--with-opt-dir=#{paths.join(":")}"

    system "./configure", *args
    system "make"
    system "make", "install"
    system "make", "install-doc" if build.with? "doc"
  end

  def post_install
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
  end

  def abi_version
    "1.9.1"
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
        "#{opt_bin}/ruby#{"193" if build.with? "suffix"}"
      end
    end
    EOS
  end

  test do
    output = `#{bin}/ruby -e "puts 'hello'"`
    assert_equal "hello\n", output
    assert_equal 0, $?.exitstatus
  end
end
