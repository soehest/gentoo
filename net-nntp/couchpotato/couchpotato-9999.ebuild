# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2:2.6"

EGIT_REPO_URI="https://github.com/RuudBurger/CouchPotatoServer.git"

inherit eutils user git-2 python

DESCRIPTION="CouchPotatoServer (CPS) V2 is an automatic NZB and torrent downloader for movies"
HOMEPAGE="https://github.com/RuudBurger/CouchPotatoServer#readme"

LICENSE="GPL-2" # only
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

pkg_setup() {
	# Control PYTHON_USE_WITH
	python_set_active_version 2
	python_pkg_setup

	# Create couchpotato group
	enewgroup ${PN}
	# Create couchpotato user, put in couchpotato group
	enewuser ${PN} -1 -1 -1 ${PN}
}

src_install() {
	dodoc README.md

	newconfd "${FILESDIR}/${PN}.conf" ${PN}
	newinitd "${FILESDIR}/${PN}.init" ${PN}

	# Location of data files
	keepdir /var/${PN}
	fowners -R ${PN}:${PN} /var/${PN}

	insinto /etc/${PN}
	insopts -m0660 -o ${PN} -g ${PN}
	doins "${FILESDIR}/${PN}.ini"

	# Rotation of log files
	insinto /etc/logrotate.d
	insopts -m0644 -o root -g root
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	insinto /usr/share/${PN}
	doins -r couchpotato libs CouchPotato.py version.py
}

pkg_postinst() {

	# we need to remove .git which old ebuild installed
	if [[ -d "/usr/share/${PN}/.git" ]] ; then
	   ewarn "stale files from previous ebuild detected"
	   ewarn "/usr/share/${PN}/.git removed."
	   ewarn "To ensure proper operation, you should unmerge package and remove directory /usr/share/${PN} and then emerge package again"
	   ewarn "Sorry for the inconvenience"
	   rm -Rf "/usr/share/${PN}/.git"
	fi

	python_mod_optimize /usr/share/${PN}

	elog "Couchpotato has been installed with data directories in /var/${PN}"
	elog
	elog "New user/group ${PN}/${PN} has been created"
	elog
	elog "Config file is located in /etc/${PN}/${PN}.ini"
	elog "Note: Log files are located in /var/${PN}/logs"
	elog
	elog "Please configure /etc/conf.d/${PN} before starting as daemon!"
	elog
	elog "Start with ${ROOT}etc/init.d/${PN} start"
	elog "Visit http://<host ip>:5050 to configure Couchpotato"
	elog "Default web username/password : couchpotato/secret"
	elog
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
