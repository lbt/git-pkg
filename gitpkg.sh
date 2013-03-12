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
OUTDIR=""

SERVICES="github|gitorious|mer"

usage() {
  cat <<EOF
Usage: $0 --service <service> --repo <path/pkg> [--outdir <outdir>]
Options:
  --service <service>      Git hosting service to use ($SERVICES)
  --repo <path/pkg>        Repository path to check out
  --outdir <outdir>        Move files to outdir after checkout (optional)

Examples:
  $0 --service github --repo lbt/powertop

EOF
}

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
    -h|*-help)
      usage
      exit 0
    ;;
    *)
      usage
      echo Unknown parameter $1.
      exit 1
    ;;
  esac
  shift
done

if [ -z "$SVC" ]; then
  usage
  echo "ERROR: no --service parameter ($SERVICES)"
  exit 1
fi
if [ -z "$REPO" ]; then
  usage
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
    git clone -n $URL .
fi
/usr/lib/obs/service/gp_mkpkg $TAG

if [ ! -z "$OUTDIR" ]; then
    # Move all files to OUTDIR
    find . -mindepth 1 -maxdepth 1 -not -name .git -print0 | xargs -0 -I files mv files $OUTDIR
fi

exit 0
