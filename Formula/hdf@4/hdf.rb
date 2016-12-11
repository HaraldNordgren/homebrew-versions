class Hdf < Formula
  version "4"
  homepage "http://www.hdfgroup.org"
  url "http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.11/src/hdf-4.2.11.tar.bz2"
  sha256 "bb0e900b8cc6bc89a5730abc97e654e7705e8e1fbc4e0d4477f417822428d99b"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha1 "c2c52d5a07559d08d3eb5af108ed8b839721ed88" => :yosemite
    sha1 "ac39325b98c7baac776f8a28e4fb138a25ea7340" => :mavericks
    sha1 "cc499e59d40db001001ef595539e1d79dcf18c96" => :mountain_lion
  end

  option "with-fortran", "Build Fortran interface."

  deprecated_option "enable-fortran" => "with-fortran"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "szip"
  depends_on "jpeg"
  depends_on :fortran => :optional

  # redefine library name to "df" from "hdf".  this seems to be an artifact
  # of using cmake that needs to be corrected for compatibility with
  # anything depending on hdf4.
  patch :DATA

  def install
    ENV["SZIP_INSTALL"] = HOMEBREW_PREFIX

    args = std_cmake_args
    args.concat [
      "-DBUILD_SHARED_LIBS=ON",
      "-DBUILD_TESTING=OFF",
      "-DHDF4_BUILD_TOOLS=ON",
      "-DHDF4_BUILD_UTILS=ON",
      "-DHDF4_BUILD_WITH_INSTALL_NAME=ON",
      "-DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON",
      "-DHDF4_ENABLE_NETCDF=OFF", # Conflict. Just install NetCDF for this.
      "-DHDF4_ENABLE_SZIP_ENCODING=ON",
      "-DHDF4_ENABLE_SZIP_SUPPORT=ON",
      "-DHDF4_ENABLE_Z_LIB_SUPPORT=ON"
    ]

    if build.with? "fortran"
      args.concat %W[-DHDF4_BUILD_FORTRAN=ON -DCMAKE_Fortran_MODULE_DIRECTORY=#{include}]
    else
      args << "-DHDF4_BUILD_FORTRAN=OFF"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"

      # Remove stray ncdump executable as it conflicts with NetCDF.
      rm (bin+"ncdump")
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
--- a/CMakeLists.txt	2015-02-09 11:43:05.000000000 -0500
+++ b/CMakeLists.txt	2015-06-28 14:05:35.000000000 -0400
@@ -95,7 +95,7 @@
 # Set the core names of all the libraries
 #-----------------------------------------------------------------------------
 set (HDF4_LIB_CORENAME              "hdf4")
-set (HDF4_SRC_LIB_CORENAME          "hdf")
+set (HDF4_SRC_LIB_CORENAME          "df")
 set (HDF4_SRC_FCSTUB_LIB_CORENAME   "hdf_fcstub")
 set (HDF4_SRC_FORTRAN_LIB_CORENAME  "hdf_fortran")
 set (HDF4_MF_LIB_CORENAME           "mfhdf")
