# - Try to find the utilities that come with opm-common
#
#  OPM_OUTPUT_UTILS_FOUND  - the opm-common utilities are available
#  COMPARE_ECL_COMMAND     - the full path to the compareECL executable
#  COMPARE_SUMMARY_COMMAND - the full path to the compareSummary executable
#
#  Usage:
#  find_package(OpmOutputUtils)

if (EXISTS "${opm-common_DIR}/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-common_DIR}/compareSummary")
elseif (EXISTS "${opm-common_DIR}/bin/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-common_DIR}/bin/compareSummary")
elseif (EXISTS "${opm-common_PREFIX}/bin/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-common_PREFIX}/bin/compareSummary")
else()
  message("The compareSummary utility was not found!")
endif()

if (EXISTS "${opm-common_DIR}/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-common_DIR}/compareECL")
elseif (EXISTS "${opm-common_DIR}/bin/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-common_DIR}/bin/compareECL")
elseif (EXISTS "${opm-common_PREFIX}/bin/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-common_PREFIX}/bin/compareECL")
else()
  message("The compareECL utility was not found!")
endif()

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  OPM_OUTPUT_UTILS
  "The opm-common utilities could not be found. Probably you need to install opm-common." COMPARE_ECL_COMMAND COMPARE_SUMMARY_COMMAND)

# stop the dune build system from complaining if the opm-common
# utilities were found
if (OPM_OUTPUT_UTILS_FOUND)
  set(OpmOutputUtils_FOUND 1)
endif()
