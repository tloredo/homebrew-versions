# Note that x.even are stable releases, x.odd are devel releases
class Node010 < Formula
  desc "Platform built on V8 to build network applications"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v0.10.38/node-v0.10.38.tar.gz"
  sha256 "513da8ed5e48abefdfab664f1cabc160238d314a0481148804aff8fc6552b78b"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "387704ec2651265b0d4bec275088c5de23bc68b54cf349f66547a7c2cb07700c" => :yosemite
    sha256 "68faff9a680c58ff74b164e07c7f8881da8a18cab8dcace6faa866d22b11e057" => :mavericks
    sha256 "134a8943abf80ff7549595a47444c82155fe8af3f6c97177332f06b68bf90250" => :mountain_lion
  end

  deprecated_option "enable-debug" => "with-debug"

  option "with-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "without-completion", "npm bash completion will not be installed"

  depends_on :python => :build
  depends_on "openssl" => :optional

  fails_with :llvm do
    build 2326
  end

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-2.11.0.tgz"
    sha256 "c35f1b89705d63e76c8548647b0fa016e0bedee899a51ba93895db1d5eda940b"
  end

  conflicts_with "node",
    :because => "Differing versions of the same formulae."

  def install
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"

    if build.with? "openssl"
      args << "--shared-openssl"
    else
      args << "--without-ssl2" << "--without-ssl3"
    end

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

      if build.with? "completion"
        bash_completion.install \
          buildpath/"npm_install/lib/utils/completion.sh" => "npm"
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
