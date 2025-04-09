# Projet TAD : Base de Données GLPI pour CY Tech

## Introduction

Ce projet a été réalisé dans le cadre du module Traitement et Administration des Données (TAD). Il porte sur l'optimisation de la base de données **GLPI**, un outil open-source de gestion de parc informatique, adaptée spécifiquement aux besoins de **CY Tech**. Un enjeu majeur était la prise en charge de **plusieurs sites**, notamment Cergy et Pau.

L'objectif principal était d'identifier les limites de la structure GLPI de base et de proposer une **nouvelle architecture optimisée**. Pour cela, nous avons mis en œuvre des concepts avancés de bases de données vus en cours, tels que :

* Tablespaces
* Clusters
* Index (optimisation des requêtes)
* PL/SQL (procédures, fonctions, triggers, curseurs)
* Vues matérialisées (mentionné comme concept, à vérifier si des scripts spécifiques existent)
* Bases de données réparties (pour gérer les sites de Cergy et Pau)

Ce document explique comment utiliser les scripts SQL fournis dans ce dépôt pour recréer l'architecture de base de données proposée sur vos propres instances Oracle.

## Contributeurs 

* David DEL CAMPO
* Simon CHANTHRABOUTH-LIEBBE
* Younes BENABDELLAH
  
## Prérequis

* **Deux instances de base de données Oracle** accessibles : une pour simuler le site de **Cergy**, une pour simuler le site de **Pau**.
* Un **client Oracle** (SQL*Plus, SQL Developer) installé et configuré pour pouvoir se connecter aux deux instances.
* Les **informations de connexion** (nom d'utilisateur, mot de passe, nom de service/SID ou chaîne de connexion TNS) pour un utilisateur ayant les privilèges suffisants (ex: `SYSTEM` ou un utilisateur DBA dédié) sur *chacune* des deux instances.
* Les **fichiers SQL** de ce dépôt clonés sur votre machine locale.

## Instructions d'Installation de la Base de Données

Suivez attentivement ces étapes **dans l'ordre indiqué**. Chaque étape précise sur quelle instance de base de données (Cergy ou Pau) les commandes doivent être exécutées.

---

### 1. Configuration Initiale de la Base de Données CENTRALISÉE Cergy

**➡️ Connectez-vous à l'instance de base de données CERGY.**

a.  **Créer les utilisateurs et rôles initiaux :**
    Exécutez le script suivant pour créer les schémas utilisateurs et les rôles nécessaires sur Cergy.
    ```sql
    @users_roles-CERGY.sql
    ```

b.  **Créer les tables spécifiques à CY Tech pour Cergy :**
    Ce script crée la structure des tables pour le site de Cergy.
    ```sql
    @create_tables_cy_tech-CERGY.sql
    ```

c.  **Insérer les données de test (peuplement aléatoire) :**
    Ce script peuple les tables de Cergy avec des données générées aléatoirement.
    ```sql
    @seed_data.sql
    ```

d.  **(Optionnel/Vérification) Attribuer les rôles et privilèges sur les tables :**
    Ce script est mentionné une seconde fois. Il peut servir à attribuer des privilèges spécifiques aux utilisateurs/rôles sur les tables fraîchement créées si ce n'est pas déjà fait dans le premier appel ou la création des tables.
    ```sql
    @users_roles-CERGY.sql
    ```

e.  **Créer les vues spécifiques à Cergy :**
    ```sql
    @views-CERGY.sql
    ```

f.  **Créer les index pour optimiser les requêtes sur Cergy :**
    ```sql
    @index_tables-CERGY.sql
    ```

g.  **Créer les clusters de tables sur Cergy :**
    ```sql
    @cluster_tables-CERGY.sql
    ```

---

### 2. Configuration de la Base de Données RÉPARTIE Pau et Répartition des Données

Cette section configure l'instance de Pau et établit la communication entre les deux bases.

a.  **Préparer la base Pau (Utilisateurs/Rôles) :**
    **➡️ Connectez-vous à l'instance de base de données PAU.**
    Naviguez dans le dossier `Pau_(distributed_database)` dans votre terminal ou assurez-vous que votre client SQL exécute le script depuis ce chemin relatif.
    ```sql
    @Pau_(distributed_database)/1.create_users_roles-PAU.sql
    ```

b.  **Créer les tables Pau :**
    **➡️ Toujours connecté à PAU.**
    ```sql
    @Pau_(distributed_database)/2.create_tables-PAU.sql
    ```

c.  **Attribuer les privilèges sur Pau :**
    **➡️ Toujours connecté à PAU.**
    ```sql
    @Pau_(distributed_database)/3.grant_privileges_to_users-PAU.sql
    ```

d.  **Créer le lien de base de données de Pau vers Cergy (`DB_LINK_CERGY`) :**
    **➡️ Toujours connecté à PAU.**
    Ce lien permettra à Pau d'interroger Cergy. Assurez-vous que la configuration réseau permet à l'instance Pau de contacter l'instance Cergy via les informations fournies *dans* le script SQL.
    ```sql
    @Pau_(distributed_database)/4.create_database_link-PAU.sql
    ```

e.  **Créer le lien de base de données de Cergy vers Pau (`DB_LINK_PAU`) :**
    **‼️➡️ IMPORTANT : Connectez-vous maintenant à l'instance de CERGY ‼️**
    Ce lien permettra à Cergy d'interroger Pau. Assurez-vous que la configuration réseau permet à l'instance Cergy de contacter l'instance Pau via les informations fournies *dans* le script SQL.
    ```sql
    @Pau_(distributed_database)/4bis.create_database_link-CERGY.sql
    ```

f.  **Insérer/Migrer les données distribuées (depuis Cergy vers Pau) :**
    **➡️ Toujours connecté à CERGY.**
    **⚠️ ATTENTION :** Ce script est critique. Il insère des données spécifiques au site de Pau *depuis Cergy* dans la base de Pau (via le `DB_LINK_PAU`) et **supprime ensuite ces mêmes données de la base de Cergy** pour finaliser la répartition.
    ```sql
    @Pau_(distributed_database)/5.insert_distributed_data_from_CERGY.sql
    ```

g.  **Créer les vues, index et clusters sur Pau :**
    **➡️ Connectez-vous à nouveau à l'instance de PAU.**
    Créez les objets spécifiques à Pau après l'insertion des données.
    ```sql
    @Pau_(distributed_database)/views-PAU.sql
    @Pau_(distributed_database)/index_tables-PAU.sql
    @Pau_(distributed_database)/cluster_tables-PAU.sql
    ```

---

### 3. Création des Vues Globales

Ces vues permettent potentiellement d'avoir une vision consolidée des données des deux sites.

**➡️ Connectez-vous à l'instance de CERGY.**
```sql
@global_views.sql
