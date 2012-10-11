# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcec/libcec-1.9.0.ebuild,v 1.1 2012/09/15 12:44:39 thev00d00 Exp $

EAPI=4

inherit autotools eutils linux-info vcs-snapshot

DESCRIPTION="Library for communicating with the Pulse-Eight USB HDMI-CEC Adaptor"
HOMEPAGE="http://libcec.pulse-eight.com"
SRC_URI="http://github.com/Pulse-Eight/${PN}/tarball/${P} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

RDEPEND=">=sys-fs/udev-151"
DEPEND="${RDEPEND}
	dev-libs/lockdev
	virtual/pkgconfig"

CONFIG_CHECK="~USB_ACM"

src_prepare() {
	sed -i '/^CXXFLAGS/s:-fPIC::' configure.ac || die
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	use static-libs || find "${ED}" -name '*.la' -delete
}
