# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests opm-common!
#

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

# Check if valgrind library is available or not.
find_package(Valgrind)

# export include flags for valgrind
set(HAVE_VALGRIND "${VALGRIND_FOUND}")
if(VALGRIND_FOUND)
  dune_register_package_flags(
    INCLUDE_DIRS "${VALGRIND_INCLUDE_DIR}")
endif()

# add a work-around for the missing HAVE_PTHREAD config.h
# variable. the actual threads detection is done by dune-common.
if (THREADS_HAVE_PTHREAD_ARG)
  set(HAVE_PTHREAD 1)
endif()
