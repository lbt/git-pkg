#!/usr/bin/env python

import os, sys
from distutils.core import setup
try:
    import setuptools
    # enable "setup.py develop", optional
except ImportError:
    pass

if 'install' in sys.argv and \
   'MAKEFLAGS' not in os.environ and \
   'RPM_BUILD_ROOT' not in os.environ:
        repl = raw_input('WARNING: Please use `make install` for installation, continue(y/N)? ')
        if repl != 'y':
            sys.exit(1)

# For debian based systems, '--install-layout=deb' is needed after 2.6
if sys.version_info[:2] <= (2, 5) and '--install-layout=deb' in sys.argv:
    del sys.argv[sys.argv.index('--install-layout=deb')]

try:
    with open('version.py') as f: exec(f.read())
    version=__version__
except IOError:
    print 'WARNING: Cannot write version number file'

setup(name='gitpkg',
      version = version,
      description='Mer git packaging tools',
      author='David Greaves',
      author_email='david@dgreaves.com',
      url='https://github.com/mer-tools/git-pkg',
      scripts=['gp_mkpkg'],
      py_modules=['BlockDumper']
     )
