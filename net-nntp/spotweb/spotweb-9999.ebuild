# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils user git-2 webapp

PYTHON_DEPEND="2:2.6"

EGIT_REPO_URI="https://github.com/spotweb/spotweb.git"

DESCRIPTION="Spotweb is a webbased usenet binary resource indexer based on the protocol and development done by Spotnet"
HOMEPAGE="http://github.com/spotnet"
LICENSE="Spotweb"

KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="virtual/mysql
	dev-lang/php[zip,curl,pdo]
	virtual/httpd-php"
RDEPEND="${DEPEND}"

need_httpd_cgi

pkg_setup() {
	# Control PYTHON_USE_WITH
	webapp_pkg_setup
	echo "Creating spotweb MySQL user and spotweb database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	"${EROOT}"/usr/bin/mysql -u root -p < "${FILESDIR}"/create_db.sql
}

src_install() {
	webapp_src_preinst
	#install htdoc files
	insinto ${MY_HTDOCSDIR}
	dodoc README.md
	# next two lines are ugly but working
	mkdir cache
	touch dbsettings.inc.php
	doins check-cache.php dbsettings.inc.php favicon.ico install.php index.php migrate-cache.php migrate-cache2.php notifications.xml retrieve.php settings.php upgrade-db.php usenetservers.xml || die "failed to install"
	doins -r cache NNTP images js lib locales templates tests vendor utils || die "failed to install"
	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt
	doins "${FILESDIR}"/.htaccess || die "failed to install htaccess"
	webapp_serverowned ${MY_HTDOCSDIR}/cache
	webapp_serverowned ${MY_HTDOCSDIR}/dbsettings.inc.php
	webapp_src_install
}

pkg_postinst() {
	echo "jeg er her"
	webapp_pkg_postinst
}

pkg_config() {
	#defunct at the moment :(
	echo "Creating spotweb MySQL user and spotweb database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	"${EROOT}"/usr/bin/mysql -u root -p < "${FILESDIR}"/create_db.sql
}
