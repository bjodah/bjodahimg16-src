#!/bin/bash -ex
which phantomjs

# Test py.test:
tmpdir=$(mktemp -d)
trap "rm -r $tmpdir" EXIT SIGINT SIGTERM
cd $tmpdir
mkdir flib
echo -e "def f(x):\n    return x**2" > flib/func.py
echo -e "import func\n\n\ndef test_f():\n    assert func.f(3) == 9" > flib/test_func.py
py.test --pep8 --cov flib --cov-report html --doctest-modules
