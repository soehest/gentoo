# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dwarves/dwarves-9999.ebuild,v 1.8 2011/11/06 01:49:41 flameeyes Exp $

EAPI=4

PYTHON_DEPEND="2:2.6"

EGIT_REPO_URI="https://github.com/mrkipling/maraschino.git"

inherit eutils user git-2 python

DESCRIPTION="web frontend for sabnzbd, couchpotato, sickbeard headphones and xbmc"
HOMEPAGE="http://www.maraschinoproject.com"

LICENSE="GPL-2" # only
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

pkg_setup() {
        # Control PYTHON_USE_WITH
        python_set_active_version 2
        python_pkg_setup

        # Create maraschino group
        enewgroup ${PN}
        # Create maraschino user, put in maraschino group
        enewuser ${PN} -1 -1 -1 ${PN}
}

src_install() {
	dodoc AUTHORS README.md

	newconfd "${FILESDIR}/${PN}.conf" ${PN}
        newinitd "${FILESDIR}/${PN}.init" ${PN}
	
	# Location of log and data files
	keepdir /var/${PN}
        fowners -R ${PN}:${PN} /var/${PN}

	keepdir /var/{${PN}/cache,log/${PN}}
        fowners -R ${PN}:${PN} /var/{${PN}/cache,log/${PN}}

	# Rotation of log files
        insinto /etc/logrotate.d
        insopts -m0644 -o root -g root
        newins "${FILESDIR}/${PN}.logrotate" ${PN}

	# wierd stuff ;-)
        last_commit=$(git rev-parse HEAD)
        echo -n ${last_commit} > Version.txt
	insinto /var/${PN}
	doins Version.txt

	insinto /usr/share/${PN}
        doins -r lib maraschino modules static templates Maraschino.py mobile.py
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

        elog "Maraschino has been installed with data directories in /var/${PN}"
	elog
	elog "New user/group ${PN}/${PN} has been created"
	elog
        elog "Please configure /etc/conf.d/${PN} before starting as daemon!"
        elog "Port setting in /etc/conf.d/${PN} has priority over the port set in webinterface"
	elog
        elog "Start with ${ROOT}etc/init.d/${PN} start"
        elog "Visit http://<host ip>:7000 to configure Maraschino"
        elog 
	elog "Security note:"
	elog "There is no default username/password, so it is important that you configure maraschino using the web interface!"
}

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}

