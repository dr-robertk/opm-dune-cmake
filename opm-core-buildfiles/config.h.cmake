/* begin opm-core
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

/* Hack around some ugly code in the unit tests. */
#define HAVE_DYNAMIC_BOOST_TEST 1

/* end private */

/* Define to the version of opm-core */
#define OPM_CORE_VERSION "${OPM_CORE_VERSION}"

/* Define to the major version of opm-core */
#define OPM_CORE_VERSION_MAJOR ${OPM_CORE_VERSION_MAJOR}

/* Define to the minor version of opm-core */
#define OPM_CORE_VERSION_MINOR ${OPM_CORE_VERSION_MINOR}

/* Define to the revision of opm-core */
#define OPM_CORE_VERSION_REVISION ${OPM_CORE_VERSION_REVISION}

/* Is the PETSc numerical library available? */
#cmakedefine HAVE_PETSC

/* begin bottom */

/* end bottom */

/* end opm-core */
