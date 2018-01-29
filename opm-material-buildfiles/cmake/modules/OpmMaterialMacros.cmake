# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests opm-material!
#

# support for quadruple precision math
find_package(Quadmath)
if(QUADMATH_FOUND)
  set(HAVE_QUAD 1)
  dune_register_package_flags(
    LIBRARIES "${QUADMATH_LIBRARIES}")
endif()
