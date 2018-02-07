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

# Check if valgrind library is available or not.
find_package(Valgrind)

# export include flags for valgrind
set(HAVE_VALGRIND "${VALGRIND_FOUND}")
if(VALGRIND_FOUND)
  dune_register_package_flags(
    INCLUDE_DIRS "${VALGRIND_INCLUDE_DIR}")
endif()

# detect thread-level parallelism with OpenMP
option(ENABLE_OPENMP "Turn OpenMP on if it is available?" OFF)
if(ENABLE_OPENMP)
  find_package(OpenMP)

  if(OPENMP_FOUND)
    set(HAVE_OPENMP 1)
    dune_register_package_flags(
      COMPILE_OPTIONS "${OpenMP_CXX_FLAGS}"
      LIBRARIES "${OpenMP_CXX_FLAGS}")
  endif()
endif()

# add a work-around for the missing HAVE_PTHREAD config.h
# variable. the actual threads detection is done by dune-common.
if (THREADS_HAVE_PTHREAD_ARG)
  set(HAVE_PTHREAD 1)
endif()

# this is a hack to make config.h work as advertised
if(ecl_FOUND)
  set(HAVE_ERT 1)
endif()
