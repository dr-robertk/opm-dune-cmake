# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0)

# set up project and specify the minimum cmake version
project("opm-upscaling" C CXX)

option(INSTALL_BENCHMARKS "Install benchmark applications?" OFF)

# Sibling build
option(SIBLING_SEARCH "Search for other modules in sibling directories?" ON)
if(SIBLING_SEARCH)
  # guess the sibling dir
  get_filename_component(_leaf_dir_name ${PROJECT_BINARY_DIR} NAME)
  get_filename_component(_parent_full_dir ${PROJECT_BINARY_DIR} DIRECTORY)
  get_filename_component(_parent_dir_name ${_parent_full_dir} NAME)
  get_filename_component(_modules_dir ${_parent_full_dir} DIRECTORY)
  foreach(MOD dune-common dune-geometry dune-grid dune-localfunctions dune-istl opm-common libecl opm-parser opm-grid opm-material opm-core)
    # do not overwrite the location of a module if it was explicitly
    # specified by the user
    if(${MOD}_DIR)
      continue()
    endif()

    # Try various possible locations for the build directory of the dependency
    foreach(BUILD_DIR "${_leaf_dir_name}" "build-cmake" "build" "../${MOD}-build" "../build-${MOD}" "../build" ".")
      if(EXISTS "${_modules_dir}/${MOD}/${BUILD_DIR}/${MOD}-config.cmake")
        set(${MOD}_DIR ${_modules_dir}/${MOD}/${BUILD_DIR})
        break()
      endif()
    endforeach()
  endforeach()
endif()

if(dune-common_DIR AND NOT IS_DIRECTORY ${dune-common_DIR})
  message(WARNING "Value ${dune-common_DIR} passed to variable"
    " dune-common_DIR is not a directory")
endif()
if(opm-common_DIR AND NOT IS_DIRECTORY ${opm-common_DIR})
  message(WARNING "Value ${opm-common_DIR} passed to variable"
    " opm-common_DIR is not a directory")
endif()

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
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH}
  "${PROJECT_SOURCE_DIR}/cmake/modules")

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the OPM cmake macros
include(OpmMacros)

# find the packages needed to compile the module
find_package(Boost COMPONENTS unit_test_framework iostreams REQUIRED)

# make sure that the HAVE_CONFIG_H C macro evaluates to one instead of
# being only defined
get_property(CD_LIST DIRECTORY "." PROPERTY COMPILE_DEFINITIONS)
list(REMOVE_ITEM CD_LIST "HAVE_CONFIG_H")
list(APPEND CD_LIST "HAVE_CONFIG_H=1")
set_property(DIRECTORY "." PROPERTY COMPILE_DEFINITIONS "${CD_LIST}")

# we want all features detected by the build system to be enabled,
# thank you!
dune_enable_all_packages()

# add source files from CMakeLists_files.cmake to
# library libopmcore.a and create executables
opm_add_headers_library_and_executables("opmupscaling")

# we need to explicitly add upscale_relperm_benchmark because the that
# target gets defined via the ADDITIONAL_SOURCE_FILES list, but this
# is currently unhandled by the
# opm_add_headers_library_and_executables() macro.
opm_add_application(upscale_relperm_benchmark SOURCES benchmarks/upscale_relperm_benchmark.cpp
  LIBRARIES "${Boost_LIBRARIES}" INCLUDE_DIRS "${Boost_INCLUDE_DIRS}")

# setup extra tests (using helper binaries)
include (${CMAKE_CURRENT_SOURCE_DIR}/compareUpscaling.cmake)

# encode test cases so they can be embedded in the benchmark executables
include(EmbedCases.cmake)

# Setup static benchmarks
include(OpmStaticTargets)
opm_from_git(${PROJECT_SOURCE_DIR} benchmarks ${VCS_SHA1} benchmarks)
add_dependencies(benchmarks-static opm-grid-static)

# Copy static benchmarks to main project binary directory
foreach(benchmark ${OPM_BENCHMARKS})
  add_custom_command(TARGET benchmarks-static POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/static/benchmarks/src/benchmarks-static-build/bin/${benchmark}
                                                      ${CMAKE_BINARY_DIR}/bin/${benchmark}-static)
	if(INSTALL_BENCHMARKS)
		install(TARGETS ${benchmark} DESTINATION bin)
	endif()
endforeach()

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
