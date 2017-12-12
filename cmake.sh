#!/bin/bash

# check for cmake call from dunecontrol
if [ "$1" == "-DCMAKE_MODULE_PATH=" ]; then

  #OLDFLAGS=`printf '"%s" ' "$@"; echo "";`
  OLDFLAGS=$@

  for SOURCE_DIR in $OLDFLAGS; do true
  done

  MODULE_NAME=`cat $SOURCE_DIR/dune.module | grep -i "Module:" | cut -d " " -f 2`

  echo "$MODULE_NAME: build in $SOURCE_DIR"

  FLAGS=
  for FLAG in $OLDFLAGS ; do
    if [ "$FLAG" == "$SOURCE_DIR" ]; then
      export ORIGINAL_PROJECT_SOURCE_DIR=$SOURCE_DIR
      NEW_SOURCE_DIR=$PWD/../opm-dune-cmake/$MODULE_NAME
      ln -s $SOURCE_DIR/* $NEW_SOURCE_DIR/
      FLAGS="${FLAGS}"" ""$NEW_SOURCE_DIR"
    else
      FLAGS="${FLAGS}"" ""${FLAG}"
    fi
  done
  echo $FLAGS
  exec /usr/bin/cmake $FLAGS
else
  exec /usr/bin/cmake $@
fi
