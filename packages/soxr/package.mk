PACKAGE_NAME="The SoX Resampler library"
PACKAGE_VERSION="0.1.3"
PACKAGE_SRC="https://sourceforge.net/projects/soxr/files/soxr-0.1.3-Source.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	LDFLAGS="-lm" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}