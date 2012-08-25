# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dwarves/dwarves-9999.ebuild,v 1.8 2011/11/06 01:49:41 flameeyes Exp $

EAPI=4

PYTHON_DEPEND="2:2.6"

EGIT_REPO_URI="https://github.com/midgetspy/Sick-Beard.git"

inherit eutils user git-2 python

DESCRIPTION="Automatic TV-Series downloader for SABnzbd"
HOMEPAGE="https://github.com/midgetspy/Sick-Beard#readme"

LICENSE="GPL-2" # only
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
        dev-python/cheetah
"

pkg_setup() {
        # Control PYTHON_USE_WITH
        python_set_active_version 2
        python_pkg_setup

        # Create sickbeard group
        enewgroup ${PN}
        # Create sickbeard user, put in sickbeard group
        enewuser ${PN} -1 -1 -1 ${PN}
}

src_install() {
	dodoc readme.md

	newconfd "${FILESDIR}/${PN}.conf" ${PN}
        newinitd "${FILESDIR}/${PN}.init" ${PN}
	
	# Location of log and data files
	keepdir /var/${PN}
	fowners -R ${PN}:${PN} /var/${PN}

	keepdir /var/{${PN}/{cache,download},{run,log}/${PN}}
        fowners -R ${PN}:${PN} /var/{${PN}/{cache,download},{run,log}/${PN}}

	insinto /etc/${PN}
        insopts -m0660 -o ${PN} -g ${PN}
        doins "${FILESDIR}/${PN}.ini"

	# Rotation of log files
        insinto /etc/logrotate.d
        insopts -m0644 -o root -g root
        newins "${FILESDIR}/${PN}.logrotate" ${PN}

	insinto /usr/share/${PN}
        insopts -m0770 -o ${PN} -g ${PN}
        diropts -m0770 -o ${PN} -g ${PN}
        doins -r .
}

pkg_postinst() {
        python_mod_optimize /usr/share/${PN}

        elog "SickBeard has been installed with data directories in /var/${PN}"
	elog
	elog "New user/group ${PN}/${PN} has been created"
        elog
	elog "Config file is located in /etc/${PN}/${PN}.ini"
	elog
        elog "Please configure /etc/conf.d/${PN} before starting as daemon!"
        elog
        elog "Start with ${ROOT}etc/init.d/${PN} start"
        elog "Visit http://<host ip>:8081 to configure SickBeard"
        elog "Default web username/password : sickbeard/secret"
        elog
}

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}

