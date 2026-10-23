# Système Séquentiel - Feux Tricolores sur FPGA (DE2i-150)

## 📋 Description du projet
Ce projet consiste à concevoir et à implémenter un système séquentiel (gestion d'un timer pour des feux tricolores) entièrement développé en **VHDL** et ciblant la carte FPGA **Intel Altera DE2i-150**. 

L'objectif principal est de piloter le comportement du système à l'aide d'une **Machine à États Finis (FSM)** tout en gérant proprement les interactions utilisateur via des boutons poussoirs sécurisés par un module anti-rebonds.

## ⚙️ Fonctionnalités techniques
* **Machine à États Finis (FSM) :** Le comportement est piloté par 5 états principaux : `IDLE`, `INIT`, `SET_TIME`, `COUNTDOWN` et `DONE`.
* **Module Anti-rebonds (`debounce`) :** Sécurise la lecture des signaux des boutons poussoirs de la carte pour éviter les parasites électriques.
* **Base de temps :** Génération d'un signal d'horloge précis (strobe d'une seconde) à partir de l'oscillateur de la carte.
* **Interface visuelle :** Utilisation des LED de la carte pour indiquer l'état du timer et les phases de clignotement (`DONE`).

## 🛠️ Ce que l'on va retrouver dans ce dépôt
* **`src/`** : Les codes sources VHDL du projet (module principal et gestion des boutons).
* **`docs/`** : Le compte-rendu complet du projet.

## 🚀 Prochaines étapes
* Téléversement et organisation des codes sources VHDL.
* Documentation des résultats de simulation et des tests sur la carte physique.
