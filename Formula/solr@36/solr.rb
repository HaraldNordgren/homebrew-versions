require 'formula'

class Solr < Formula
  version "36"
  homepage 'http://lucene.apache.org/solr/'
  url 'http://apache.mirrors.tds.net/lucene/solr/3.6.2'
  sha1 'ed246c505ef8674c7b4ed9af52616ebd8b9e41d8'

  def script; <<-EOS.undent
    #!/bin/sh
    if [ -z "$1" ]; then
      echo "Usage: $ solr path/to/config/dir"
    else
      cd #{libexec}/example && java -Dsolr.solr.home=$1 -jar start.jar
    fi
    EOS
  end

  def install
    libexec.install Dir['*']
    (bin+'solr').write script
  end

  def caveats; <<-EOS.undent
    To start solr:
      solr path/to/solr/config/dir

    See the solr homepage for more setup information:
      brew home solr
    EOS
  end
end
