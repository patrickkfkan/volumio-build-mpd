# volumio-build-mpd

Bash script for cross-building Music Player Daemon (MPD) for Volumio.

The primary aim is to build the latest version of MPD for Volumio which, as of now, is using an outdated version. My reason for doing so is to solve the premature playback cutoff problem that occurs with the YouTube plugin.

The build script supports cross-building MPD for the armv7 and x86 architectures.

## Test status

Tested in Volumio with MPD built by this script:
- Playing local files
- Playing files on DLNA servers
- Playing web radio
- Playing YouTube streams

Testers needed - in particular, playing files over network shares (NFS and Samba).

## Build environment

The build script has been tested on Debian Buster, but a similar distro like Ubuntu 18.04 should also work. You need to install the necessary build tools first before running the script:

```
$ apt install build-essential wget rsync gawk bison \
    	python python3 python3-pip cmake autoconf libtool \
    	git pkg-config gettext intltool qemu-user-static \
    	libgcrypt20-dev gperf libglib2.0-dev docbook-xsl \
    	xsltproc libncurses-dev flex texinfo
$ pip3 install meson ninja

# If cross-building for x86, also need to do:
$ sudo apt install yasm
```

## Usage

```
$ ./build.sh --target=ARCH --prefix=PREFIX --output=FILENAME -jLEVEL
```

Notes:
- --target=ARCH: arm, armv7 or x86.
- --prefix=PREFIX: the path that would point to the MPD build on the target device. **Do not** use general or shared ones like `/usr` or `/usr/local`. Instead, choose a path that can hold the MPD build entirely on its own, such as `/opt/mympd`.
- --output=FILENAME: the name of the binary package that will be generated when the build finishes. This is a gzipped tar archive that will hold all the files needed for running MPD. After the build finishes, you would copy this file to your Volumio device for deployment. Binary packages are stored under the `targets` directory.
- --jLEVEL: the number of jobs to run in parallel by the compiler. To maximize usage of your CPU, you can set this to a value that is double the number of cores of your processor (e.g. `-j8` for a quad-core CPU).
- Default values will be provided for omitted options.
- You will be prompted for confirmation before the build begins. Check that the build options (whether set by you or by default) are correct before continuing.
- Running `./build.sh --help` will show you help information.


## Example

#### Building

```
# Go to home directory
$ cd ~
# Get the script
$ git clone https://github.com/patrickkfkan/volumio-build-mpd.git
$ cd volumio-build-mpd
$ ./build.sh --target=armv7 --prefix=/opt/mympd --output=mympd.tar.gz -j8
--------------------------------------------------------------------------------
Target arch           :  armv7
Prefix                     :  /opt/mympd
Binary package    :  /home/patrickkfkan/volumio-build-mpd/targets/mympd.tar.gz
Make concurrency  :  8

Note: Prefix will be the path to the MPD build on your target device 
--------------------------------------------------------------------------------
Continue [y/n]?
# Enter 'y' to continue

....(messages during build omitted)

# Build finished
Binary package created: /home/patrickkfkan/volumio-build-mpd/targets/mympd.tar.gz

```

#### Deployment
Let's assume our Volumio device is accessible at `volumio.local` and SSH is enabled.

```
# Copy binary package to /home/volumio directory of Volumio device
$ scp /home/patrickkfkan/volumio-build-mpd/targets/mympd.tar.gz volumio@volumio.local:/home/volumio

# SSH into volumio device (we'll use the 'volumio@volumio:' prompt to indicate that we are inside the SSH session)
$ ssh volumio@volumio.local

# Unpack binary package
# The full path of the MPD build is stored inside the binary package, so we change to root directory before unpacking
volumio@volumio: cd /
volumio@volumio: sudo tar xzf /home/volumio/mympd.tar.gz

# Unpacking could take some time ..zzz...

# Enter bin directory of our MPD build
volumio@volumio: cd /opt/mympd/bin

# Quick check that our MPD is executable. Don't leave out the ./ before mpd, otherwise you will be executing Volumio's MPD!
volumio@volumio: ./mpd --version
Music Player Daemon 0.21.16 (0.21.16)
Copyright 2003-2007 Warren Dukes <warren.dukes@gmail.com>
Copyright 2008-2018 Max Kellermann <max.kellermann@gmail.com>
This is free software; see the source for copying conditions.  There is NO
warranty; not even MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

...
# If you see something like the above, mpd is executable and we can proceed to the next step.

# Switch Volumio's MPD to ours
volumio@volumio: sudo ./systemd-switch-mpd.sh

# Check if there are errors, then exit SSH session
volumio@volumio: exit
```

Have fun and, if you don't like the new MPD or something is not working property, you can revert to Volumio's MPD. To do this, SSH into Volumio and enter bin directory of our MPD build:

```
# SSH session
volumio@volumio: cd /opt/mympd/bin
volumio@volumio: ./systemd-switch-mpd.sh --original
```

