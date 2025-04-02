# Étape 1 : Analyse et préparation
- [x] Comprendre la base GLPI existante via Github
- [x] Sélectionner les tables pertinentes
- [x] Analyser les tables choisies
- [x] Identifier les dépendances (foreign key...)
- [x] Créer un modèle conceptuel au propre (UML)
- [ ] Définir les objectifs d'optimisations (ex: Performance, lisibilité, modularité...)
# Étape 2 : Conception & Création de la base optimisée
- [x] Créer/modifier fichier ```create_tables_cy_tech.sql```
- [ ] Créer les tablespaces nécessaires
- [ ] Répartir les tables dans les bons tablespaces
- [ ] Définir et créer les index utiles (B-Tree ou Bitmap)
- [ ] Définir et créer des clusters pour les associations fréquentes (utilisateurs <-> profil/groupe)
- [ ] Créer des vues simplificatrices (logiques ou matérialisées)
# Étape 3 : Développement PL/SQL
- [ ]  Créer des triggers (ex: auto-incréments, MAJ totaux, horodatages)
- [ ]  Créer des fonctions (ex: statut d'un équipement)
- [ ] Créer des procédures (ex: assignation matériel, création user)
- [ ]  Utiliser des curseurs
- [ ] Ajouter gestions d'exception
- [ ] Créer un package PL/SQL global (ex: pck_glpi)
# Étape 4 : Base de données Répartie (BDDR)
- [ ] Réfléchir aux données à répartir en Cergy et Pau (ex: matériel, utilisateurs, réseaux)
- [ ] Mettre en oeuvre la fragmentation horizontale/verticale
- [ ] Créer des vues reconstituantes
- [ ] Mettre en place database link
- [ ] Gérer les transactions réparties
# Étape 5 : Génération de données & Tests
- [ ] Créer un script PL/SQL de génération de données
- [ ] Effectuer des tests de requêtes complexes
- [ ] [Bonus] Comparer les performances avec GLPI d'origine
- [ ] Analyser les plans d'exécution (EXPLAIN PLAN)
# Étape 6 : Livrables
- [ ] Rédiger un rapport complet (reverse eng., choix, résultats)
- [ ] Préparer la présentation orale (10 à 15 minutes)
- [ ] Regrouper tous les fichiers SQL + PL/SQL