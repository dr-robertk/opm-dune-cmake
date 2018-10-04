# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("chiwoms" C CXX)

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the additional generic OPM cmake macros
include(OpmMacros)

# recursively mark all header files beneath the "src"
# directory for installation.
#opm_recusive_export_all_headers("src")

# the cmake modules get a special treatment
opm_export_cmake_modules()

# we want all features detected by the build system to be enabled,
# thank you!
dune_enable_all_packages()

# copy the data files (i.e., grid files, etc) needed to run the unit
# tests from the source to the build directory
#opm_recusive_copy_testdata_to_builddir("tests/data/*" "tests/referencesolutions/*")
#file(COPY "${CMAKE_SOURCE_DIR}/tests/data/" DESTINATION "${CMAKE_BINARY_DIR}/data")

# extract the code name of the current ewoms revision from the
# corresponding dune.module file
set(chiwoms_DUNE_MODULE_FILE "${CMAKE_SOURCE_DIR}/dune.module")
if(NOT EXISTS "${chiwoms_DUNE_MODULE_FILE}")
  message(FATAL_ERROR "File '${chiwoms_DUNE_MODULE_FILE}' does not exist!")
endif()

extract_line("Codename:" CHIWOMS_VERSION_CODENAME "${chiwoms_DUNE_MODULE_FILE}")
if(CHIWOMS_VERSION_CODENAME)
  set(CHIWOMS_VERSION_STRING "${CHIWOMS_VERSION} (\"${CHIWOMS_VERSION_CODENAME}\")")
  string(REPLACE "\"" "\\\"" CHIWOMS_VERSION_STRING "${CHIWOMS_VERSION_STRING}")
else()
  set(CHIWOMS_VERSION_STRING "${CHIWOMS_VERSION}")
endif()

# the general-purpose ECL simulator ("ebos" == "&ecl &black-&oil &simulator)
opm_add_application(chiwoms
                    SOURCES
                      src/chiwoms.cpp
                      src/co2_c8_dens.c
                      src/co2_c8_enth.c
                      src/co2_c8_visc.c
                      src/padua.c
                    EXE_NAME chiwoms)

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
