# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests opm-common!
#

# since this is basically the whole point of the module we always want
# to enable the ECL stuff, thank you.
set(ENABLE_ECL_INPUT ON)
set(ENABLE_ECL_OUTPUT ON)
set(HAVE_ECL_INPUT ON)
set(HAVE_ECL_OUTPUT ON)

# if ecl_DIR was specified then add this to the search path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ecl_DIR})

# if ecl_ROOT was specified then add this to the search path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ecl_ROOT})

find_package(ecl REQUIRED)
if(NOT TARGET ecl)
  message(FATAL_ERROR "libecl not found!")
endif()

# Need to grab from target to enable transitional depends
get_target_property(ecl_INCLUDE_DIRS ecl INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(ecl_LIBRARIES ecl INTERFACE_LINK_LIBRARIES)
get_target_property(ecl_lib ecl LOCATION)
set(ecl_LIBRARIES ${ecl_lib} ${ecl_LIBRARIES})
set(ecl_FOUND 1)

dune_register_package_flags(
  LIBRARIES "${ecl_LIBRARIES}"
  INCLUDE_DIRS "${ecl_INCLUDE_DIRS}")

# handle boost
find_package(Boost COMPONENTS regex system filesystem REQUIRED)
dune_register_package_flags(
  LIBRARIES "${Boost_LIBRARIES}"
  INCLUDE_DIRS "${Boost_INCLUDE_DIRS}")

# this is a hack that is required for the non-standard locations of
# header files in opm-common
if (DEFINED opm-common_SOURCE_DIR)
  dune_register_package_flags(
    INCLUDE_DIRS
    "${opm-common_SOURCE_DIR}/opm/json"
    "${opm-common_SOURCE_DIR}/external/cjson")
else()
  foreach(CAND
      "${opm-common_PREFIX}/opm/json"
      "${opm-common_PREFIX}/external/cjson"
      "${opm-common_DIR}/include")

    if (IS_DIRECTORY "${CAND}")
      dune_register_package_flags(INCLUDE_DIRS "${CAND}")
    endif()

  endforeach()
endif()
