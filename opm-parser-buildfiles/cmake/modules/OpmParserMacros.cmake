# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests opm-parser!
#

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
# header files in opm-parser
if (DEFINED opm-parser_SOURCE_DIR)
  dune_register_package_flags(
    INCLUDE_DIRS
    "${opm-parser_SOURCE_DIR}/lib/json/include"
    "${opm-parser_SOURCE_DIR}/external/cjson"
    "${opm-parser_SOURCE_DIR}/lib/eclipse/include")
else()
  foreach(CAND
      "${opm-parser_PREFIX}/lib/json/include"
      "${opm-parser_PREFIX}/external/cjson"
      "${opm-parser_PREFIX}/lib/eclipse/include"
      "${opm-parser_DIR}/include")

    if (IS_DIRECTORY "${CAND}")
      dune_register_package_flags(INCLUDE_DIRS "${CAND}")
    endif()

  endforeach()
endif()
