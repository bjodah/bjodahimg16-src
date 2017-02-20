#!/bin/bash
if [[ ! -d /opt/boost_1_63_0 ]]; then
    >&2 echo "Could not find directory: boost_1_63_0 under /opt:"
    set -x
    ls -lah /opt
    set +x
    exit 1
fi
cd /tmp
TMPFILE=tmpfile
touch $TMPFILE
mv ${TMPFILE} ${TMPFILE}.cpp
TMPFILE=${TMPFILE}.cpp
cleanup() {
    rm $TMPFILE test_po
}
trap cleanup INT TERM
cat <<'EOF'>$TMPFILE
#include <sysexits.h>
#include <iostream>
#include <boost/program_options.hpp>

int main(int ac, char* av[]) {
    namespace po = boost::program_options;
    using namespace std;

    po::options_description desc("Allowed options");
    desc.add_options()
            ("help", "produce help message")
            ("compression", po::value<int>(), "set compression level")
            ;

    po::variables_map vm;
    po::store(po::parse_command_line(ac, av, desc), vm);
    po::notify(vm);

    if (vm.count("help")) {
        cout << desc << "\n";
        return EX_USAGE;
    }

    if (vm.count("compression")) {
        cout << "Compression level was set to "
        << vm["compression"].as<int>() << ".\n";
    } else {
        cout << "Compression level was not set.\n";
    }
}
EOF
CPLUS_INCLUDE_PATH=/opt/boost_1_63_0 LIBRARY_PATH=/opt/boost_1_63_0/lib g++ $TMPFILE -o test_po -lboost_program_options
LD_LIBRARY_PATH=/opt/boost_1_63_0/lib ./test_po --help
if [[ $? -ne 64 ]]; then  # EX_USAGE == 64 on linux...
    >&2 echo "Failed to run test_po (boost 1.63.0 link mismatch?)"
    exit 1
fi
cleanup
