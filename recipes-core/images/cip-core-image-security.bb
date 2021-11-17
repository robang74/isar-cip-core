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
	libtss2-esys0 \
	libpam-cracklib \
	acl \
	audispd-plugins auditd \
	uuid-runtime \
	sudo \
"
