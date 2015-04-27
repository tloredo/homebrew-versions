class Node08 < Formula
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v0.8.26/node-v0.8.26.tar.gz"
  sha256 "d873216685774b96139af534ce015077d2c93ddfc4e3596e128853f3c08a5413"
  revision 3

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    revision 1
    sha256 "3185286b196a5f105d7db714b52b710e9da274ffaf66525841a950d1be82d2b6" => :yosemite
    sha256 "f48b1c0bab13cb6df95193b68fe1d3ded6b1324e7518d637d8548b482bd989ca" => :mavericks
    sha256 "4861bd949ae6e4dca014fdf7931accd36b8557de61f1f49fc72fb5b4ceb0ba82" => :mountain_lion
  end

  option "with-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "with-system-zlib", "Use the system zlib rather than the bundled"

  deprecated_option "enable-debug" => "with-debug"

  depends_on :python => :build
  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on "v8" => :optional

  fails_with :llvm do
    build 2326
  end

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-2.8.3.tgz"
    sha256 "81089fbb9f71286d2fd41423fbb171a92a126709d6a4b5d7c5ae02475a393838"
  end

  # Fixes double-free issue. See https://github.com/joyent/node/issues/6427
  # Should be fixed if they ever do a v0.8 release.
  patch :DATA

  conflicts_with "node",
    :because => "Differing versions of the same formulae."

  def install
    # Lie to `xcode-select` for now to work around a GYP bug that affects
    # CLT-only systems:
    #
    #   https://code.google.com/p/gyp/issues/detail?id=292
    #   joyent/node#3681
    ENV["DEVELOPER_DIR"] = MacOS.dev_tools_path unless MacOS::Xcode.installed?

    args = %W[--prefix=#{prefix} --without-npm --shared-openssl]

    args << "--shared-v8" if build.with? "v8"
    args << "--shared-zlib" if build.with? "system-zlib"
    args << "--debug" if build.with? "debug"

    system "./configure", *args
    system "make", "install"

    if build.with? "npm"
      resource("npm").stage buildpath/"npm_install"

      # make sure npm can find node
      ENV.prepend_path "PATH", bin
      # make sure user prefix settings in $HOME are ignored
      ENV["HOME"] = buildpath/"home"
      # set log level temporarily for npm's `make install`
      ENV["NPM_CONFIG_LOGLEVEL"] = "verbose"

      cd buildpath/"npm_install" do
        system "./configure", "--prefix=#{libexec}/npm"
        system "make", "install"
      end
    end
  end

  def post_install
    return if build.without? "npm"

    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    npm_exec = node_modules/"npm/bin/npm-cli.js"
    # Kill npm but preserve all other modules across node updates/upgrades.
    rm_rf node_modules/"npm"

    cp_r libexec/"npm/lib/node_modules/npm", node_modules
    # This symlink doesn't hop into homebrew_prefix/bin automatically so
    # remove it and make our own. This is a small consequence of our bottle
    # npm make install workaround. All other installs **do** symlink to
    # homebrew_prefix/bin correctly. We ln rather than cp this because doing
    # so mimics npm's normal install.
    ln_sf npm_exec, "#{HOMEBREW_PREFIX}/bin/npm"

    # Let's do the manpage dance. It's just a jump to the left.
    # And then a step to the right, with your hand on rm_f.
    ["man1", "man3", "man5", "man7"].each do |man|
      # Dirs must exist first: https://github.com/Homebrew/homebrew/issues/35969
      mkdir_p HOMEBREW_PREFIX/"share/man/#{man}"
      rm_f Dir[HOMEBREW_PREFIX/"share/man/#{man}/{npm.,npm-,npmrc.}*"]
      ln_sf Dir[libexec/"npm/share/man/#{man}/npm*"], HOMEBREW_PREFIX/"share/man/#{man}"
    end

    npm_root = node_modules/"npm"
    npmrc = npm_root/"npmrc"
    npmrc.atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  def caveats
    s = ""

    if build.with? "npm"
      s += <<-EOS.undent
        If you update npm itself, do NOT use the npm update command.
        The upstream-recommended way to update npm is:
          npm install -g npm@latest
      EOS
    else
      s += <<-EOS.undent
        Homebrew has NOT installed npm. If you later install it, you should supplement
        your NODE_PATH with the npm module folder:
          #{HOMEBREW_PREFIX}/lib/node_modules
      EOS
    end

    s
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/node #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus

    if build.with? "npm"
      # make sure npm can find node
      ENV.prepend_path "PATH", opt_bin
      assert_equal which("node"), opt_bin/"node"
      assert (HOMEBREW_PREFIX/"bin/npm").exist?, "npm must exist"
      assert (HOMEBREW_PREFIX/"bin/npm").executable?, "npm must be executable"
      system "#{HOMEBREW_PREFIX}/bin/npm", "--verbose", "install", "npm@latest"
    end
  end
end

__END__
diff --git a/deps/v8/src/spaces.h b/deps/v8/src/spaces.h
index b0ecc5d..d76d77d 100644
--- a/deps/v8/src/spaces.h
+++ b/deps/v8/src/spaces.h
@@ -321,7 +321,8 @@ class MemoryChunk {
   Space* owner() const {
     if ((reinterpret_cast<intptr_t>(owner_) & kFailureTagMask) ==
         kFailureTag) {
-      return reinterpret_cast<Space*>(owner_ - kFailureTag);
+      return reinterpret_cast<Space*>(reinterpret_cast<intptr_t>(owner_) -
+                                      kFailureTag);
     } else {
       return NULL;
     }
