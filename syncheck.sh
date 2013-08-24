#!/bin/bash

set -e

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)
PROG=syncheck.sh

trap bug_found ERR

function usage() {
    echo "$PROG"
}

function bug_found() {
    echo >&2 "ERROR: You found a bug in the $PROG script, please report"
    exit 99
}

cd "$HERE"

RET=0

#file test args msg
function check() {
    if grep -q $3 "$2" -- "$1"; then
        echo "SYNTAX ERROR: $4 found in '$1'"
        grep --color=always $3 "$2" -- "$1" | while read line; do
            echo " --> $line"
        done
        echo
        RET=1
    fi
    return 0
}

while read file; do
    check "$file" '^.{121,}$' -EHn "line too long"
    check "$file" ' $' -EHn "trailing whitespace"
    check "$file" '	' -Hn "tab found"
    check "$file" '^ +[+-]' -EHn "method declaration/definition not on line start"
    check "$file" '^[+-]\([a-z *]+\)' -EHn "method declaration/definition syntax"
    check "$file" '@synthesize' -Hn "@synthesize found"
    check "$file" '^[+-] \(.*\).*\{' -EHn "method definition: { not on next line"
done < <(find FRLayeredNavigationController -name '*.h' \
              -or -name '*.m' -type f)

if [ $RET -eq 0 ]; then
    echo "CONGRATULATIONS, looks fine"
fi

exit $RET
