# Copyright 1999-2012 Gentoo Foundation
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
	dev-lang/php[zip,curl]
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
	insinto ${MY_HTDOCSDIR}
	dodoc README.md
	#install htdoc files
	doins Mobile_Detect.php favicon.ico install.php index.php notifications.xml retrieve.php upgrade-db.php || die "failed to install"
	doins settings.php usenetservers.xml || die "failed to install"
	doins -r Crypt Math NNTP images js lib locales templates tests || die "failed to install"
	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt
	doins "${FILESDIR}"/.htaccess || die "failed to install htaccess"
	webapp_src_install
}

pkg_postinst() {
	webapp_pkg_postinst
}
