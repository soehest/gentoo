# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

# Require python-2 with sqlite USE flag
PYTHON_DEPEND="2:2.6"
PYTHON_USE_WITH="sqlite"

inherit eutils python user

MY_P="${P/sab/SAB}"

DESCRIPTION="Binary newsgrabber in Python, with web-interface. Successor of old SABnzbd project"
HOMEPAGE="http://www.sabnzbd.org/"
SRC_URI="mirror://sourceforge/sabnzbdplus/${MY_P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	app-arch/par2cmdline
	app-arch/unrar
	app-arch/unzip
	dev-python/cheetah
	dev-python/pyopenssl
	dev-python/yenc
"

S="${WORKDIR}/${MY_P}"
DHOMEDIR="/var/${PN}"

pkg_setup() {
	# Control PYTHON_USE_WITH
	python_set_active_version 2
	python_pkg_setup

	# Create sabnzbd group
	enewgroup ${PN}
	# Create sabnzbd user, put in sabnzbd group
	enewuser ${PN} -1 -1 -1 ${PN}
}

src_install() {
	dodoc {ABOUT,CHANGELOG,ISSUES,README}.txt Sample-PostProc.sh

	newconfd "${FILESDIR}/${PN}.conf" ${PN}
	newinitd "${FILESDIR}/${PN}.init" ${PN}
	keepdir /var/{${PN}/{admin,backup,cache,complete,download,dirscan},log/${PN}}
	fowners -R ${PN}:${PN} /var/{${PN}/{,admin,backup,cache,complete,download,dirscan},log/${PN}}

	# Default configuration file and directory

	insinto /etc/${PN}
	insopts -m0660 -o ${PN} -g ${PN}
	doins "${FILESDIR}/${PN}.ini"

	# Rotation of log files
	insinto /etc/logrotate.d
	insopts -m0644 -o root -g root
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	# Add themes & code into /usr/share
	insinto /usr/share/${PN}
	doins -r cherrypy email gntp icons interfaces locale po sabnzbd SABnzbd.py tools util
}

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}

	elog "SABnzbd has been installed with default directories in /var/${PN}"
	elog
	elog "New user/group ${PN}/${PN} has been created"
	elog
	elog "Config file is located in /etc/${PN}/${PN}.ini"
	elog
	elog "Please configure /etc/conf.d/${PN} before starting as daemon!"
	elog
	elog "Start with ${ROOT}etc/init.d/${PN} start"
	elog "Visit http://<host ip>:8080 to configure SABnzbd"
	elog "Default web username/password : sabnzbd/secret"
	elog
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
