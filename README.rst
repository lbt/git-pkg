This tool supports managing rpm packaging (spec files and patches) from a git tree.

Normal Operation
================

New release of a working package that needs a patch? use --rel:

* Checkout the mer-master branch
* Commit your changes/patches
* gp_release --rel=<Ver-Rel>
* git push --tags origin master pkg-mer

Want to work on the packaging? Same approach but do --edit and then commit
your packaging changes:

* gp_release --rel=<Ver-Rel> --edit
* hack on the packaging
* git commit -am"Release <Ver-Rel>"

Fancy using osc to do a local verify build?

* osc co myprj/pkg
* cd myprj/pkg
* gp_release --git-dir=<my gitpkg repo with changes>
* osc build

Need to setup a new package?

* Clone upstream
* Find the right tag and see if a pristine-tar should also be used
* Got some good packaging from OBS? Use --auto
* gp_setup --auto --pristine --base-on=RELEASE_0_9_7 --pkgdir=<good packaging> --ver=0.9.7-1
otherwise:

* gp_setup --manual --pkgdir=<rough packaging> --ver=0.9.7-1

New upstream version? use --ver:

* Checkout the mer-master branch or pull the upstream and tags
* gp_release --ver=<release-tag>
* git push --tags origin master pkg-mer

Basically gp_release is for managing Version: and Release: and adding patches; gp_setup is for setting up new package repositories. Other tools are used by the OBS to checkout the code for building.

Why is it needed?
=================

The rpm packaging used in Mer and derived products consists of a tarball and some packaging files. These packages need to be change controlled and that is where gitpkg comes in.

Currently for Mer Core the raw tarball, patches and packaging files are stored in git.

This leads to:

* **Inefficient storage**: git is not designed to store large binaries efficiently
* **Opacity**: files in the tarball cannot be examined without extracting and unpacking
* **Dissociation**: the upstream change history is lost

So clearly the main objectives are:

* Increase storage efficiency
* Reduce opacity (increase transparency)
* Retain association with upstream

Other objectives:

* Maintain or improve RE efficiency
* Obviousness - eg "``git checkout master``" should have me ready to hack

For a distro/product there are 2 types of package:

* **Native** packages are developed directly for/in the distro or product (no patches!)
* **Upstream** packages are developed elsewhere, and may contain additional patches for the product

gitpkg is useful for both upstream and native packages and ensures that packaging is kept distinct from the code.

The tool assumes that OBS is not being used as the primary store for code and packaging and that vanilla rpm/tarball+spec is the basic build source.


What does it do?
================

There are a few main use cases:

* Setup a new package from git and (possibly pre-existing) packaging
* Add/modify a patch and update packaging
* New upstream release and update packaging

* Create tarball, spec and patches for building/uploading to OBS


Using gp_setup
==============

This can be used to simply create a suitable packaging branch or to import existing packaging.


Worked Example: Importing oprofile
----------------------------------

Upstream uses git so we'll use --base-on to base off it after cloning it::

  git clone git://oprofile.git.sourceforge.net/gitroot/oprofile/oprofile
  cd oprofile

Determine the tag and verify if a pristine-tar should also be used (eg for autogen.sh)

We have some packaging so check it out (in a different window)::

  osc co Project:KDE:Mer_Extras oprofile

so we can use --auto

Looking at the tarball that is released we see there are changes to the git tree (autogen.sh etc) so we'll use --pristine.

The release tag is "RELEASE_0_9_7" so that will be the --base-on value; since this isn't a simple version we need to specify --rel=0.9.7-1

The command then is::

  gp_setup --auto --pristine --base-on=RELEASE_0_9_7 \
           --pkgdir=/mer/obs/cobs/Project:KDE:Mer_Extras/oprofile \
           --ver=0.9.7-1


More examples:

Project with an upstream git and some existing packaging::

  git clone upstream
  gp_setup --auto --base-on=v3.1.7 --pkgdir=/mer/obs/cobs/Mer:Tools:Testing/pciutils/ --ver=3.1.7-3

Project with no upstream git a pristine tar and some existing packaging but no patches (using sudo as an example)::

  gp_setup --auto --pristine --unpack-to=1.8.2 --pkgdir=/mer/obs/cobs/Mer:Tools:Testing/sudo


Git Names and branch layouts
============================

ver is X.Y.Z and is conceptually an upstream version and ideally a tag.

Releases are identified as X.Y.Z-R

branch names:

* master
* mer-master
* pkg-mer

tag formats:

* <base>
* mer-<ver>-<rel>
* pkg-mer-<ver>-<rel>

 upstream/master
            upstream or master branch (can be anything - often a specific
	    branch with rc releases eg in rpm or OBS)

 mer-master
            This is the patch branch; it is a branch per upstream
	    release which splits from the upstream at the 'base' tag
	    and contains distro specific patches. It is rebased for
	    each upstream release. This branch contains the code used
	    by the packaging.

	    Tags here will be of the form mer-<ver>-<rel>

            Tags are made on here to preserve commits and the branch
	    may be re-based if needed (eg if a patch is removed
	    between -1 and -2 releases)

	    If using pristine-tar then the initial commit is the
	    pristine-tar delta and is not applied as a patch - it's
	    simply there to allow development patches apply cleanly to
	    the tarball.

 pkg-mer
            Discrete commit tree holding any packaging.
	    Tags of pkg-mer-<ver>-<rel>


Git support for multiple sources is possible but more complex


The _src file
=============

This file defines the src needed for building a package.
It supports:

* Single tarball
* Patches
* Multiple tarballs (yes, kinda, see obs-server)

One line:

* git:<tarball>:<commit1>:<commit2>
* pristine-tar:<tarball>:<commit1>:<commit2>
* Future? Blob : if needed, just store the raw file in a commit

 git:<filename>:<commit1>[:<commit2>]
    <filename> is created in the current directory from git archive at <commit1>
    patches for commits from <commit1> to <commit2> are placed in files
    according to git-patch
    Note that the <commit>s can be tags, branches or sha1s - anything git uses.

 pristine-tar:<filename>[:<commit1>:<commit2>] <filename> is extracted
    from pristine-tar <commit1> represents the closest point on the
    upstream branch to the pristine tar. At this point there's a mer
    branch. The first commit is a simple patch of any files added,
    modified or removed to make the released tarball. Subsequent
    patches are Mer's
    Patches for commits from <commit1> to <commit2> are placed in files
    according to git-patch. THE FIRST COMMIT IS SKIPPED as it's
    in the pristine tarball.
    The filename is obtained from pristine-tar checkout


Walkthrough for Powertop
========================

Find the upstream and clone it::

 git clone git://github.com/fenrus75/powertop.git

 git checkout -f v2.1.1
 gp_setup --manual --ver=2.1.1-1

At this point you are in the packaging branch. Providing a --rel lets
gp_setup do some tagging for us.

Edit yaml/spec/changes and create some packaging (we'll cheat and use philippe's)::

 curl -kOL https://github.com/philippedeswert/powertop/raw/pkg-mer/powertop.changes
 curl -kOL https://github.com/philippedeswert/powertop/raw/pkg-mer/powertop.spec
 curl -kOL https://github.com/philippedeswert/powertop/raw/pkg-mer/powertop.yaml

Describe in the _src file how OBS gets the source (in this case, use simple git archive to make a tar.bz2 based on the tag v2.1.1)::

 echo git:powertop-v2.1.1.tar.bz2:mer-2.1.1-1 > _src
 git add powertop.* _src

Check to ensure it builds.

First we must create an osc package to build the source in.

Go to a suitable OBS directory with Mer_Core_i486 or similar as a repo target.

Now create the package::
  
  osc mkpac powertop
  cd powertop

Now we're in a suitable osc directory we can setup git::

 gp_release --git-dir=<working git dir>
 osc build Mer_Core_i486 i586

All good, commit::

 git commit -s


TODO
====

[ ] Improve hack-testing. ie incorporate uncommitted changes into a build



Notes
=====

gitpkg uses `Git orphan branches`_.

.. _Git orphan branches: http://stackoverflow.com/questions/1384325/in-git-is-there-a-simple-way-of-introducing-an-unrelated-branch-to-a-repository

Sage asked if it was possible to just clone the packaging or source - it is but it's not trivial::

 git init $PKG
 cd $PKG
 git remote add mer-tools ssh://$USER@review.merproject.org:29418/mer-tools/$PKG
 sed -i '/fetch/s/\*/\pkg-mer/g' .git/config
 git fetch mer-tools

* The tarball uses src/ as the location for git packages unless pristine-tar is in use
