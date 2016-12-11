require 'formula'

class Hdf < Formula
  version "4"
  homepage 'http://www.hdfgroup.org'
  url 'http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.8/src/hdf-4.2.8.tar.bz2'
  sha1 '9d4ab457ccb8e582c265ca3f5f2ec90614d89da4'

  option 'enable-fortran', 'Build Fortran interface.'

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'szip'
  depends_on 'jpeg'
  depends_on :fortran if build.include? 'enable-fortran'

  def patches
    # Fix a couple of buglets in CMakeLists that showed up post-4.2.6. These
    # need to be reported upstream.
    DATA
  end

  def install
    ENV['SZIP_INSTALL'] = HOMEBREW_PREFIX

    args = std_cmake_args
    args.concat [
      '-DBUILD_SHARED_LIBS=ON',
      '-DBUILD_TESTING=OFF',
      '-DHDF4_BUILD_TOOLS=ON',
      '-DHDF4_BUILD_UTILS=ON',
      '-DHDF4_BUILD_WITH_INSTALL_NAME=ON',
      '-DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON',
      '-DHDF4_ENABLE_NETCDF=OFF', # Conflict. Just install NetCDF for this.
      '-DHDF4_ENABLE_SZIP_ENCODING=ON',
      '-DHDF4_ENABLE_SZIP_SUPPORT=ON',
      '-DHDF4_ENABLE_Z_LIB_SUPPORT=ON'
    ]
    if build.include? 'enable-fortran'
      args.concat %W[-DHDF4_BUILD_FORTRAN=ON -DCMAKE_Fortran_MODULE_DIRECTORY=#{include}]
    else
      args << '-DHDF4_BUILD_FORTRAN=OFF'
    end

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make install'

      # Remove stray ncdump executable as it conflicts with NetCDF.
      rm (bin + 'ncdump')
    end
  end

  def caveats; <<-EOS.undent
      HDF4 has been superseeded by HDF5.  However, the API changed
      substantially and some programs still require the HDF4 libraries in order
      to function.
    EOS
  end
end
__END__
Fix a couple of errors in the CMake configuration that showed up after 4.2.6:

  * Don't pass the NAMES attribute to FIND_PACKAGE as this makes it impossible
    to find anything.
  * Don't define _POSIX_SOURCE as this causes incorrect typedefs for parameters
    like u_int and u_long.

diff --git a/CMakeLists.txt b/CMakeLists.txt
index 7ccb383..39cc093 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -457,7 +457,7 @@ OPTION (HDF4_ENABLE_JPEG_LIB_SUPPORT "Enable libjpeg" ON)
 IF (HDF4_ENABLE_JPEG_LIB_SUPPORT)
   IF (NOT H4_JPEGLIB_HEADER)
     IF (NOT JPEG_USE_EXTERNAL)
-      FIND_PACKAGE (JPEG NAMES ${JPEG_PACKAGE_NAME}${HDF_PACKAGE_EXT})
+      FIND_PACKAGE (JPEG)
     ENDIF (NOT JPEG_USE_EXTERNAL)
     IF (JPEG_FOUND)
       SET (H4_HAVE_JPEGLIB_H 1)
@@ -504,7 +504,7 @@ OPTION (HDF4_ENABLE_Z_LIB_SUPPORT "Enable Zlib Filters" ON)
 IF (HDF4_ENABLE_Z_LIB_SUPPORT)
   IF (NOT H4_ZLIB_HEADER)
     IF (NOT ZLIB_USE_EXTERNAL)
-      FIND_PACKAGE (ZLIB NAMES ${ZLIB_PACKAGE_NAME}${HDF_PACKAGE_EXT})
+      FIND_PACKAGE (ZLIB)
     ENDIF (NOT ZLIB_USE_EXTERNAL)
     IF (ZLIB_FOUND)
       SET (H4_HAVE_FILTER_DEFLATE 1)
@@ -542,7 +542,7 @@ OPTION (HDF4_ENABLE_SZIP_SUPPORT "Use SZip Filter" OFF)
 IF (HDF4_ENABLE_SZIP_SUPPORT)
   OPTION (HDF4_ENABLE_SZIP_ENCODING "Use SZip Encoding" OFF)
   IF (NOT SZIP_USE_EXTERNAL)
-    FIND_PACKAGE (SZIP NAMES ${SZIP_PACKAGE_NAME}${HDF_PACKAGE_EXT})
+    FIND_PACKAGE (SZIP)
   ENDIF (NOT SZIP_USE_EXTERNAL)
   IF (SZIP_FOUND)
     SET (H4_HAVE_FILTER_SZIP 1)
@@ -971,4 +971,4 @@ IF (NOT HDF4_EXTERNALLY_CONFIGURED AND NOT HDF4_NO_PACKAGES)
     )
   ENDIF (HDF4_BUILD_UTILS)
 ENDIF (NOT HDF4_EXTERNALLY_CONFIGURED AND NOT HDF4_NO_PACKAGES)
-  
\ No newline at end of file
+  
diff --git a/config/cmake/ConfigureChecks.cmake b/config/cmake/ConfigureChecks.cmake
index eddb311..b13da01 100644
--- a/config/cmake/ConfigureChecks.cmake
+++ b/config/cmake/ConfigureChecks.cmake
@@ -233,7 +233,7 @@ IF (NOT WINDOWS)
   IF (CYGWIN)
     SET (HDF_EXTRA_FLAGS -D_BSD_SOURCE)
   ELSE (CYGWIN)
-    SET (HDF_EXTRA_FLAGS -D_POSIX_SOURCE -D_BSD_SOURCE)
+    SET (HDF_EXTRA_FLAGS -D_BSD_SOURCE)
   ENDIF (CYGWIN)
   OPTION (HDF_ENABLE_LARGE_FILE "Enable support for large (64-bit) files on Linux." ON)
   IF (HDF_ENABLE_LARGE_FILE)
