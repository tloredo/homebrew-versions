class Solr14 < Formula
  homepage "http://lucene.apache.org/solr/"
  url "https://archive.apache.org/dist/lucene/solr/1.4.1/apache-solr-1.4.1.tgz"
  sha256 "d795bc477335b3e29bab7073b385c93fca4be867aae345203da0d1e438d7543f"

  depends_on :java

  def script; <<-EOS.undent
    #!/bin/sh
    if [ -z "$1" ]; then
      echo "Usage: $ solr14 path/to/config/dir"
    else
      cd #{libexec}/example && java -Dsolr.solr.home=$1 -jar start.jar
    fi
    EOS
  end

  def install
    libexec.install Dir["*"]
    (bin+"solr14").write script
  end

  def caveats; <<-EOS.undent
    To start solr:
        solr path/to/solr/config/dir

    See the solr homepage for more setup information:
        brew home solr
    EOS
  end

  test do
    system "solr14"
  end
end
