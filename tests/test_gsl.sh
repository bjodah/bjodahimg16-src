#!/bin/bash -e
tmpfile=$(mktemp)
trap "rm $tmpfile" EXIT SIGINT SIGTERM
gcc -O2 -o $tmpfile gsl_ex_main.c -lgsl -lgslcblas -lm
$tmpfile >/dev/null
