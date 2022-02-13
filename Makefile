SHELL := /bin/bash

FLATPAK_BUILDER_EXE = flatpak run org.flatpak.Builder
FLATPAK_MANIFEST = com.github.avojak.replay.yml

.PHONY: all test clean-test flatpak

all: flatpak

test:
	@$(MAKE) -C test run-tests

clean-test:
	@$(MAKE) -C test clean-tests

flatpak:
	$(FLATPAK_BUILDER_EXE) build $(FLATPAK_MANIFEST) --user --install --force-clean