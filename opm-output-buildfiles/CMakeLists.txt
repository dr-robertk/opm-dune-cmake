# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.1)

# set up project and specify the minimum cmake version
project("opm-output" C CXX)

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
# library libopmoutput.a and create executables
opm_add_headers_library_and_executables("opmoutput")

install(TARGETS compareSummary DESTINATION bin)

opm_recusive_copy_testdata_to_builddir("tests/*.data" "tests/*.DATA")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
