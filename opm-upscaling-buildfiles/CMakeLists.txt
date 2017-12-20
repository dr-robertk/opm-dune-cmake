# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0)

# set up project and specify the minimum cmake version
project("opm-upscaling" C CXX)

option(INSTALL_BENCHMARKS "Install benchmark applications?" OFF)

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
