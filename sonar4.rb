class Sonar4 < Formula
  homepage "http://www.sonarqube.org/"
  url "http://dist.sonar.codehaus.org/sonarqube-4.5.4.zip"
  sha1 "755d93b58d8fe88f4e7e99eb11930254128bc5c1"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "e2107c08b2317a7bb0623c2362e09e1e67e42501" => :yosemite
    sha1 "9b645db49f27913c9edd85e1772e9fab85210986" => :mavericks
    sha1 "b1072a188f79703046a120ae35bc0534c5b9f2c6" => :mountain_lion
  end

  def install
    # Delete native bin directories for other systems
    rm_rf Dir["bin/{aix,hpux,linux,solaris,windows}-*"]

    if MacOS.prefer_64_bit?
      rm_rf "bin/macosx-universal-32"
    else
      rm_rf "bin/macosx-universal-64"
    end

    # Delete Windows files
    rm_f Dir["war/*.bat"]
    libexec.install Dir["*"]

    if MacOS.prefer_64_bit?
      bin.install_symlink "#{libexec}/bin/macosx-universal-64/sonar.sh" => "sonar"
    else
      bin.install_symlink "#{libexec}/bin/macosx-universal-32/sonar.sh" => "sonar"
    end
  end

  plist_options :manual => "sonar console"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
        <string>#{opt_bin}/sonar</string>
        <string>start</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match /SonarQube/, pipe_output("#{bin}/sonar status")
  end
end
