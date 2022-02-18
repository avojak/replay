# I'm lazy, and it's easier to remember 'make all' than the entire flatpak-builder command :)

SHELL := /bin/bash

.PHONY: all flatpak

all: flatpak

flatpak:
	flatpak-builder build com.github.avojak.replay.yml --user --install --force-clean