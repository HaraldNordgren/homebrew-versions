class Eigen < Formula
  version "2"
  homepage "http://eigen.tuxfamily.org/"
  url "https://bitbucket.org/eigen/eigen/get/2.0.17.tar.bz2"
  sha256 "7255e856ed367ce6e6e2d4153b0e4e753c8b8d36918bf440dd34ad56aff09960"

  depends_on "cmake" => :build

  def install
    mkdir "eigen-build" do
      args = std_cmake_args
      args << "-DCMAKE_BUILD_TYPE=Release"
      args << "-Dpkg_config_libdir='#{lib}'" << ".."

      system "cmake", *args
      system "make", "install"
    end
  end
end
