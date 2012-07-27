#! /bin/sh
#open /usr/bin/screen
curfile=$BASH_SOURCE
dirpath=${curfile%/*}
/bin/sh $dirpath/../../../${distro.name}.sh