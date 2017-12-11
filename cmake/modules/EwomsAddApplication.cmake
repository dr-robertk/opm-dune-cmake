# add an application. the main difference to EwomsAddTest() is that
# applications are always compiled if CONDITION evaluates to true...
#
# EwomsAddApplication(AppName
#                     [EXE_NAME AppExecutableName]
#                     [CONDITION ConditionalExpression]
#                     [SOURCES SourceFile1 SourceFile2 ...])
macro(EwomsAddApplication AppName)
  opm_add_test(${AppName} ${ARGN} ALWAYS_ENABLE ONLY_COMPILE)
endmacro()
