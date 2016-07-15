#!/bin/bash -e
tmpfile=$(mktemp)
trap "rm $tmpfile" EXIT SIGINT SIGTERM
gcc -I${PREFIX}/include -L${PREFIX}/lib -o $tmpfile sundials_cvRoberts_dns.c -lm -lsundials_cvode -llapack -lsundials_nvecserial
$tmpfile >/dev/null
