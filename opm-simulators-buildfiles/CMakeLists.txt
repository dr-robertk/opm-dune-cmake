# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("opm-simulators" C CXX)

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the OPM cmake macros
include(OpmMacros)

find_package(opm-tests)
find_package(OpmOutputUtils)

# find the packages needed to compile the unit tests
find_package(Boost COMPONENTS unit_test_framework REQUIRED)

# read source files from CMakeLists_files.cmake, conditionally modify
# them, and add the library and create executables
opm_read_listsfile()

# this is quite a hack: these files should not have be added to the
# lists in the first place!
if (NOT MPI_FOUND)
  list(REMOVE_ITEM TEST_SOURCE_FILES
    tests/test_parallel_linearsolver.cpp
    tests/test_parallelistlinformation.cpp
    )
endif()

if (NOT PETSC_FOUND)
  list (REMOVE_ITEM MAIN_SOURCE_FILES
    opm/core/linalg/LinearSolverPetsc.cpp
    )
endif()

if (NOT SuiteSparse_FOUND)
  list (REMOVE_ITEM MAIN_SOURCE_FILES
    opm/core/linalg/call_umfpack.c
    opm/core/linalg/LinearSolverUmfpack.cpp
    tutorials/tutorial2.cpp
    tutorials/tutorial3.cpp
    tutorials/tutorial4.cpp
    )
endif()

opm_add_headers_library_and_executables("opmeclwells")

if(opm-tests_FOUND)
  include (${CMAKE_CURRENT_SOURCE_DIR}/compareECLFiles.cmake)
endif()

# the general-purpose ECL simulator ("ebos" == "&ecl &black-&oil &simulator)
opm_add_application(ebos
                    SOURCES ebos/ebos.cc
                    EXE_NAME ebos)

opm_add_application(ebos_plain
                    SOURCES ebos/ebos_plain.cc
                    EXE_NAME ebos_plain)

opm_add_application(ebos_solvent
                    SOURCES ebos/ebos_solvent.cc
                    EXE_NAME ebos_solvent)

opm_add_application(ebos_polymer
                    SOURCES ebos/ebos_polymer.cc
                    EXE_NAME ebos_polymer)

opm_add_application(ebos_thermal
                    SOURCES ebos/ebos_thermal.cc
                    EXE_NAME ebos_thermal)

opm_add_application(ebos_oilwater
                    SOURCES ebos/ebos_oilwater.cc
                    EXE_NAME ebos_oilwater)

opm_add_application(ebos_gasoil
                    SOURCES ebos/ebos_gasoil.cc
                    EXE_NAME ebos_gasoil)

add_custom_target(all_ebos)
add_dependencies(all_ebos "ebos")
add_dependencies(all_ebos "ebos_solvent")
add_dependencies(all_ebos "ebos_polymer")
add_dependencies(all_ebos "ebos_thermal")
add_dependencies(all_ebos "ebos_oilwater")
add_dependencies(all_ebos "ebos_gasoil")

if(EXISTS "${PROJECT_SOURCE_DIR}/ebos/ebos_femistl.cc")
opm_add_application(ebos_femistl
                    SOURCES ebos/ebos_femistl.cc
                    EXE_NAME ebos_femistl)

opm_add_application(ebos_fempetsc
                    SOURCES ebos/ebos_fempetsc.cc
                    EXE_NAME ebos_fempetsc)

add_dependencies(all_ebos "ebos_femistl")
add_dependencies(all_ebos "ebos_fempetsc")
endif()

opm_add_application(flow
  SOURCES
   flow/flow.cpp
   flow/flow_ebos_blackoil.cpp
   flow/flow_ebos_gasoil.cpp
   flow/flow_ebos_oilwater.cpp
   flow/flow_ebos_polymer.cpp
   flow/flow_ebos_solvent.cpp
   flow/flow_ebos_energy.cpp
   flow/flow_ebos_oilwater_polymer.cpp
   flow/flow_ebos_oilwater_polymer_injectivity.cpp)


opm_recusive_copy_testdata_to_builddir("tests/*.data" "tests/*.DATA" "tests/VFP*")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
