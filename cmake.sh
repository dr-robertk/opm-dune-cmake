#!/bin/bash

# check for cmake call from dunecontrol
if [ "$1" == "-DCMAKE_MODULE_PATH=" ]; then

  OLDFLAGS=$@

  for SOURCE_DIR in $OLDFLAGS; do true
  done

  MODULE_NAME=`cat $SOURCE_DIR/dune.module | grep -i "Module:" | cut -d " " -f 2`

  echo "$MODULE_NAME: build in $SOURCE_DIR"
  NEW_SOURCE_DIR=$PWD/../opm-dune-cmake/$MODULE_NAME
  if ! test -d $NEW_SOURCE_DIR ; then
    echo "$NEW_SOURCE_DIR does not exits. Falling back to original build"
    exec /usr/bin/cmake $@
  else
    ln -s $SOURCE_DIR/* $NEW_SOURCE_DIR/
  fi

  FLAGS=
  for FLAG in $OLDFLAGS ; do
    if [ "$FLAG" == "$SOURCE_DIR" ]; then
      export ORIGINAL_PROJECT_SOURCE_DIR=$SOURCE_DIR
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
