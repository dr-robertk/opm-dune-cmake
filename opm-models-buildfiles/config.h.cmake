/* begin opm-models
   put the definitions for config.h specific to
   your project here. Everything above will be
   overwritten
*/
/* begin private */
/* Name of package */
#define PACKAGE "@DUNE_MOD_NAME@"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "@DUNE_MAINTAINER@"

/* Define to the full name of this package. */
#define PACKAGE_NAME "@DUNE_MOD_NAME@"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "@DUNE_MOD_NAME@ @DUNE_MOD_VERSION@"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "@DUNE_MOD_NAME@"

/* Define to the home page for this package. */
#define PACKAGE_URL "@DUNE_MOD_URL@"

/* Define to the version of this package. */
#define PACKAGE_VERSION "@DUNE_MOD_VERSION@"

/* end private */

/* Specify if the PAPI performance measurement library is available */
#cmakedefine HAVE_PAPI 1

/* Specify if the HWLOC process binding library */
#cmakedefine HAVE_HWLOC 1

/* Define to the version of opm-models */
#define OPM_MODELS_VERSION "${OPM_MODELS_VERSION_STRING}"

/* Define to the major version of opm-models */
#define OPM_MODELS_VERSION_MAJOR ${OPM_MODELS_VERSION_MAJOR}

/* Define to the minor version of opm-models */
#define OPM_MODELS_VERSION_MINOR ${OPM_MODELS_VERSION_MINOR}

/* Define to the revision of opm-models */
#define OPM_MODELS_VERSION_REVISION ${OPM_MODELS_VERSION_REVISION}

/* Define to the codename of opm-models */
#define OPM_MODELS_VERSION_CODENAME "${OPM_MODELS_VERSION_CODENAME}"

/* begin bottom */

/* end bottom */

/* end opm-models */
