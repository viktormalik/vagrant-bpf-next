#!/bin/bash

# Usage: ./run_tests [TESTS]
#
# Default tests to run are in $ALL_TESTS
#
# Creating <TEST>-denylist in the same directory will skip the listed
# sub-tests of <TEST>

TESTDIR=${TESTDIR:=/bpf-next/tools/testing/selftests/bpf}
ALL_TESTS="test_progs test_progs-no_alu32 test_maps test_verifier"
LOG=""

run_test() {
    testname=$1
    if [ -f /vagrant/$testname-denylist ]; then
        denylist=$(cat /vagrant/$testname-denylist | cut -d' ' -f1 | tr '\n' ',')
        cmd="$TESTDIR/$testname -d $denylist"
    else
        cmd="$TESTDIR/$testname"
    fi
    LOG="$LOG$testname: $($cmd | tee /dev/tty | tail -n 1)\n"
    echo
}

if [ $# -eq 0 ]; then
    tests=$ALL_TESTS
else
    tests=$@
fi

rc=0
for t in $tests; do
    run_test $t || rc=1
done

echo "Summary"
echo "-------"
echo -e $LOG

if [ $rc -eq 0 ]; then
    echo "All tests have passed"
else
    echo "Some tests have failed"
fi

exit $rc
