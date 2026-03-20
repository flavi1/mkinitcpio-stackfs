# StackFS : Advanced File-Driven Mounting Engine
**SPDX-License-Identifier: GPL-2.0-only** **Copyright (C) 2026 Guillon Flavien - StackFS Project**

 A file-Driven Stack Mounting engine for mkinitcpio.

`stackfs` est un hook pour `mkinitcpio` conçu pour l'orchestration dynamique de la racine système (`/`). Il permet de construire une hiérarchie de montage (Stack) basée sur la structure physique de vos fichiers, fusionnant des images immuables et persistantes via **OverlayFS**.

## 🚀 Philosophie : "Structure-as-Configuration"
Avec StackFS, vous n'avez pas de fichier de configuration complexe à maintenir dans l'initramfs. **Le nom et l'emplacement de vos fichiers définissent votre montage.**

1. **Ordre alphabétique** : Les couches sont empilées selon leur nom (ex: `0_base.ro` avant `1_patch.ro`).
2. **Extensions sémantiques** : 
   - `.ro` : Couche en lecture seule (LowerDir).
   - `.rw` : Couche persistante en lecture-écriture (UpperDir).
3. **Zéro-Config** : Pointez simplement `mnt=mon_dossier` dans votre ligne de boot.

## 🏗️ Architecture des Couches (Layer Stack)



```text
       STACKFS EXECUTION FLOW
      _______________________________
     |                               |
     |      VIRTUAL ROOT (/)         |  <-- final switch_root
     |_______________________________|
                    |
      ______________|_______________
     |     (Upper) 1_persist.rw      |  <-- Writeable Layer (ext4/xfs)
     |_______________________________|
                    |
      ______________|_______________
     |     (Lower) 0_base.ro         |  <-- Immutable Layer (squashfs)
     |_______________________________|
                    |
      ______________|_______________
     |      HOST BOOT DISK           |  <-- Moved to /.boot_disk
     |_______________________________|
```

## 🛠️ Installation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/votre-user/mkinitcpio-stackfs.git
   cd mkinitcpio-stackfs
   ```

2. **Installer les fichiers** :
   ```bash
   sudo make install
   ```

3. **Configurer `mkinitcpio.conf`** :
   Ajoutez `stackfs` avant `filesystems` :
   ```bash
   HOOKS=(base udev block stackfs filesystems keyboard)
   ```

4. **Régénérer l'initramfs** :
   ```bash
   sudo mkinitcpio -p linux
   ```

## 📖 Guide d'utilisation (Kernel Cmdline)

### Cas A : Montage d'un fichier unique
Idéal pour tester une image système monolithique.
`linux ... root=/dev/sda3 mnt=rootfs.ext4`

### Cas B : Montage d'un dossier (Orchestration)
`linux ... root=/dev/sda3 mnt=my_os_folder`

Le dossier `my_os_folder` (situé à la racine de votre partition `root`) peut contenir :
* `00_core.squashfs.ro` (Système de base)
* `10_drivers.ro` (Compléments immuables)
* `99_user_data.ext4.rw` (Persistance utilisateur)

## 🔍 Debugging & Logs
StackFS est conçu pour être transparent. Un journal détaillé est généré à chaque boot :
* **Localisation** : `/.boot_disk/[PATH_TO_KERNEL]/.stackfs.log`
* **Contenu** : Détail de l'empilement des couches, résolution des périphériques et erreurs de montage.

---

### Prochaine étape pour toi :
Tu peux maintenant ouvrir **GitHub Desktop**, faire ton premier commit avec ce `README.md` et tes scripts `hooks/stackfs` et `install/stackfs`. 

**Souhaites-tu que je t'aide à rédiger le script `Makefile` pour que la commande `sudo make install` que j'ai mise dans la doc fonctionne réellement ?**
