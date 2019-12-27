PACKAGE_NAME="Game Music Emu"
PACKAGE_VERSION="0.6.2"
PACKAGE_SRC="https://bitbucket.org/mpyne/game-music-emu/downloads/game-music-emu-0.6.2.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}