class Gdal < Formula
  version "111"
  desc "GDAL: Geospatial Data Abstraction Library"
  homepage "http://www.gdal.org/"
  revision 1

  stable do
    url "http://download.osgeo.org/gdal/1.11.1/gdal-1.11.1.tar.gz"
    sha256 "f46b5944a8cabc8516673f231f466131cdfd2cdc6677dbee5d96ec7fc58a3340"

    # REMOVE when 1.11.2 is released
    # Fix segfault when executing OGR2SQLITE_Register() when compiled against sqlite 3.8.7
    # See: http://trac.osgeo.org/gdal/ticket/5725, https://github.com/OSGeo/gdal/commit/12d3b98
    # Fixes issue with QGIS's Save as... for vector layers: http://hub.qgis.org/issues/11526
    patch :p2 do
      url "https://github.com/OSGeo/gdal/commit/12d3b984a052c59ee336f952902b82ace01ba31c.diff"
      sha256 "f255bf89933c6a275726293983e29f23ba878c30b024b544cc7a70ce3eb92894"
    end
  end

  bottle do
    sha256 "438b85eda6978c38b0414885bb8d8584a9d9a95077ea6e761f516b0a83a489c2" => :sierra
    sha256 "2cd0f0de91d8216b5435d4073b71232c1d6b58bd72f47750ef323044ecf01aa0" => :el_capitan
    sha256 "edb87e84e3201ef68b90910f9d50c4b906c2384fe118a0b9652699b0850d133a" => :yosemite
  end

  option "with-complete", "Use additional Homebrew libraries to provide more drivers."
  option "with-opencl", "Build with OpenCL acceleration."
  option "with-armadillo", "Build with Armadillo accelerated TPS transforms."
  option "with-unsupported", "Allow configure to drag in any library it can find. Invoke this at your own risk."
  option "with-mdb", "Build with Access MDB driver (requires Java 1.6+ JDK/JRE, from Apple or Oracle)."
  option "with-libkml", "Build with Google's libkml driver (requires libkml --HEAD or >= 1.3)"

  depends_on :python => :optional
  if build.with? "python"
    depends_on :fortran => :build
  end

  depends_on "libpng"
  depends_on "jpeg"
  depends_on "giflib"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "proj"
  depends_on "geos"
  depends_on "sqlite" # To ensure compatibility with SpatiaLite.
  depends_on "freexl"
  depends_on "libspatialite"
  depends_on "postgresql" => :optional
  depends_on "mysql" => :optional
  depends_on "homebrew/science/armadillo" => :optional

  if build.with? "libkml"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  if build.with? "complete"
    # Raster libraries
    depends_on "homebrew/science/netcdf" # Also brings in HDF5
    depends_on "jasper"
    depends_on "webp"
    depends_on "cfitsio"
    depends_on "epsilon"
    depends_on "libdap"
    depends_on "libxml2"

    # Vector libraries
    depends_on "unixodbc" # OS X version is not complete enough
    depends_on "xerces-c"

    # Other libraries
    depends_on "xz" # get liblzma compression algorithm library from XZutils
    depends_on "poppler"
    depends_on "json-c"
  end

  # Extra linking libraries in configure test of armadillo may throw warning
  # see: https://trac.osgeo.org/gdal/ticket/5455
  if build.with? "armadillo"
    patch do
      url "https://gist.githubusercontent.com/dakcarto/7abad108aa31a1e53fb4/raw/b56887208fd91d0434d5a901dae3806fb1bd32f8/gdal-armadillo.patch"
      sha256 "e6880b9256abe2c289f4b1196792a626c689772390430c36976c0c5e0f339124"
    end
  end

  resource "numpy" do
    url "https://downloads.sourceforge.net/project/numpy/NumPy/1.8.1/numpy-1.8.1.tar.gz"
    sha256 "3d722fc3ac922a34c50183683e828052cd9bb7e9134a95098441297d7ea1c7a9"
  end

  resource "libkml" do
    # Until 1.3 is stable, use master branch
    url "https://github.com/google/libkml.git",
        :revision => "9b50572641f671194e523ad21d0171ea6537426e"
    version "1.3-dev"
  end

  def configure_args
    args = [
      # Base configuration.
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-local=#{prefix}",
      "--with-threads",
      "--with-libtool",

      # GDAL native backends.
      "--with-pcraster=internal",
      "--with-pcidsk=internal",
      "--with-bsb",
      "--with-grib",
      "--with-pam",

      # Backends supported by OS X.
      "--with-libiconv-prefix=/usr",
      "--with-libz=/usr",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-expat=/usr",
      "--with-curl=/usr/bin/curl-config",

      # Default Homebrew backends.
      "--with-jpeg=#{HOMEBREW_PREFIX}",
      "--without-jpeg12", # Needs specially configured JPEG and TIFF libraries.
      "--with-gif=#{HOMEBREW_PREFIX}",
      "--with-libtiff=#{HOMEBREW_PREFIX}",
      "--with-geotiff=#{HOMEBREW_PREFIX}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-freexl=#{HOMEBREW_PREFIX}",
      "--with-spatialite=#{HOMEBREW_PREFIX}",
      "--with-geos=#{HOMEBREW_PREFIX}/bin/geos-config",
      "--with-static-proj4=#{HOMEBREW_PREFIX}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",

      # GRASS backend explicitly disabled.  Creates a chicken-and-egg problem.
      # Should be installed separately after GRASS installation using the
      # official GDAL GRASS plugin.
      "--without-grass",
      "--without-libgrass",
    ]

    # Optional Homebrew packages supporting additional formats.
    supported_backends = %w[
      liblzma
      cfitsio
      hdf5
      netcdf
      jasper
      xerces
      odbc
      dods-root
      epsilon
      webp
      poppler
    ]

    if build.with? "complete"
      supported_backends.delete "liblzma"
      args << "--with-liblzma=yes"
      args.concat supported_backends.map { |b| "--with-" + b + "=" + HOMEBREW_PREFIX }
    elsif build.without? "unsupported"
      args.concat supported_backends.map { |b| "--without-" + b }
    end

    # The following libraries are either proprietary, not available for public
    # download or have no stable version in the Homebrew core that is
    # compatible with GDAL. Interested users will have to install such software
    # manually and most likely have to tweak the install routine.
    #
    # Podofo is disabled because Poppler provides the same functionality and
    # then some.
    unsupported_backends = %w[
      gta
      ogdi
      fme
      hdf4
      openjpeg
      fgdb
      ecw
      kakadu
      mrsid
      jp2mrsid
      mrsid_lidar
      msg
      oci
      ingres
      dwgdirect
      idb
      sde
      podofo
      rasdaman
      sosi
    ]
    args.concat unsupported_backends.map { |b| "--without-" + b } if build.without? "unsupported"

    # Database support.
    args << (build.with?("postgresql") ? "--with-pg=#{HOMEBREW_PREFIX}/bin/pg_config" : "--without-pg")
    args << (build.with?("mysql") ? "--with-mysql=#{HOMEBREW_PREFIX}/bin/mysql_config" : "--without-mysql")

    if build.with? "mdb"
      args << "--with-java=yes"
      # The rpath is only embedded for Oracle (non-framework) installs
      args << "--with-jvm-lib-add-rpath=yes"
      args << "--with-mdb=yes"
    end

    args << "--with-libkml=#{libexec}" if build.with? "libkml"

    # Python is installed manually to ensure everything is properly sandboxed.
    args << "--without-python"

    # Scripting APIs that have not been re-worked to respect Homebrew prefixes.
    #
    # Currently disabled as they install willy-nilly into locations outside of
    # the Homebrew prefix.  Enable if you feel like it, but uninstallation may be
    # a manual affair.
    #
    # TODO: Fix installation of script bindings so they install into the
    # Homebrew prefix.
    args << "--without-perl"
    args << "--without-php"
    args << "--without-ruby"

    args << (build.with?("opencl") ? "--with-opencl" : "--without-opencl")
    args << (build.with?("armadillo") ? "--with-armadillo=#{Formula["armadillo"].opt_prefix}" : "--with-armadillo=no")

    args
  end

  def package_installed(python, module_name)
    quiet_system python, "-c", "import #{module_name}"
  end

  def install
    if (build.with? "python") && !(package_installed "python", "numpy")
      ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"
      numpy_args = ["build", "--fcompiler=gnu95",
                    "install", "--prefix=#{libexec}"]
      resource("numpy").stage { system "python", "setup.py", *numpy_args }
    end

    if build.with? "libkml"
      resource("libkml").stage do
        # See main `libkml` formula for info on patches
        inreplace "configure.ac", "-Werror", ""
        inreplace "third_party/Makefile.am" do |s|
          s.sub!(/(lib_LTLIBRARIES =) libminizip.la liburiparser.la/, "\\1")
          s.sub!(/(noinst_LTLIBRARIES = libgtest.la libgtest_main.la)/,
                 "\\1 libminizip.la liburiparser.la")
          s.sub!(/(libminizip_la_LDFLAGS =)/, "\\1 -static")
          s.sub!(/(liburiparser_la_LDFLAGS =)/, "\\1 -static")
        end

        system "./autogen.sh"
        system "./configure", "--prefix=#{libexec}"
        system "make", "install"
      end
    end

    # Linking flags for SQLite are not added at a critical moment when the GDAL
    # library is being assembled. This causes the build to fail due to missing
    # symbols. Also, ensure Homebrew SQLite is used so that Spatialite is
    # functional.
    #
    # Fortunately, this can be remedied using LDFLAGS.
    sqlite = Formula["sqlite"]
    ENV.append "LDFLAGS", "-L#{sqlite.opt_lib} -lsqlite3"
    ENV.append "CFLAGS", "-I#{sqlite.opt_include}"

    # Reset ARCHFLAGS to match how we build.
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    # Fix hardcoded mandir: http://trac.osgeo.org/gdal/ticket/5092
    inreplace "configure", %r{^mandir='\$\{prefix\}\/man'$}, ""

    # These libs are statically linked in vendored libkml and libkml formula
    inreplace "configure", " -lminizip -luriparser", "" if build.with? "libkml"

    system "./configure", *configure_args
    system "make"
    system "make", "install"

    # `python-config` may try to talk us into building bindings for more
    # architectures than we really should.
    if MacOS.prefer_64_bit?
      ENV.append_to_cflags "-arch #{Hardware::CPU.arch_64_bit}"
    else
      ENV.append_to_cflags "-arch #{Hardware::CPU.arch_32_bit}"
    end

    cd "swig/python" do
      system "python", *Language::Python.setup_install_args(libexec/"vendor")
      bin.install Dir["scripts/*"]
    end

    system "make", "install-man"
    # Clean up any stray doxygen files.
    Dir.glob("#{bin}/*.dox") { |p| rm p }
  end

  def caveats
    if build.with? "mdb"
      <<-EOS.undent
      To have a functional MDB driver, install supporting .jar files in:
        `/Library/Java/Extensions/`

      See: http://www.gdal.org/ogr/drv_mdb.html
      EOS
    end
  end

  test do
    system bin/"gdalinfo", "--formats"
    system bin/"ogrinfo", "--formats"
  end
end
