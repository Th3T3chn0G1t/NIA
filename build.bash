#!/bin/bash

# TODO(Emily): Use `getopt` instead of this
if [ "$1" = "--help" ]; then
	echo "Usage: $0 [--help]"
	echo ""
	echo "Environment:"
	echo "	NIA_SILENT: Silences script output"
	echo "	NIA_NO_LOG: Prevents writing of log files"
	echo "	NIA_LOGDIR: Sets log output dir (Default: \$NIA_ROOT/Logs)"
	echo "	NIA_NO_BUILD_OFX: Disables the building of OFX"
	exit 0
fi

# Allow out-of-tree builds
if [ -z ${NIA_ROOT+x} ]; then
        NIA_ROOT=`realpath .`
fi

LOGFILE_STAMP="`date -Iseconds`"

# Allow out-of-tree builds
if [ -z ${NIA_LOGDIR+x} ]; then
        NIA_LOGDIR="$NIA_ROOT/Logs"
fi
mkdir -p $NIA_LOGDIR


debug() {
        if [ -z ${NIA_SILENT+x} ]; then
                # TODO(Emily): Might need to check for different echo types
                #              As macOS f.e. doesn't need nor want the `-e` for
                #              Echoing escape codes.
                echo -e $DBGFLAG "[\033[1;35mNIA\033[0;m] $MSG"
        fi

		if [ -z ${NOLOG+x} ]; then
	        echo -e "[NIA] $MSG" >> $LOGFILE
		fi
}

if [ -z ${NIA_NO_LOG+x} ]; then
	LOGFILE="$NIA_LOGDIR/NIA-Build-$LOGFILE_STAMP.log"
	MSG="Writing logs to $LOGFILE" debug
else
	LOGFILE="/dev/null"
fi

MSG="Using project root $NIA_ROOT" debug

if [ -z ${NIA_NO_BUILD_OFX} ]; then
	OFX_DIR="$NIA_ROOT/Source/Vendor/OpenFX"

	make -C$OFX_DIR/Support/Library >> $LOGFILE 2>&1 &
	make -C$OFX_DIR/Support/Plugins >> $LOGFILE 2>&1 &
	make -C$OFX_DIR/HostSupport >> $LOGFILE 2>&1 &

	MSG="Building OpenFX" DBGFLAG="-n" debug

	while
		jobs %1 &> /dev/null ||
		jobs %2 &> /dev/null ||
		jobs %3 &> /dev/null
	do
		echo -ne "."
		sleep 1
	done
	echo " Done!"
fi

