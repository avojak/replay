SHELL = /bin/bash

FLATPAK_REMOTE_URL  = https://flatpak.elementary.io/repo.flatpakrepo
FLATPAK_REMOTE_NAME = appcenter
PLATFORM_VERSION    = 6.1

# Check for executables which are assumed to already be present on the system
EXECUTABLES = flatpak flatpak-builder
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

.PHONY: all flatpak lint

all: flatpak

flatpak-init:
	flatpak remote-add --if-not-exists --system $(FLATPAK_REMOTE_NAME) $(FLATPAK_REMOTE_URL)
	flatpak install -y --user $(FLATPAK_REMOTE_NAME) io.elementary.Platform//$(PLATFORM_VERSION) 
	flatpak install -y --user $(FLATPAK_REMOTE_NAME) io.elementary.Sdk//$(PLATFORM_VERSION)

init: flatpak-init

# TODO: Add offline option to add --disable-download flag
flatpak:
	flatpak-builder build com.github.avojak.replay.yml --user --install --force-clean --disable-download

lint:
	io.elementary.vala-lint ./src

translations:
# TODO

clean:
	rm -rf ./.flatpak-builder/
	rm -rf ./build/
	rm -rf ./builddir/