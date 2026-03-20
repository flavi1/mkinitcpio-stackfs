# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 Guillon Flavien - StackFS Project

DESTDIR ?=
PREFIX  ?= /usr
BIN_DIR     = $(DESTDIR)$(PREFIX)/bin
HOOKS_DIR   = $(DESTDIR)$(PREFIX)/lib/initcpio/hooks
INSTALL_DIR = $(DESTDIR)$(PREFIX)/lib/initcpio/install

.PHONY: install uninstall help

help:
	@echo "StackFS Makefile"
	@echo "  make install   - Installe les scripts système et l'utilitaire bin"
	@echo "  make uninstall - Supprime les fichiers installés"

install:
	@echo "::: Installation de StackFS :::"
	# Création des répertoires
	install -vdm755 $(BIN_DIR)
	install -vdm755 $(HOOKS_DIR)
	install -vdm755 $(INSTALL_DIR)
	
	# Installation de l'utilitaire (avec droits d'exécution 755)
	install -vpm755 bin/mnt-stackfs $(BIN_DIR)/mnt-stackfs
	
	# Installation des hooks mkinitcpio (droits 644)
	install -vpm644 hooks/stackfs $(HOOKS_DIR)/stackfs
	install -vpm644 install/stackfs $(INSTALL_DIR)/stackfs
	
	@echo "Terminé. L'utilitaire 'mnt-stackfs' est disponible."
	@echo "N'oubliez pas d'ajouter 'stackfs' à votre mkinitcpio.conf"

uninstall:
	@echo "::: Désinstallation de StackFS :::"
	rm -vf $(BIN_DIR)/mnt-stackfs
	rm -vf $(HOOKS_DIR)/stackfs
	rm -vf $(INSTALL_DIR)/stackfs
	@echo "StackFS a été retiré du système."
