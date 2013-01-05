#!/bin/bash

# (C) 2012 David Greaves david@dgreaves.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# See http://www.gnu.org/licenses/gpl-2.0.html for full license text.

STORE=/data/service/gitpkg
SVC=""
REPO=""


while test $# -gt 0; do
  case $1 in
    *-service)
      SVC="$2"
      shift
    ;;
    *-repo)
      REPO="$2"
      shift
    ;;
    *-tag)
      TAG="$2"
      shift
    ;;
    *-outdir)
      OUTDIR="$2"
      shift
    ;;
    *)
      echo Unknown parameter $1.
      echo 'Usage: gitpkg --service [github|gitorious|mer] --repo <path/pkg>'
      echo 'eg gitpkg --service github --repo lbt/powertop'
      exit 1
    ;;
  esac
  shift
done

if [ -z "$SVC" ]; then
  echo "ERROR: no --service parameter (github|gitorious|mer)!"
  exit 1
fi
if [ -z "$REPO" ]; then
  echo "ERROR: no --repo parameter"
  exit 1
fi

case $SVC in
    github)
        URL=git://github.com/${REPO}.git ;;
    gitorious)
        URL=git://gitorious.org/${REPO}.git ;;
    mer)
        URL=http://gitweb.merproject.org/gitweb/${REPO}.git/ ;;
    *)
        echo "Sorry, git service $SVC is not whitelisted. please contact lbt in #mer"
        exit 1 ;;
esac

PRJDIR=$(pwd)
cd $STORE

mkdir -p $SVC/$REPO
cd $SVC/$REPO

# clone or update
if [ -d .git ]; then
    git remote update --prune
    git fetch --all
    git fetch --tags
else
    git clone $URL .
fi
/usr/lib/obs/service/gp_mkpkg $TAG

# Move all files to OUTDIR
mv $(find . -mindepth 1 -maxdepth 1 -not -name .git) $OUTDIR

exit 0
