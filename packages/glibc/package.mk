PACKAGE_NAME="GNU C Library"
PACKAGE_VERSION="2.32"
PACKAGE_SRC="https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	CC=${BUILD_CC} ${PACKAGE_SRC_DIR}/configure --prefix=${INSTALL_PREFIX}/${BUILD_TARGET} --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} --with-headers=${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --disable-multilib
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}