# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

cmake_minimum_required(VERSION 3.0.1)

# set up project and specify the minimum cmake version
project("opm-models" C CXX)

# find the build system (i.e., dune-common) and set cmake's module path
find_package(dune-common REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${dune-common_MODULE_PATH})

# include the dune macros
include(DuneMacros)

# start a dune project with information from dune.module
dune_project()

# include the additional generic OPM cmake macros
include(OpmMacros)

# recursively mark all header files beneath the "opm-models" directory for
# installation.
opm_recusive_export_all_headers("opm-models")

# the cmake modules get a special treatment
opm_export_cmake_modules()

# we want all features detected by the build system to be enabled,
# thank you!
dune_enable_all_packages()

find_package(OpmOutputUtils)

# copy the data files (i.e., grid files, etc) needed to run the unit
# tests from the source to the build directory
opm_recusive_copy_testdata_to_builddir("tests/data/*")
file(COPY "${CMAKE_SOURCE_DIR}/tests/data/" DESTINATION "${CMAKE_BINARY_DIR}/data")

# extract the code name of the current opm-models revision from the
# corresponding dune.module file
set(opm-models_DUNE_MODULE_FILE "${CMAKE_SOURCE_DIR}/dune.module")
if(NOT EXISTS "${opm-models_DUNE_MODULE_FILE}")
  message(FATAL_ERROR "File '${opm-models_DUNE_MODULE_FILE}' does not exist!")
endif()

extract_line("Codename:" OPM_MODELS_VERSION_CODENAME "${opm-models_DUNE_MODULE_FILE}")
if(OPM_MODELS_VERSION_CODENAME)
  set(OPM_MODELS_VERSION_STRING "${OPM_MODELS_VERSION} (\"${OPM_MODELS_VERSION_CODENAME}\")")
  string(REPLACE "\"" "\\\"" OPM_MODELS_VERSION_STRING "${OPM_MODELS_VERSION_STRING}")
else()
  set(OPM_MODELS_VERSION_STRING "${OPM_MODELS_VERSION}")
endif()

# eWoms comes with its custom test driver script
opm_set_test_driver("${PROJECT_SOURCE_DIR}/bin/runtest.sh" "--simulation")

# the ART to DGF file format conversion utility
opm_add_application(art2dgf
                    SOURCES art2dgf/art2dgf.cc
                    EXE_NAME art2dgf)

add_dependencies(test-suite art2dgf)

#opm_add_test(art2dgf
#  NO_COMPILE
#  DRIVER_ARGS --plain
#  TEST_ARGS "data/fracture-raw.art")

# add targets for all tests of the models. we add the water-air test
# first because it take longest and so that we don't have to wait for
# them as long for parallel test runs
opm_add_test(waterair_pvs_ni
             TEST_ARGS --grid-global-refinements=1)

opm_add_test(lens_immiscible_vcfv_ad
             TEST_ARGS --end-time=3000)

opm_add_test(lens_immiscible_vcfv_fd
             TEST_ARGS --end-time=3000)

opm_add_test(lens_immiscible_ecfv_ad
             TEST_ARGS --end-time=3000)

# this test is identical to the simulation of the lens problem that
# uses the element centered finite volume discretization in
# conjunction with automatic differentiation
# (lens_immiscible_ecfv_ad). The only difference is that it uses
# multiple compile units in order to ensure that eWoms code can be
# used within libraries that use the same type tag within multiple
# compile units.
opm_add_test(lens_immiscible_ecfv_ad_mcu
             ONLY_COMPILE
             SOURCES
                tests/lens_immiscible_ecfv_ad_cu1.cc
                tests/lens_immiscible_ecfv_ad_cu2.cc
                tests/lens_immiscible_ecfv_ad_main.cc)

opm_add_test(finger_immiscible_ecfv
             CONDITION dune-alugrid_FOUND)

opm_add_test(finger_immiscible_vcfv
             CONDITION dune-alugrid_FOUND)

opm_add_test(finger_immiscible_ecfv_adaptive
             EXE_NAME finger_immiscible_ecfv
             CONDITION dune-alugrid_FOUND AND dune-fem_FOUND
             NO_COMPILE
             TEST_ARGS --enable-grid-adaptation=true --end-time=25e3)

if(EXISTS "${PROJECT_SOURCE_DIR}/tests/fivespot_immiscible_sofv_ad.cc")
  opm_add_test(fivespot_immiscible_sofv_ad)
endif()

if(EXISTS "${PROJECT_SOURCE_DIR}/tests/transport_immiscible_sofv_fd.cc")
  opm_add_test(transport_immiscible_sofv_fd)
endif()

if(EXISTS "${PROJECT_SOURCE_DIR}/tests/transport_immiscible_sofv_ad.cc")
  opm_add_test(transport_immiscible_sofv_ad)
endif()

if(EXISTS "${PROJECT_SOURCE_DIR}/tests/transport_immiscible_weno_ad.cc")
  opm_add_test(transport_immiscible_weno_ad)
endif()

foreach(tapp co2injection_flash_ni_vcfv
             co2injection_flash_ni_ecfv
             co2injection_flash_vcfv
             co2injection_flash_ecfv
             co2injection_ncp_ni_vcfv
             co2injection_pvs_ni_vcfv
             co2injection_ncp_vcfv
             co2injection_pvs_vcfv
             co2injection_immiscible_ni_vcfv
             co2injection_immiscible_vcfv
             co2injection_immiscible_ecfv
             co2injection_ncp_ecfv
             co2injection_pvs_ecfv
             co2injection_immiscible_ni_ecfv
             co2injection_ncp_ni_ecfv
             co2injection_pvs_ni_ecfv
             powerinjection_forchheimer_fd
             powerinjection_forchheimer_ad
             powerinjection_darcy_fd
             powerinjection_darcy_ad
             cuvette_pvs
             infiltration_pvs
             lens_richards_vcfv
             lens_richards_ecfv
             obstacle_immiscible
             obstacle_ncp
             obstacle_pvs
             outflow_pvs
             diffusion_flash
             diffusion_ncp
             diffusion_pvs
             groundwater_immiscible)
  opm_add_test(${tapp})
endforeach()

opm_add_test(reservoir_blackoil_vcfv TEST_ARGS --end-time=8750000)
opm_add_test(reservoir_blackoil_ecfv TEST_ARGS --end-time=8750000)
opm_add_test(reservoir_ncp_vcfv TEST_ARGS --end-time=8750000)
opm_add_test(reservoir_ncp_ecfv TEST_ARGS --end-time=8750000)

# a test which ensures that black-oil specific fluid state used by the
# black-oil model conforms to the generic fluid state API.
#opm_add_test(test_blackoilfluidstate DRIVER_ARGS --plain)

opm_add_test(fracture_discretefracture
             CONDITION dune-alugrid_FOUND
             TEST_ARGS --end-time=400)

opm_add_test(test_propertysystem
             DRIVER_ARGS --plain)

opm_add_test(test_quadrature
             DRIVER_ARGS --plain)

# test for the parallelization of the element centered finite volume
# discretization (using the non-isothermal NCP model and the parallel
# AMG linear solver)
opm_add_test(co2injection_ncp_ni_ecfv_parallel
             EXE_NAME co2injection_ncp_ni_ecfv
             NO_COMPILE
             PROCESSORS 4
             CONDITION MPI_FOUND
             DRIVER_ARGS --parallel-simulation=4)

# test for the parallelization of the vertex centered finite volume
# discretization (using BiCGSTAB + ILU0)
opm_add_test(obstacle_immiscible_parallel
             EXE_NAME obstacle_immiscible
             NO_COMPILE
             PROCESSORS 4
             CONDITION MPI_FOUND
             DRIVER_ARGS --parallel-simulation=4
             TEST_ARGS --end-time=1 --initial-time-step-size=1)

# test for the parallel AMG linear solver using the vertex centered
# finite volume discretization
opm_add_test(lens_immiscible_vcfv_fd_parallel
             EXE_NAME lens_immiscible_vcfv_fd
             NO_COMPILE
             PROCESSORS 4
             CONDITION MPI_FOUND
             DRIVER_ARGS --parallel-simulation=4
             TEST_ARGS --end-time=250 --initial-time-step-size=250)

opm_add_test(lens_immiscible_vcfv_ad_parallel
             EXE_NAME lens_immiscible_vcfv_ad
             NO_COMPILE
             PROCESSORS 4
             CONDITION ${MPI_FOUND}
             DRIVER_ARGS --parallel-simulation=4
             TEST_ARGS --end-time=250 --initial-time-step-size=250)

opm_add_test(lens_immiscible_ecfv_ad_parallel
             EXE_NAME lens_immiscible_ecfv_ad
             NO_COMPILE
             PROCESSORS 4
             CONDITION MPI_FOUND
             DRIVER_ARGS --parallel-simulation=4
             TEST_ARGS --end-time=250 --initial-time-step-size=250)

opm_add_test(obstacle_immiscible_parameters
             EXE_NAME obstacle_immiscible
             NO_COMPILE
             DEPENDS obstacle_immiscible
             DRIVER_ARGS --parameters)

opm_add_test(obstacle_pvs_restart
             EXE_NAME obstacle_pvs
             NO_COMPILE
             DEPENDS obstacle_pvs
             DRIVER_ARGS --restart
             TEST_ARGS --pvs-verbosity=2 --end-time=30000)

opm_add_test(tutorial1
             SOURCES tutorial/tutorial1.cc)

opm_add_test(test_tasklets DRIVER_ARGS --plain)

# finalize the dune project, e.g. generating config.h etc.
finalize_dune_project(GENERATE_CONFIG_H_CMAKE)
