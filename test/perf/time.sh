#/bin/bash
if [[ -n $SSORT_BUILD_DIR ]]; then
    _SSORT_BUILD_DIR=$SSORT_BUILD_DIR
else
    _SSORT_BUILD_DIR="build"
fi

if [[ -n $SSORT_TESTDATA_PATH ]]; then
    _SSORT_TESTDATA_PATH=$SSORT_TESTDATA_PATH
else
    _SSORT_TESTDATA_PATH="test/testdata"
fi

if [[ -n $SSORT_FLAGS ]]; then
    _SSORT_FLAGS=$SSORT_FLAGS
else
    _SSORT_FLAGS=""
fi

SIG_TERM_EXIT_BASE=128
SIGINT=2
SIGINT_EXIT=$(($SIG_TERM_EXIT_BASE + $SIGINT))

clean_setup() {
    rm -rf $1 $2
}

for compressed in $_SSORT_TESTDATA_PATH/*.txt.gz; do
    decompressed=${compressed%".gz"} &&
    gunzip -c $compressed > $decompressed
    actual=${decompressed}.sorted

    cmd="$_SSORT_BUILD_DIR/ssort"
    if [[ -n $_SSORT_FLAGS ]]; then
        cmd="$cmd $_SSORT_FLAGS"
    fi
    cmd="$cmd $decompressed"
    
    for i in {1..10}; do
        echo "$cmd $i:" &&
        time -p $cmd 2>/dev/null
        if [ $? -eq $SIGINT_EXIT ]; then
            echo "[ERROR] time.sh: ssort child process was interrupted"
            clean_setup $decompressed $actual
            exit $SIGINT_EXIT
        fi
    done
    clean_setup $decompressed $actual
done
