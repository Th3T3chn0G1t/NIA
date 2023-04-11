#!/bin/sh

# TODO(Emily): Add usage switch/func?

# Allow out-of-tree builds
if [ -z ${NIA_ROOT+x} ]; then
        NIA_ROOT=`realpath .`
fi

### Usage:
### NIA_SILENT: Silences script output
### NIA_NO_LOG: Prevents writing of log files
### NIA_LOGDIR: Sets log output dir (Default: $NIA_ROOT/Logs)
### NIA_NO_BUILD_OFX: Disables the building of OFX

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
                echo -e "[\033[1;35mNIA\033[0;m] $MSG"
        fi

        echo -e "[NIA] $MSG" >> $LOGFILE
}

if [ -z ${NIA_NO_LOG+x} ]; then
	LOGFILE="$NIA_LOGDIR/NIA-$LOGFILE_STAMP.log"
	MSG="Writing logs to $LOGFILE" debug
else
	LOGFILE="/dev/null"
fi

MSG="Using project root $NIA_ROOT" debug

if [ -z ${NIA_NO_BUILD_OFX} ]; then
	# NOTE(Emily): Let's assume system `python3` is the default for now
	#              We might actually want to switch this to use Nuke's
	#              Bundled runtime for consistency's sake.
	python3 -m pip install -r $NIA_ROOT/Source/Vendor/OpenFX/Documentation/pipreq.txt >> $LOGFILE 2>&1
fi

