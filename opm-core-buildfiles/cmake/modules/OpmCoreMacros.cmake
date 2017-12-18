# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests opm-core!
#

# Check if PETSc numerical library is available or not. TODO: This
# probably does not belong here. (That said, opm-core is supposed to
# have a meeting with the butcher soon.)
find_package(PETSc)

# export the library and include flags for PETSc
set(HAVE_PETSC "${PETSC_FOUND}")
if(PETSC_FOUND)
  dune_register_package_flags(
    LIBRARIES "${PETSC_LIBRARIES}"
    INCLUDE_DIRS "${PETSC_INCLUDES}")
endif()
