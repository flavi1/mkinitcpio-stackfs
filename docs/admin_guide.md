## Documentation SysAdmin : Hook `stackfs`

Le hook **stackfs** est un gestionnaire de montage pour `initramfs` conçu pour l'orchestration dynamique de la racine système (`/`). Il permet de booter soit sur une image disque unique, soit sur une pile de couches (OverlayFS) fusionnant des images en lecture seule et des volumes persistants.

---

### 1. Configuration de `mkinitcpio`

Pour intégrer le hook, modifiez votre configuration `mkinitcpio` pour inclure les modules de boucle et de fusion, puis placez le hook avant le montage des systèmes de fichiers réels.

**Fichier :** `/etc/mkinitcpio.conf`

    MODULES=(loop overlay ext4 squashfs)
    HOOKS=(base udev block stackfs filesystems keyboard)

Générez ensuite l'image (en désactivant le fallback si nécessaire) :
`mkinitcpio -p linux`

---

### 2. Usage Simple : Fichier Unique (Monolithique)

Utile pour les déploiements immuables ou les tests rapides. Le paramètre `mnt` pointe directement vers un fichier image (ext4, squashfs, etc.) situé dans le dossier de boot.

**Configuration GRUB / CMDLINE :**
Le chemin de `mnt` est relatif au répertoire contenant le noyau.

    linux /ARTEFIX/boot/vmlinuz-linux root=/dev/sda3 mnt=rootfs.ext4
    initrd /ARTEFIX/boot/initramfs-linux.img

**Comportement :**
* Le fichier `rootfs.ext4` est monté en tant que `/`.
* La partition physique (`/dev/sda3`) est déplacée et reste accessible dans `/.boot_disk`.

---

### 3. Usage Avancé : Orchestration par Dossier

Lorsque `mnt` pointe vers un dossier, le hook analyse son contenu pour construire une racine hybride via **OverlayFS**.

**Structure d'exemple sur le disque :**

    /ARTEFIX/boot/my_os/
    ├── 0_base.squashfs.ro    # Système de base immuable
    ├── 1_custom.ro           # Couche de personnalisation (ex: drivers)
    └── 2_persist.ext4.rw     # Couche d'écriture persistante

**Ligne de boot :**
`root=/dev/sda3 mnt=my_os`

#### Règles de nommage et priorité :
1.  **Séquence :** Les fichiers sont chargés par ordre alphabétique.
2.  **Suffixe `.ro` :** Image montée en lecture seule (Lower layer).
3.  **Suffixe `.rw` :** Image montée en lecture-écriture. Si elle est en dernière position, elle sert d'**Upperdir** (toute modification du système y est enregistrée).
4.  **Placeholders (Fichiers vides) :** Un fichier de 0 octet déclenche un montage **volatil (Tmpfs)** en RAM pour ce point précis.

---

### 4. Structure Interne et Mutation de Chemins

Le hook supporte la création de points de montage spécifiques à l'intérieur de la pile via une syntaxe de nommage dans les images :

* **Double Underscore (`__`) :** Traduit en slash (`/`) pour les dossiers.
    * Un dossier nommé `var__log` dans une image sera monté sur `/var/log` dans le système final.
* **Persistance ciblée :** Vous pouvez isoler la persistance. Si `2_persist.ext4.rw` contient uniquement un dossier `etc`, seul `/etc` sera persistant ; le reste du système restera en lecture seule ou en RAM.

---

### 5. Maintenance et Debugging

Le hook génère un journal détaillé de l'orchestration directement sur la partition de boot pour diagnostiquer les échecs de montage avant le `switch_root`.

* **Log persistant :** Accessible après le boot dans `/.boot_disk/[CHEMIN_KERNEL]/.stackfs.log`.
* **Points techniques :**
    * `/.premount/` : Contient les montages bruts de chaque image loop.
    * `/tmp/fs_workdir/` : Répertoires de travail OverlayFS (volatils).

> **Note de sécurité :** Le hook effectue automatiquement un `mount --move` des interfaces système (`/proc`, `/sys`, `/dev`, `/run`) vers la nouvelle racine avant de passer la main à l'init final (`/sbin/init`).

