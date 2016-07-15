#!/bin/bash -e
echo -e 'int main(){ return 0; }' | gcc -o /tmp/a.out -xc - && /tmp/a.out
