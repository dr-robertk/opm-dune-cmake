#!/bin/bash

MODULES="opm-common opm-grid opm-core opm-output opm-material ewoms opm-simulators"

for MOD in $MODULES; do
  mkdir $MOD
  cd $MOD
  ln -s ../cmake/modules/DuneBuildSystem.cmake ./CMakeLists.txt
  cd ../
done
