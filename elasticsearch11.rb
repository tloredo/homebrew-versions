require "formula"

class Elasticsearch11 < Formula
  homepage "https://www.elastic.co/products/elasticsearch"
  url "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.1.2.tar.gz"
  sha256 "adcea279ff2ffbe270ae86c6b563641afa93f1f5bf2ffe33e7a7c8ac2baf9527"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "53a4ed703c6c2aa968391e30a47de3c6e17cb80cb876a923eef8ad9e8ff99142" => :yosemite
    sha256 "132f4430f98f131964f209892783990f78f191f8c09289d0c6f32a7613391e65" => :mavericks
    sha256 "cc98f4d4cf3cbe3850db595e7456f4f13b04463936e6ee5054a991b1553326b3" => :mountain_lion
  end

  def cluster_name
    "elasticsearch_#{ENV['USER']}"
  end

  def install
    # Remove Windows files
    rm_f Dir["bin/*.bat"]

    # Move libraries to `libexec` directory
    libexec.install Dir['lib/*.jar']
    (libexec/'sigar').install Dir['lib/sigar/*.{jar,dylib}']

    # Install everything else into package directory
    prefix.install Dir['*']

    # Remove unnecessary files
    rm_f Dir["#{lib}/sigar/*"]

    # Set up Elasticsearch for local development:
    inreplace "#{prefix}/config/elasticsearch.yml" do |s|
      # 1. Give the cluster a unique name
      s.gsub! /#\s*cluster\.name\: elasticsearch/, "cluster.name: #{cluster_name}"

      # 2. Configure paths
      s.sub! "# path.data: /path/to/data", "path.data: #{var}/elasticsearch/"
      s.sub! "# path.logs: /path/to/logs", "path.logs: #{var}/log/elasticsearch/"
      s.sub! "# path.plugins: /path/to/plugins", "path.plugins: #{var}/lib/elasticsearch/plugins"

      # 3. Bind to loopback IP for laptops roaming different networks
      s.gsub! /#\s*network\.host\: [^\n]+/, "network.host: 127.0.0.1"
    end

    inreplace "#{bin}/elasticsearch.in.sh" do |s|
      # Configure ES_HOME
      s.sub!  /#\!\/bin\/sh\n/, "#!/bin/sh\n\nES_HOME=#{prefix}"
      # Configure ES_CLASSPATH paths to use libexec instead of lib
      s.gsub! /ES_HOME\/lib\//, "ES_HOME/libexec/"
    end

    inreplace "#{bin}/plugin" do |s|
      # Add the proper ES_CLASSPATH configuration
      s.sub!  /SCRIPT="\$0"/, %Q|SCRIPT="$0"\nES_CLASSPATH=#{libexec}|
      # Replace paths to use libexec instead of lib
      s.gsub! /\$ES_HOME\/lib\//, "$ES_CLASSPATH/"
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

  plist_options :manual => "elasticsearch --config=#{HOMEBREW_PREFIX}/opt/elasticsearch11/config/elasticsearch.yml"

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
            <string>#{opt_bin}/elasticsearch</string>
            <string>--config=#{opt_prefix}/config/elasticsearch.yml</string>
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
end
