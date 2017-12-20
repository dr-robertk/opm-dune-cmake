# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0)

# set up project and specify the minimum cmake version
project("opm-core" C CXX)

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the OPM cmake macros
include(OpmMacros)

# find the packages needed to compile the unit tests
find_package(Boost COMPONENTS unit_test_framework REQUIRED)

# make sure that the HAVE_CONFIG_H C macro evaluates to one instead of
# being only defined
get_property(CD_LIST DIRECTORY "." PROPERTY COMPILE_DEFINITIONS)
list(REMOVE_ITEM CD_LIST "HAVE_CONFIG_H")
list(APPEND CD_LIST "HAVE_CONFIG_H=1")
set_property(DIRECTORY "." PROPERTY COMPILE_DEFINITIONS "${CD_LIST}")

# read in the file lists of CMakeLists_files.txt and remove the files
# which should not have been added.
opm_read_listsfile()

if (NOT MPI_FOUND)
  list(REMOVE_ITEM TEST_SOURCE_FILES
    "tests/test_parallel_linearsolver.cpp"
    "tests/test_parallelistlinformation.cpp"
    )
endif()

if (NOT SuiteSparse_FOUND)
  list (REMOVE_ITEM MAIN_SOURCE_FILES
    "opm/core/linalg/call_umfpack.c"
    "opm/core/linalg/LinearSolverUmfpack.cpp"
    )
endif()

if (NOT PETSC_FOUND)
  list (REMOVE_ITEM MAIN_SOURCE_FILES
    "opm/core/linalg/call_petsc.c"
    "opm/core/linalg/LinearSolverPetsc.cpp"
    )
endif()


# add the library and create executables based on the file list from
# above
opm_add_headers_library_and_executables("opmcore")

opm_recusive_copy_testdata_to_builddir("tests/*.data" "tests/*.DATA")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
