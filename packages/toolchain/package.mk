case ${BUILD_ARCH} in
"armv7")
	PACKAGE_NAME="GNU Toolchain for the A-profile Architecture"
	PACKAGE_VERSION="GCC 8.3-2019.03"
	PACKAGE_SRC="https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz"
	;;
"x86")
	PACKAGE_NAME="Toolchain for the x86-i686 Architecture"
	PACKAGE_VERSION="(Buildroot 2018.11-rc2-00003-ga0787e9) 8.2.0"
	PACKAGE_SRC="https://toolchains.bootlin.com/downloads/releases/toolchains/x86-i686/tarballs/x86-i686--glibc--bleeding-edge-2018.11-1.tar.bz2"
	;;
*)
	;;
esac

on_exit_build() {
	TOOLCHAIN_DIR=$(pwd)

	case ${BUILD_ARCH} in
	"armv7")	
		BUILD_TARGET="arm-linux-gnueabihf"
#		BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/lib -L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--sysroot=${STAGING_DIR} -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=${INSTALL_PREFIX}/${BUILD_TARGET}/lib/ld-linux-armhf.so.3"
        BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=${INSTALL_PREFIX}/${BUILD_TARGET}/lib/ld-linux-armhf.so.3"
		;;
	"x86")
		BUILD_TARGET="i686-linux"
		BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=${INSTALL_PREFIX}/${BUILD_TARGET}/lib/ld-linux.so.2"
		# bison in this toolchain is looking at wrong paths, use system one instead
		# https://github.com/bootlin/toolchains-builder/issues/17
		if [[ -e ${TOOLCHAIN_DIR}/bin/bison ]]; then
			mv ${TOOLCHAIN_DIR}/bin/bison ${TOOLCHAIN_DIR}/bin/bison.disabled
		fi
		;;
	*)
		echo_error "Error: Unknown target '${BUILD_ARCH}'. Toolchain setup failed."
		return 1
		;;
	esac

	BUILD_CC="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-gcc"
	BUILD_CXX="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-g++"
	BUILD_AR="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ar"
	BUILD_RANLIB="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ranlib"
	BUILD_OBJCOPY="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-objcopy"
	BUILD_STRIP="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-strip"
	BUILD_CFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/include"
	BUILD_PKG_CONFIG_LIBDIR="${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig"
	BUILD_PKG_CONFIG_SYSROOT_DIR="${STAGING_DIR}"
	export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

	TOOLCHAIN_CMAKE="${TOOLCHAIN_DIR}/config/cmake-toolchain.txt"
	mkdir -p ${TOOLCHAIN_DIR}/config
	in_to_out ${PACKAGE_DIR}/config/cmake-toolchain.txt.in ${TOOLCHAIN_CMAKE}

	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	echo "TOOLCHAIN_DIR=\"${TOOLCHAIN_DIR}\""
	echo "BUILD_TARGET=\"${BUILD_TARGET}\""
	echo "BUILD_CC=\"${BUILD_CC}\""
	echo "BUILD_CXX=\"${BUILD_CXX}\""
	echo "BUILD_AR=\"${BUILD_AR}\""
	echo "BUILD_RANLIB=\"${BUILD_RANLIB}\""
	echo "BUILD_OBJCOPY=\"${BUILD_OBJCOPY}\""
	echo "BUILD_STRIP=\"${BUILD_STRIP}\""
	echo "BUILD_CFLAGS=\"${BUILD_CFLAGS}\""
	echo "BUILD_LDFLAGS=\"${BUILD_LDFLAGS}\""
	echo "BUILD_PKG_CONFIG_LIBDIR=\"${BUILD_PKG_CONFIG_LIBDIR}\""
	echo "BUILD_PKG_CONFIG_SYSROOT_DIR=\"${BUILD_PKG_CONFIG_SYSROOT_DIR}\""
	echo "PATH=\"${PATH}\""
	echo "TOOLCHAIN_CMAKE=\"${TOOLCHAIN_CMAKE}\""
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}
