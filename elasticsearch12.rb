class Elasticsearch12 < Formula
  homepage "https://www.elastic.co/products/elasticsearch"
  url "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.2.4.tar.gz"
  sha256 "07c298cb4dae634a2514f6022cd28533be0d86e3a2d0ad75ee6f24ff49b2e22f"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    revision 1
    sha256 "ac1cb4d7b023d175ba2b28a7564375f4170bc723bdd9edc00f6e49092ffdd2c0" => :yosemite
    sha256 "62e62ad012f3689c02d226d70ba5ea440a9832909abcd148cea17ba47fdfb9d7" => :mavericks
    sha256 "e7ae3287bd80f05f3fb9cc655e8762e10a20225b90aba1717a046579e09c29e7" => :mountain_lion
  end

  depends_on :java => "1.7+"

  def cluster_name
    "elasticsearch_#{ENV["USER"]}"
  end

  def install
    # Remove Windows files
    rm_f Dir["bin/*.bat"]
    rm_f Dir["bin/*.exe"]

    # Move libraries to `libexec` directory
    libexec.install Dir["lib/*.jar"]
    (libexec/"sigar").install Dir["lib/sigar/*.{jar,dylib}"]

    # Install everything else into package directory
    prefix.install Dir["*"]

    # Remove unnecessary files
    rm_f Dir["#{lib}/sigar/*"]

    # Set up Elasticsearch for local development:
    inreplace "#{prefix}/config/elasticsearch.yml" do |s|
      # 1. Give the cluster a unique name
      s.gsub! /#\s*cluster\.name\: elasticsearch/, "cluster.name: #{cluster_name}"

      # 2. Configure paths
      s.sub!(%r{#\s*path\.data: /path/to.+$}, "path.data: #{var}/elasticsearch/")
      s.sub!(%r{#\s*path\.logs: /path/to.+$}, "path.logs: #{var}/log/elasticsearch/")
      s.sub!(%r{#\s*path\.plugins: /path/to.+$}, "path.plugins: #{var}/lib/elasticsearch/plugins")

      # 3. Bind to loopback IP for laptops roaming different networks
      s.gsub! /#\s*network\.host\: [^\n]+/, "network.host: 127.0.0.1"
    end

    inreplace "#{bin}/elasticsearch.in.sh" do |s|
      # Configure ES_HOME
      s.sub!(%r{#\!/bin/sh\n}, "#!/bin/sh\n\nES_HOME=#{prefix}")
      # Configure ES_CLASSPATH paths to use libexec instead of lib
      s.gsub!(%r{ES_HOME/lib/}, "ES_HOME/libexec/")
    end

    inreplace "#{bin}/plugin" do |s|
      # Add the proper ES_CLASSPATH configuration
      s.sub!(/SCRIPT="\$0"/, %(SCRIPT="$0"\nES_CLASSPATH=#{libexec}))
      # Replace paths to use libexec instead of lib
      s.gsub!(%r{\$ES_HOME/lib/}, "$ES_CLASSPATH/")
    end
  end

  def post_install
    # Make sure runtime directories exist
    (var/"elasticsearch/#{cluster_name}").mkpath
    (var/"log/elasticsearch").mkpath
    (var/"lib/elasticsearch/plugins").mkpath
  end

  def caveats; <<-EOS.undent
    Data:    #{var}/elasticsearch/#{cluster_name}/
    Logs:    #{var}/log/elasticsearch/#{cluster_name}.log
    Plugins: #{var}/lib/elasticsearch/plugins/
    EOS
  end

  plist_options :manual => "elasticsearch --config=#{HOMEBREW_PREFIX}/opt/elasticsearch12/config/elasticsearch.yml"

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
            <string>#{HOMEBREW_PREFIX}/bin/elasticsearch</string>
            <string>--config=#{prefix}/config/elasticsearch.yml</string>
          </array>
          <key>EnvironmentVariables</key>
          <dict>
            <key>ES_JAVA_OPTS</key>
            <string>-Xss200000</string>
          </dict>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>/dev/null</string>
          <key>StandardOutPath</key>
          <string>/dev/null</string>
        </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/plugin", "--list"
  end
end
