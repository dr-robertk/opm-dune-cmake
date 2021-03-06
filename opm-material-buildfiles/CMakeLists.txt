# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("opm-material" C CXX)

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the additional generic OPM cmake macros
include(OpmMacros)

# recursively mark all header files beneath the "opm" directory for
# installation.
opm_recusive_export_all_headers("opm")

# the cmake modules get a special treatment
opm_export_cmake_modules()

# we want all features detected by the build system to be enabled,
# thank you!
dune_enable_all_packages()

# add all unit tests
opm_add_test(test_blackoilfluidstate)
opm_add_test(test_ConditionalStorage)
opm_add_test(test_eclblackoilfluidsystem CONDITION opm-common_FOUND)
opm_add_test(test_eclblackoilpvt CONDITION opm-common_FOUND)
opm_add_test(test_eclmateriallawmanager CONDITION opm-common_FOUND)
opm_add_test(test_fluidmatrixinteractions)
opm_add_test(test_pengrobinson)
opm_add_test(test_densead)
opm_add_test(test_ncpflash)
opm_add_test(test_spline)
opm_add_test(test_tabulation)
opm_add_test(test_2dtables)
opm_add_test(test_components)
opm_add_test(test_fluidsystems)
opm_add_test(test_immiscibleflash)

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
