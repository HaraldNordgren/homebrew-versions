require 'formula'

def build_gui?
  ARGV.include? '--with-gui'
end

class Postgis < Formula
  version "15"
  homepage 'http://postgis.refractions.net'
  url 'http://postgis.refractions.net/download/postgis-1.5.3.tar.gz'
  md5 '05a61df5e1b78bf51c9ce98bea5526fc'

  depends_on 'postgresql'
  depends_on 'proj'
  depends_on 'geos'

  depends_on 'gtk+' if build_gui?

  def options
    [
      ['--with-gui', 'Build shp2pgsql-gui in addition to command line tools']
    ]
  end

  # PostGIS command line tools intentionally have unused symbols in
  # them---these are callbacks for liblwgeom.
  skip_clean :all

  def install
    ENV.deparallelize
    postgresql = Formula.factory 'postgresql'

    args = [
      "--disable-dependency-tracking",
      # Can't use --prefix, PostGIS disrespects it and flat-out refuses to
      # accept it with the 2.0 beta.
      "--with-projdir=#{HOMEBREW_PREFIX}",
      # This is against Homebrew guidelines, but we have to do it as the
      # PostGIS plugin libraries can only be properly inserted into Homebrew's
      # Postgresql keg.
      "--with-pgconfig=#{postgresql.bin}/pg_config"
    ]
    args << '--with-gui' if build_gui?

    system './configure', *args
    system 'make'

    # __DON'T RUN MAKE INSTALL!__
    #
    # PostGIS includes the PGXS makefiles and so will install __everything__
    # into the Postgres keg instead of the PostGIS keg. Unfortunately, some
    # things have to be inside the Postgres keg in order to be function. So, we
    # install the bare minimum of stuff and then manually move everything else
    # to the prefix.

    # Install PostGIS plugin libraries into the Postgres keg so that they can
    # be loaded and so PostGIS databases will continue to function even if
    # PostGIS is removed.
    postgresql.lib.install Dir['postgis/postgis*.so']

    # Stand-alone SQL files will be installed the share folder
    postgis_sql = share + 'postgis'

    bin.install %w[
      loader/pgsql2shp
      loader/shp2pgsql
      utils/new_postgis_restore.pl
    ]
    bin.install 'loader/shp2pgsql-gui' if build_gui?

    # Install PostGIS 1.x upgrade scripts
    postgis_sql.install %w[
      postgis/postgis_upgrade_13_to_15.sql
      postgis/postgis_upgrade_14_to_15.sql
      postgis/postgis_upgrade_15_minor.sql
    ]

    # Common tools
    bin.install %w[
      utils/create_undef.pl
      utils/postgis_proc_upgrade.pl
      utils/postgis_restore.pl
      utils/profile_intersects.pl
      utils/test_estimation.pl
      utils/test_geography_estimation.pl
      utils/test_geography_joinestimation.pl
      utils/test_joinestimation.pl
    ]

    # Common SQL scripts
    postgis_sql.install %w[
      spatial_ref_sys.sql
      postgis/postgis.sql
      postgis/uninstall_postgis.sql
    ]
  end

  def caveats;
    postgresql = Formula.factory 'postgresql'

    <<-EOS.undent
      To create a spatially-enabled database, see the documentation:
        http://postgis.refractions.net/documentation/manual-1.5/ch02.html#id2630392
      and to upgrade your existing spatial databases, see here:
        http://postgis.refractions.net/documentation/manual-1.5/ch02.html#upgrading

      PostGIS SQL scripts installed to:
        #{HOMEBREW_PREFIX}/share/postgis
      PostGIS plugin libraries installed to:
        #{postgresql.lib}
    EOS
  end
end
