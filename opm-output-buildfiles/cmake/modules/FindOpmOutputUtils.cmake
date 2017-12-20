# - Try to find the utilities that come with opm-output
#
#  OPM_OUTPUT_UTILS_FOUND  - the opm-output utilities are available
#  COMPARE_ECL_COMMAND     - the full path to the compareECL executable
#  COMPARE_SUMMARY_COMMAND - the full path to the compareSummary executable
#
#  Usage:
#  find_package(OpmOutputUtils)

if (EXISTS "${opm-output_DIR}/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-output_DIR}/compareSummary")
elseif (EXISTS "${opm-output_DIR}/bin/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-output_DIR}/bin/compareSummary")
elseif (EXISTS "${opm-output_PREFIX}/bin/compareSummary")
  set(COMPARE_SUMMARY_COMMAND "${opm-output_PREFIX}/bin/compareSummary")
else()
  message("The compareSummary utility was not found!")
endif()

if (EXISTS "${opm-output_DIR}/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-output_DIR}/compareECL")
elseif (EXISTS "${opm-output_DIR}/bin/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-output_DIR}/bin/compareECL")
elseif (EXISTS "${opm-output_PREFIX}/bin/compareECL")
  set(COMPARE_ECL_COMMAND "${opm-output_PREFIX}/bin/compareECL")
else()
  message("The compareECL utility was not found!")
endif()

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  OPM_OUTPUT_UTILS
  "The opm-output utilities could not be found. Probably you need to install opm-output." COMPARE_ECL_COMMAND COMPARE_SUMMARY_COMMAND)

# stop the dune build system from complaining if the opm-output
# utilities were found
if (OPM_OUTPUT_UTILS_FOUND)
  set(OpmOutputUtils_FOUND 1)
endif()
