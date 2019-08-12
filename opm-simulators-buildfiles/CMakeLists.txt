# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("opm-simulators" C CXX)

option(BUILD_FLOW "Build the production oriented flow simulator?" OFF)
option(BUILD_EBOS "Build the research oriented ebos simulator?" ON)
option(BUILD_EBOS_EXTENSIONS "Build the variants for various extensions of ebos by default?" OFF)
option(BUILD_EBOS_DEBUG_EXTENSIONS "Build the debugging variants of ebos by default?" OFF)

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

set(MEBOS_TARGETS "")
foreach(EXT blackoil solvent polymer foam gasoil oilwater thermal)
  add_library(ebos_lib${EXT} OBJECT EXCLUDE_FROM_ALL ebos/ebos_${EXT}.cc)
  target_include_directories(ebos_lib${EXT} PRIVATE ${ecl_INCLUDE_DIRS})
  list(APPEND MEBOS_TARGETS $<TARGET_OBJECTS:ebos_lib${EXT}>)
endforeach()

# blackoil ebos
opm_add_application(ebos
                    DEFAULT_ENABLE_IF ${BUILD_EBOS}
                    SOURCES ebos/ebos_main.cc $<TARGET_OBJECTS:ebos_libblackoil>)

# add specialized ebos simulators with some black-oil extension
foreach(EXT solvent polymer foam gasoil oilwater thermal)
  opm_add_application(ebos_${EXT}
    DEFAULT_ENABLE_IF ${BUILD_EBOS_EXTENSIONS}
    SOURCES ebos/ebos_${EXT}_main.cc $<TARGET_OBJECTS:ebos_lib${EXT}>)
endforeach()

# multiplexed ebos with most of the above model extensions
opm_add_application(mebos
                    DEFAULT_ENABLE_IF ${BUILD_EBOS_EXTENSIONS}
                    SOURCES ebos/mebos_main.cc ${MEBOS_TARGETS})

######
# ebos variants for debugging
######

# variant that uses the default ewoms linear solver and the toy ECL well model
opm_add_application(ebos_plain
                    DEFAULT_ENABLE_IF ${BUILD_EBOS_DEBUG_EXTENSIONS}
                    SOURCES ebos/ebos_plain.cc
                    EXE_NAME ebos_plain)

# variant that uses different phase and component indices than the others
opm_add_application(ebos_altidx
                    DEFAULT_ENABLE_IF ${BUILD_EBOS_DEBUG_EXTENSIONS}
                    SOURCES ebos/ebos_altidx.cc
                    EXE_NAME ebos_altidx)

add_custom_target(all_ebos)
add_dependencies(all_ebos "ebos")
add_dependencies(all_ebos "mebos")
add_dependencies(all_ebos "ebos_solvent")
add_dependencies(all_ebos "ebos_polymer")
add_dependencies(all_ebos "ebos_foam")
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
  DEFAULT_ENABLE_IF ${BUILD_FLOW}
  SOURCES
   flow/flow.cpp
   flow/flow_ebos_blackoil.cpp
   flow/flow_ebos_gasoil.cpp
   flow/flow_ebos_oilwater.cpp
   flow/flow_ebos_foam.cpp
   flow/flow_ebos_polymer.cpp
   flow/flow_ebos_solvent.cpp
   flow/flow_ebos_energy.cpp
   flow/flow_ebos_oilwater_polymer.cpp
   flow/flow_ebos_oilwater_polymer_injectivity.cpp)

opm_add_application(flow_blackoil_dunecpr
  DEFAULT_ENABLE_IF ${BUILD_FLOW}
  SOURCES
  flow/flow_blackoil_dunecpr.cpp
  )

if(TARGET flow)
  add_dependencies(all_tests "flow")
  add_dependencies(test-suite "flow")
  add_dependencies(build_tests "flow")
endif()


opm_recusive_copy_testdata_to_builddir("tests/*.data" "tests/*.DATA" "tests/VFP*")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
