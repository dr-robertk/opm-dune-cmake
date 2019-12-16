# - Try to find the an un-installed version of the opm-tests module
# this rule will only do something if a properly installed version
# of opm-tests has not been found before.
#
#  opm-tests_FOUND     - the opm-tests module is available
#  opm-tests_DIR       - path to the toplevel directory of the plain opm-tests tree
#  opm-tests_INSTALLED - Specifies whether the opm-tests module was
#                       installed on the system or is a plain tree
#
#  Usage:
#  find_package(PlainOpmTests)

if (opm-tests_FOUND)
  set(opm-tests_INSTALLED TRUE)
else()
  if (opm-tests_DIR AND EXISTS "${opm-tests_DIR}/spe1/SPE1CASE2.DATA")
    set(opm-tests_FOUND TRUE)
    set(opm-tests_INSTALLED FALSE)
    set(opm-tests_DIR "${opm-tests_DIR}")
  elseif (OPM_TESTS_DIR AND EXISTS "${OPM_TESTS_DIR}/spe1/SPE1CASE2.DATA")
    set(opm-tests_FOUND TRUE)
    set(opm-tests_INSTALLED FALSE)
    set(opm-tests_DIR "${OPM_TESTS_DIR}")
  elseif (opm-tests_ROOT AND EXISTS "${opm-tests_ROOT}/spe1/SPE1CASE2.DATA")
    set(opm-tests_FOUND TRUE)
    set(opm-tests_INSTALLED FALSE)
    set(opm-tests_DIR "${opm-tests_ROOT}")
  elseif (OPM_TESTS_ROOT AND EXISTS "${OPM_TESTS_ROOT}/spe1/SPE1CASE2.DATA")
    set(opm-tests_FOUND TRUE)
    set(opm-tests_INSTALLED FALSE)
    set(opm-tests_DIR "${OPM_TESTS_ROOT}")
  else()
    set(opm-tests_FOUND FALSE)
    set(opm-tests_INSTALLED FALSE)
    set(opm-tests_DIR NOTFOUND)
  endif()
endif()

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  opm-tests
  "opm-tests could not be found. You can set opm-tests_DIR to rectify this." opm-tests_FOUND)

# stop the dune build system from complaining if a suitable opm-tests
# instance was found
if (opm-tests_DIR)
  set(PlainOpmTests_FOUND 1)
  set(OPM_TESTS_ROOT "${opm-tests_DIR}")
  set(HAVE_OPM_TESTS TRUE)
endif()
