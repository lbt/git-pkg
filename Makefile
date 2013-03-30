PYTHON ?= python
SCRIPTS=gp_setup gp_release
LIBS=gp_common
BINDIR=${DESTDIR}/usr/bin
SHAREDIR=${DESTDIR}/usr/share/gitpkg
OBSDIR=${DESTDIR}/usr/lib/obs/service
PREFIX=/usr

default:

install:
	install -d ${BINDIR}
	install -d ${SHAREDIR}
	install -m 755 ${SCRIPTS} ${BINDIR}/
	install -m 755 ${LIBS} ${SHAREDIR}/

	# install the OBS service files
	install -d ${OBSDIR}
	install -m 755 gitpkg.sh ${OBSDIR}/gitpkg
	install -m 755 gitpkg.service ${OBSDIR}

	# python parts
	$(PYTHON) setup.py install --root=${DESTDIR} --prefix=${PREFIX}
