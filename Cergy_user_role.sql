------------------------------------------------------------------------------
-- DROP USER
------------------------------------------------------------------------------
DROP USER C##ADMIN_CERGY CASCADE;
DROP USER C##TECH_CERGY CASCADE;
DROP USER C##RESEAU_CERGY CASCADE;
DROP USER C##USER_CERGY CASCADE;

------------------------------------------------------------------------------
-- USER CREATION
------------------------------------------------------------------------------

CREATE USER C##ADMIN_CERGY IDENTIFIED BY adminCergy123;  -- Possèdera tout les droits sur Cergy

CREATE USER C##TECH_CERGY IDENTIFIED BY techCergy123;  -- Possèdera les droits pour la gestion des assets (matériels) et tickets sur Cergy

CREATE USER C##RESEAU_CERGY IDENTIFIED BY reseauCergy123;  -- Droits pour la gestion des réseaux et IP sur Cergy

-- Utilisateur : Etudiant, professeur, employé, etc.
CREATE USER C##USER_CERGY IDENTIFIED BY userCergy123;  -- Possèdera les droits pour insérer des tickets uniquement sur Cergy

------------------------------------------------------------------------------
-- ROLE CREATION
------------------------------------------------------------------------------

-- Rôle administrateurs
CREATE ROLE ROLE_ADMIN_CERGY;

-- Rôles techniciens
CREATE ROLE ROLE_TECH_CERGY;

-- Rôles réseau
CREATE ROLE ROLE_RESEAU_CERGY;

-- Rôles utilisateurs simples
CREATE ROLE ROLE_USER_CERGY;

------------------------------------------------------------------------------
-- GRANT PRIVILEGE TO ROLE
------------------------------------------------------------------------------

-- ADMIN CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ACCOUNT TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ROLE TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.SITE TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET_TYPE TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.TICKET TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.NETWORK TO ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_ADMIN_CERGY;

-- TECHNICIEN CERGY
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.ASSET TO ROLE_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.TICKET TO ROLE_TECH_CERGY;

-- TECHNICIEN RÉSEAU CERGY
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.NETWORK TO ROLE_RESEAU_CERGY;
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_RESEAU_CERGY;
GRANT SELECT ON CY_TECH_CERGY.ASSET TO ROLE_RESEAU_CERGY;

-- UTILISATEUR CERGY
GRANT INSERT ON CY_TECH_CERGY.TICKET TO ROLE_USER_CERGY;

------------------------------------------------------------------------------
-- GRANT ROLE TO USER
------------------------------------------------------------------------------

-- Admin Cergy
GRANT ROLE_ADMIN_CERGY TO C##ADMIN_CERGY;

-- Technicien Cergy
GRANT ROLE_TECH_CERGY TO C##TECH_CERGY;

-- Responsable Réseau Cergy
GRANT ROLE_RESEAU_CERGY TO C##RESEAU_CERGY;

-- Utilisateur standard Cergy
GRANT ROLE_USER_CERGY TO C##USER_CERGY;