#!/bin/bash

if [ "$1" == "-DCMAKE_MODULE_PATH=" ]; then

  #OLDFLAGS=`printf '"%s" ' "$@"; echo "";`
  OLDFLAGS=$@

  for BUILD_DIR in $OLDFLAGS; do true
  done

  echo "$BUILD_DIR $OLDFLAGS"

  FLAGS=
  for FLAG in $OLDFLAGS ; do
    if [ "$FLAG" == "$BUILD_DIR" ]; then
      FLAGS="${FLAGS}"" ""/home/robertk/work/OPM/master/opm-dune-cmake/opm-common"
    else
      FLAGS="${FLAGS}"" ""${FLAG}"
    fi
  done
  echo $FLAGS
  exec /usr/bin/cmake $FLAGS
else
  exec /usr/bin/cmake $@
fi
