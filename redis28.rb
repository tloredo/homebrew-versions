class Redis28 < Formula
  homepage "http://redis.io/"
  url "http://download.redis.io/releases/redis-2.8.19.tar.gz"
  sha256 "29bb08abfc3d392b2f0c3e7f48ec46dd09ab1023f9a5575fc2a93546f4ca5145"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    revision 1
    sha256 "a90c9ca0f3fda1a9e5af1fd629baff997e65017249dbdcf638bbc7dba0a1dda0" => :yosemite
    sha256 "4dbf3bfba912367c8a19709949059c3e3e8f3a128adbc0e2564bdb9bbd61a2f1" => :mavericks
    sha256 "df55c0092bf5f29f0e7395b4e4cb4090ddebcae2c1beb40fca26b9a7a80c34a2" => :mountain_lion
  end

  fails_with :llvm do
    build 2334
    cause "Fails with 'reference out of range from _linenoise'"
  end

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = MacOS.prefer_64_bit? ? "-arch x86_64" : "-arch i386"

    # Head and stable have different code layouts
    src = (buildpath/"src/Makefile").exist? ? buildpath/"src" : buildpath
    system "make", "-C", src, "CC=#{ENV.cc}"

    %w[benchmark cli server check-dump check-aof sentinel].each { |p| bin.install src/"redis-#{p}" => "redis28-#{p}" }
    %w[run db/redis28 log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis-2.8.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis28/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end

    etc.install "redis.conf" => "redis28.conf" unless (etc/"redis28.conf").exist?
    etc.install "sentinel.conf" => "redis28-sentinel.conf" unless (etc/"redis28-sentinel.conf").exist?
  end

  plist_options :manual => "redis28-server #{HOMEBREW_PREFIX}/etc/redis28.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/redis28-server</string>
          <string>#{etc}/redis28.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/redis28.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/redis28.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    # This previously wasn't bottled. Make sure it is.
    assert File.exist?(HOMEBREW_PREFIX/"etc/redis28.conf")

    system "#{bin}/redis28-server", "--version"
  end
end
