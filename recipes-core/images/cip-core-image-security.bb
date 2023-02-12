#
# A reference image which includes security packages
#
# Copyright (c) Toshiba Corporation, 2020
#
# Authors:
#  Kazuhiro Hayashi <kazuhiro3.hayashi@toshiba.co.jp>
#
# SPDX-License-Identifier: MIT
#

inherit image

DESCRIPTION = "CIP Core image including security packages"

IMAGE_INSTALL += "security-customizations"

# Debian packages that provide security features
IMAGE_PREINSTALL += " \
	openssl \
	fail2ban \
	openssh-server openssh-sftp-server openssh-client \
	syslog-ng-core syslog-ng-mod-journal \
	aide \
	nftables \
	libpam-pkcs11 \
	chrony \
	tpm2-tools \
	tpm2-abrmd \
	libpam-cracklib \
	acl \
	audispd-plugins auditd \
	uuid-runtime \
	sudo \
	aide-common \
	libpam-google-authenticator \
	passwd \
	login \
	libpam-runtime \
	util-linux \
"

# Package names based on the distro version
IMAGE_PREINSTALL:append:buster = " libtss2-esys0"
IMAGE_PREINSTALL:append:bullseye = " libtss2-esys-3.0.2-0"
