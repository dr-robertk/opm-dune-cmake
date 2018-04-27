# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("opm-common" C CXX)

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
find_package(Boost COMPONENTS regex system filesystem unit_test_framework REQUIRED)

# find the opm-tests module
find_package(opm-tests)

# we want all features detected by the build system to be enabled,
# thank you!
dune_enable_all_packages()

# Keyword generator
include(GenerateKeywords.cmake)

# Append generated sources
list(APPEND MAIN_SOURCE_FILES ${PROJECT_BINARY_DIR}/ParserKeywords.cpp)

# read in the file lists of CMakeLists_files.txt
opm_read_listsfile()

# the file comparison utilities are used for the testing of
# opm-simulators, so we build them regardless of whether
# BUILD_APPLICATIONS is set or not.
if(NOT BUILD_APPLICATIONS)
  add_custom_target(opm-output-utilities ALL)
  add_dependencies("opm-output-utilities" compareECL compareSummary)
endif()

add_definitions(-DBOOST_TEST_DYN_LINK=1)

opm_add_headers_library_and_executables("opmcommon")

target_link_libraries("opmcommon" "${Boost_REGEX_LIBRARIES}" "${Boost_SYSTEM_LIBRARIES}" "${Boost_FILESYSTEM_LIBRARIES}")
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/include")
include_directories("${PROJECT_BINARY_DIR}/include")

include(ExtraTests.cmake)

if(TARGET opmi)
  target_link_libraries(opmi ${Boost_LIBRARIES})
endif()

opm_recusive_copy_testdata("tests/*.data")

opm_recusive_copy_testdata_to_builddir("tests/*.param" "tests/*.DATA")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
