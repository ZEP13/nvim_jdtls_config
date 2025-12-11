# nvim_jdtls_config — Neovim Java LSP (jdtls) setup

Configuration Neovim dédiée au support **Java LSP via jdtls**, conçue pour être **simple**, **modulaire** et **efficace**.  
Le but de ce repo est d’offrir une base propre pour travailler en Java dans Neovim, que ce soit pour un setup personnel ou pour servir de template à d’autres.

---

# Sommaire

- [Caractéristiques](#-caractéristiques)  
- [Structure du dépôt](#-structure-du-dépôt)  
- [Prérequis](#-prérequis)  
- [Installation](#-installation)
- [Licence](#-licence)

---

# Caractéristiques

- LSP Java via **Eclipse JDT Language Server** (`jdtls`)  
- Détection automatique du **workspace** et du **project root** (Gradle / Maven / Git)  
- Workspace isolé pour chaque projet Java  
- Mappings LSP utiles (formats, diagnostics, refactors…)  
- Compatible avec `nvim-dap` pour le debug Java  
- Organisation claire grâce à `ftplugin/java.lua`  
- Config minimaliste mais extensible (peut être intégrée dans n’importe quel setup Neovim)

---

# Structure du dépôt
***
.
├── ftplugin/
│ └── java.lua # config jdtls qui se déclenche sur les fichiers Java
├── lua/
│ └── … # fichiers de configuration Lua (LSP, jdtls, etc.)
└── init.lua # point d’entrée de la config Neovim
***


Cette structure suit la logique native de Neovim :  
➡️ **tout fichier dans `ftplugin/java.lua` est chargé automatiquement pour les fichiers .java.**

---

# Prérequis

### Logiciels :
- **Neovim** ≥ 0.9  
- **Java JDK 17+**  
- **jdtls** installé sur votre système  

### Plugins recommandés :
- [`mfussenegger/nvim-jdtls`](https://github.com/mfussenegger/nvim-jdtls)  
- `nvim-lspconfig`  
- `nvim-cmp` (optionnel mais recommandé)  
- `mason.nvim` (optionnel pour installer jdtls plus facilement)  
- `nvim-dap` (si tu veux le debug Java)

---

# Installation

Clone ce repo **directement dans ta config Neovim** :

```bash
git clone https://github.com/ZEP13/nvim_jdtls_config.git ~/.config/nvim
