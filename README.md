# Twitt-Oz

Projet réalisé par Corentin Lengelé

## Decription
Projet pour le cours LINFO1104 – Concepts, paradigmes et sémantique des langages de programmation.  
Professeur: Peter Van Roy  
Assistant:  Antoine Vanderschueren

Programme en oz capable de parser des fichiers texte contenant un tweet sur chaque ligne en utilisant des threads et ensuite capable de prédire un mot en fonction d'un texte donné.

## Description des fichiers

- `tweets/*`  :Dossier des fichiers à parser.
- `Makefile`  :Makefile du projet.
- `Main.oz`   :Contient le programme principal.
- `Reader.oz` :Contient les fonctions qui permettent la lecture des fichiers.

## Utilisation
Linux: 
```bash
make run
```

Windows:  
Lancer Start.bat ou écrire ceci dans le PowerShell:
```bash
ozc -c Reader.oz -o Reader.ozf
ozc -c main.oz -o main.oza
ozengine main.oza
```  
