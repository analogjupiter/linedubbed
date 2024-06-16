#!/usr/bin/bash
doas -u root \
	apt-get update
doas -u root \
	apt-get -y install \
		crun \
		podman
doas -u root \
	usermod \
		--add-subuids 900000-965535 \
		--add-subgids 900000-965535 \
		ldrd
