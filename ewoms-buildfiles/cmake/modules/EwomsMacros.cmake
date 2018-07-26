# .. cmake_module::
#
# This module's content is executed whenever a Dune module requires or
# suggests ewoms!
#

# PAPI this is unused in the vanilla code, but when performance
# measurement it is handy to specify PAPI probes without switching the
# branch of the build system repository.
find_package(PAPI)
