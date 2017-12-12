# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

# specify the minimum cmake version
cmake_minimum_required(VERSION 3.0)

# set up project
project("opm-common" C CXX)

# Set CMP0053 (how to handle escape sequences in strings) and CMP0054
# (how to handle conditions) to the new behavior to avoid a pretty
# annoying cmake warning if a library is defined in the toplevel
# CMakeLists.txt. This should probably be considered to be a bug in
# the dune build system. Note that the old behaviour will most likely
# also work fine, but the result of setting this policy to NEW is most
# likely what's intended.
if (POLICY CMP0053)
  cmake_policy(SET CMP0053 NEW)
endif()

if (POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif()

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the OPM cmake macros
include(OpmMacros)

# find the packages needed to compile the module
find_package(Boost COMPONENTS unit_test_framework REQUIRED)

# add headers, source files from CMakeLists_files.cmake to
# library opmcommon.a and create executables
opm_add_headers_library_and_executables("opmcommon")

opm_recusive_copy_testdata_to_builddir("tests/*.param")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
