########################################
# use DUNE's build system to build OPM
########################################
cmake_minimum_required(VERSION 3.0)

#message("build dir = ${CMAKE_BINARY_DIR}")
if(DEFINED ENV{ORIGINAL_PROJECT_SOURCE_DIR})
  list(APPEND CMAKE_MODULE_PATH $ENV{ORIGINAL_PROJECT_SOURCE_DIR})
  #  set(CMAKE_BINARY_DIR $ENV{ORIGINAL_PROJECT_SOURCE_DIR})
endif()

get_filename_component(MODULE_NAME ${CMAKE_SOURCE_DIR} NAME)
message("Building module ${MODULE_NAME} using DUNE build system.")

# set up project and specify the minimum cmake version
project("${MODULE_NAME}" C CXX)

# Sibling build
option(SIBLING_SEARCH "Search for other modules in sibling directories?" ON)

# guess the sibling dir
get_filename_component(_leaf_dir_name ${PROJECT_BINARY_DIR} NAME)
get_filename_component(_parent_full_dir ${PROJECT_BINARY_DIR} DIRECTORY)
get_filename_component(_parent_dir_name ${_parent_full_dir} NAME)
get_filename_component(_modules_dir ${_parent_full_dir} DIRECTORY)
foreach(MOD dune-common dune-geometry dune-grid dune-localfunctions dune-istl opm-common libecl opm-parser opm-grid opm-data opm-core opm-output opm-material ewoms)
  # do not overwrite the location of a module if it was explicitly
  # specified by the user
  if(${MOD}_DIR)
    continue()
  endif()

  # Try various possible locations for the build directory of the dependency
  foreach(BUILD_DIR "${_leaf_dir_name}" "build-cmake" "build" "../${MOD}-build" "../build-${MOD}" "../build" ".")
    if(EXISTS "${_modules_dir}/${MOD}/${BUILD_DIR}/${MOD}-config.cmake")
      set(${MOD}_DIR ${_modules_dir}/${MOD}/${BUILD_DIR} PARENT_SCOPE)
      break()
    endif()
  endforeach()
endforeach()

if(dune-common_DIR AND NOT IS_DIRECTORY ${dune-common_DIR})
  message(WARNING "Value ${dune-common_DIR} passed to variable"
    " dune-common_DIR is not a directory")
endif()
if(opm-common_DIR AND NOT IS_DIRECTORY ${opm-common_DIR})
  message(WARNING "Value ${opm-common_DIR} passed to variable"
    " opm-common_DIR is not a directory")
endif()

# for ewoms
set(OPM_GRID_FOUND ${opm_grid_FOUND})
set(OPM_CORE_FOUND ${opm_core_FOUND})
set(OPM_PARSER_FOUND ${opm_parser_FOUND})

#message("opm grid = ${OPM_GRID_FOUND} ${opm_grid_FOUND}")

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

# include the OPM cmake macros
include(OpmMacros)

opm_create_pc_in_file("${MODULE_NAME}")
opm_create_config_h_cmake_file("${MODULE_NAME}")

# start a dune project with information from dune.module
dune_project()

find_package(PlainOpmData)
find_package(OpmOutputUtils)

# add source files from CMakeLists_files.cmake to library and create executables
opm_add_headers_library_and_executables( "${MODULE_NAME}")

# set found flags for ebos exec
if (${MODULE_NAME} STREQUAL "ewoms")
  set(OPM_CORE_FOUND TRUE)
  set(OPM_GRID_FOUND TRUE)
  set(OPM_PARSER_FOUND TRUE)
endif ()

# download Eigen if user doesn't have the correct version
if (${MODULE_NAME} STREQUAL "opm-simulators")
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
endif ()

if(opm-data_FOUND)
  include (${CMAKE_CURRENT_SOURCE_DIR}/compareECLFiles.cmake)
endif()

opm_recusive_copy_testdata("tests/*.param" "tests/*.data" "tests/*.DATA" "tests/VFP*")

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
