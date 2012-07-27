#! /bin/sh

cd $(dirname $0)
../ant/bin/ant -nouserlib -f ../build.xml $1
