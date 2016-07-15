#!/bin/bash -e
cat <<EOF | g++ -o /tmp/a.out -xc++ -std=c++11 - && /tmp/a.out
#include <boost/convert.hpp>
#include <boost/convert/lexical_cast.hpp>

int main(){ 
    int i1 = boost::lexical_cast<int>("123");
    if (i1 == 123)
        return 0;
    return 1;
}
EOF

cat <<EOF | g++ -o /tmp/a.out -xc++ -std=c++11 - && /tmp/a.out
#include <boost/vmd/is_seq.hpp>  // new in Boost 1.60

int main(void){
    return 0;
}
EOF

cat <<EOF | g++ -o /tmp/a.out -xc++ -std=c++11 - && /tmp/a.out
#include <boost/math/tools/polynomial.hpp>

using namespace boost::math;
using namespace boost::math::tools; // for polynomial
using boost::lexical_cast;

int main(void){
    boost::array<double, 4> const d3a = {{10, -6, -4, 3}};
    polynomial<double> const a(d3a.begin(), d3a.end());
    
    // With C++11 and later, you can also use initializer_list construction.
    polynomial<double> const b{{-2.0, 1.0}};
    
    // formula_format() converts from Boost storage to human notation.
    // Now we can do arithmetic with the usual infix operators: + - * / and %.
    polynomial<double> s = a + b;
    polynomial<double> d = a - b;
    polynomial<double> p = a * b;
    polynomial<double> q = a / b;
    polynomial<double> r = a % b;
    return 0;
}
EOF
