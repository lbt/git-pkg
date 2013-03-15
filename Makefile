default:

install:
	mkdir -p ${DESTDIR}/usr/bin/
	cp gp_* ${DESTDIR}/usr/bin/

	# install the OBS service files
	mkdir -p ${DESTDIR}/usr/lib/obs/service/
	cp gitpkg.sh ${DESTDIR}/usr/lib/obs/service/gitpkg
	cp gitpkg.service ${DESTDIR}/usr/lib/obs/service/
	# gitpkg expects to find gp_mkpkg here. When this is packaged
	# into rpm, a symbolic link might be a better idea.
	cp gp_mkpkg ${DESTDIR}/usr/lib/obs/service/
