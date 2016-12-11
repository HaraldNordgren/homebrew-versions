require 'formula'

class OpenMpi < Formula
  version "16"
  homepage 'http://www.open-mpi.org/'
  url 'http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.5.tar.bz2'
  sha1 '93859d515b33dd9a0ee6081db285a2d1dffe21ce'

  option 'disable-fortran', 'Do not build the Fortran bindings'
  option 'enable-mpi-thread-multiple', 'Enable MPI_THREAD_MULTIPLE'

  keg_only 'Conflicts with open-mpi in core repository.'

  depends_on :fortran unless build.include? 'disable-fortran'

  # Fixes error in tests, which makes them fail on clang.
  # Upstream ticket: https://svn.open-mpi.org/trac/ompi/ticket/4255
  patch :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
    ]
    if build.include? 'disable-fortran'
      args << '--disable-mpi-f77' << '--disable-mpi-f90'
    end

    if build.include? 'enable-mpi-thread-multiple'
      args << '--enable-mpi-thread-multiple'
    end

    system './configure', *args
    system 'make', 'all'
    system 'make', 'check'
    system 'make', 'install'

    # If Fortran bindings were built, there will be a stray `.mod` file
    # (Fortran header) in `lib` that needs to be moved to `include`.
    include.install lib/'mpi.mod' if File.exist? "#{lib}/mpi.mod"

    # Not sure why the wrapped script has a jar extension - adamv
    libexec.install bin/'vtsetup.jar'
    bin.write_jar_script libexec/'vtsetup.jar', 'vtsetup.jar'
  end
end

__END__
diff --git a/test/datatype/ddt_lib.c b/test/datatype/ddt_lib.c
index 015419d..c349384 100644
--- a/test/datatype/ddt_lib.c
+++ b/test/datatype/ddt_lib.c
@@ -209,7 +209,7 @@ int mpich_typeub2( void )

 int mpich_typeub3( void )
 {
-   int blocklen[2], err = 0, idisp[3];
+   int blocklen[3], err = 0, idisp[3];
    size_t sz;
    MPI_Aint disp[3], lb, ub, ex;
    ompi_datatype_t *types[3], *dt1, *dt2, *dt3, *dt4, *dt5;
diff --git a/test/datatype/opal_ddt_lib.c b/test/datatype/opal_ddt_lib.c
index 4491dcc..b58136d 100644
--- a/test/datatype/opal_ddt_lib.c
+++ b/test/datatype/opal_ddt_lib.c
@@ -761,7 +761,7 @@ int mpich_typeub2( void )

 int mpich_typeub3( void )
 {
-   int blocklen[2], err = 0, idisp[3];
+   int blocklen[3], err = 0, idisp[3];
    size_t sz;
    OPAL_PTRDIFF_TYPE disp[3], lb, ub, ex;
    opal_datatype_t *types[3], *dt1, *dt2, *dt3, *dt4, *dt5;
