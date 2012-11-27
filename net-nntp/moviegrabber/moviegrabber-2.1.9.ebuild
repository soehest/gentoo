# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

# Require python-2 with sqlite USE flag
PYTHON_DEPEND="2:2.6"
PYTHON_USE_WITH="sqlite"

inherit eutils python user

MY_P="${P/sab/SAB}"

DESCRIPTION="MovieGrabber is a fully automated way of downloading movie from
usenet"
HOMEPAGE="http://sourceforge.net/projects/moviegrabber/"
SRC_URI="mirror://sourceforge/moviegrabber/releases/${PN}-src-${PV}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-python/imaging
"

S="${WORKDIR}/${PN}"
DHOMEDIR="/var/${PN}"

pkg_setup() {
	# Control PYTHON_USE_WITH
	python_set_active_version 2
	python_pkg_setup

	# Create moviegrabber group
	enewgroup ${PN}
	# Create moviegrabber user, put in moviegrabber group
	enewuser ${PN} -1 -1 -1 ${PN}
}

src_install() {

	newconfd "${FILESDIR}/${PN}.conf" ${PN}
	newinitd "${FILESDIR}/${PN}.init" ${PN}
	keepdir /var/{${PN}/{configs,db},log/${PN}}
	fowners -R ${PN}:${PN} /var/{${PN}/{,configs,db},log/${PN}}

	# Default configuration file and directory

	insinto /var/${PN}/configs
	insopts -m0660 -o ${PN} -g ${PN}
	doins "${FILESDIR}/config.ini"

	# Rotation of log files
	insinto /etc/logrotate.d
	insopts -m0644 -o root -g root
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	# Add themes & code into /usr/share
	insinto /usr/share/${PN}
	doins -r certs interfaces lib MovieGrabber.py
	insinto /var/${PN}
	doins -r configs db images

	# ugly stuff can be found here. Someone should report upstream.
	dosym /var/${PN}/db /usr/share/${PN}/db
	dosym /var/${PN}/configs /usr/share/${PN}/configs
	dosym /var/${PN}/images /usr/share/${PN}/images
}

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}

elog 	"MovieGrabber has been installed with data directories in /usr/share/${PN}"
	elog
	elog "New user/group ${PN}/${PN} has been created"
	elog
	elog "Config file is located in /var/${PN}/configs/config.ini"
	elog
	elog "Please configure /etc/conf.d/${PN} before starting as daemon!"
	elog
	elog "Start with ${ROOT}etc/init.d/${PN} start"
	elog "Visit http://<host ip>:9191 to configure MovieGrabber"
	elog "Default web username/password : ${PN}/secret"
	elog
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
