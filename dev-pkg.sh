#!/usr/bin/env bash

# Test a dev version of a package in GAP master

set -e

TERM=${TERM:-xterm}

SRCDIR=$PWD

echo SRCDIR   : $SRCDIR
echo PKG_NAME : $PKG_NAME
echo REPO_URL : $REPO_URL

# set up a custom GAP root containing only this package, so that
# we can force GAP to load the correct version of this package
mkdir -p gaproot/pkg/
cd gaproot/pkg/

git clone ${REPO_URL} ${PKG_NAME}

cd ${PKG_NAME}

# show head commit for debugging
git log -n 1

###############################################################################
#

# for Semigroups package
if [[ -f prerequisites.sh ]]
then
  ./prerequisites.sh
fi

# build the package
cd ..
${GAP_HOME}/bin/BuildPackages.sh --with-gaproot=${GAP_HOME} --strict ${PKG_NAME}
cd ${PKG_NAME}


###############################################################################

# start GAP with custom GAP root, to ensure correct package version is loaded
GAP="${GAP_HOME}/bin/gap.sh -l $SRCDIR/gaproot; --quitonbreak -q"

echo ""
echo "######################################################################"
echo "#"
echo "# TESTING WHETHER THE PACKAGE IS LOADABLE"
echo "#"
echo "######################################################################"
echo ""
$GAP -A <<GAPInput
Read("/home/workspace/dev-pkg.g");
SetInfoLevel(InfoPackageLoading,4);
pkg := PreparePackageInDir("${PWD}");;
if LoadPackage(pkg) <> true then
    Print("PACKAGE IS NOT LOADABLE - TEST TERMINATED\n");
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITH DEFAULT PACKAGES, LOADED AT GAP STARTUP"
echo "#"
echo "######################################################################"
echo ""
$GAP <<GAPInput
Read("/home/workspace/dev-pkg.g");
pkg := PreparePackageInDir("${PWD}");;
if TestOnePackage(pkg) <> true then
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITHOUT PACKAGES, EXCEPT REQUIRED BY GAP (using -A option)"
echo "#"
echo "######################################################################"
echo ""
$GAP -A <<GAPInput
Read("/home/workspace/dev-pkg.g");
pkg := PreparePackageInDir("${PWD}");;
if TestOnePackage(pkg) <> true then
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput

echo ""
echo "######################################################################"
echo "#"
echo "# TEST WITH ALL PACKAGES LOADED (using LoadAllPackages() command)"
echo "#"
echo "######################################################################"
echo ""
$GAP <<GAPInput
Read("/home/workspace/dev-pkg.g");
pkg := PreparePackageInDir("${PWD}");;
LoadAllPackages();
if TestOnePackage(pkg) <> true then
    FORCE_QUIT_GAP(1);
fi;
QUIT_GAP(0);
GAPInput
