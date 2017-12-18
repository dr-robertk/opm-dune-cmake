# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0)

# set up project and specify the minimum cmake version
project("opm-simulators" C CXX)

# Set CMP0053 (how to handle escape sequences in strings) to the new
# behavior to avoid a pretty annoying cmake warning if a library is
# defined in the toplevel CMakeLists.txt. This should probably be
# considered to be a bug in the dune build system. Note that the old
# behaviour will most likely also work fine, but the result of setting
# this policy to NEW is most likely what's intended.
if (POLICY CMP0053)
  cmake_policy(SET CMP0053 NEW)
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

find_package(PlainOpmData)
find_package(OpmOutputUtils)

# find the packages needed to compile the unit tests
find_package(Boost COMPONENTS unit_test_framework REQUIRED)

# add source files from CMakeLists_files.cmake to library and create executables
opm_read_listsfile()
if (NOT SuiteSparse_FOUND)
  list (REMOVE_ITEM examples_SOURCES
    tutorials/tutorial2.cpp
    tutorials/tutorial3.cpp
    tutorials/tutorial4.cpp
    )
endif()

opm_add_headers_library_and_executables("opmsimulators")

# download Eigen if user doesn't have the correct version
if (NOT EIGEN3_FOUND)
        message (STATUS "Downloading Eigen3")
        include (ExternalProject)
        externalProject_Add (Eigen3
                GIT_REPOSITORY git://github.com/OPM/eigen3
                UPDATE_COMMAND git checkout 9e788db99d73f3199ade74bfda8d9f73fdfbbe4c
                CMAKE_ARGS -Wno-dev -DEIGEN_TEST_NO_OPENGL=1 -DEIGEN_BUILD_PKGCONFIG=0 -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/eigen3-installed
                )

        include_directories (${CMAKE_BINARY_DIR}/eigen3-installed/include/eigen3)
        add_dependencies (opmsimulators Eigen3)
endif (NOT EIGEN3_FOUND)

if(opm-data_FOUND)
  include (${CMAKE_CURRENT_SOURCE_DIR}/compareECLFiles.cmake)
endif()

opm_recusive_copy_testdata_to_builddir("tests/*.data" "tests/*.DATA" "tests/VFP*")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
