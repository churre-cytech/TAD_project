------------------------------------------------------------------------------
-- USER CREATION
------------------------------------------------------------------------------

CREATE USER CY_TECH_PAU IDENTIFIED BY pau123;  -- Base de donnée de Pau

CREATE USER ADMIN_PAU IDENTIFIED BY adminPau123;  -- Possèdera tout les droits sur Pau

CREATE USER TECH_PAU IDENTIFIED BY techPau123;  -- Possèdera les droits pour la gestion des assets (matériels) et tickets sur Pau

CREATE USER RESEAU_PAU IDENTIFIED BY reseauPau123;  -- Droits pour la gestion des réseaux et IP sur Pau

-- Utilisateur : Etudiant, professeur, employé, etc.
CREATE USER USER_PAU IDENTIFIED BY userPau123;  -- Possèdera les droits pour insérer des tickets uniquement sur Pau

CREATE USER C##SUPERADMIN_CY_TECH IDENTIFIED BY superAdmin123;  -- Possèdera tout les droits sur Cergy ET Pau (user où les tests seront utilisés)
------------------------------------------------------------------------------
-- ROLE CREATION
------------------------------------------------------------------------------

-- Rôle super administrateurs
CREATE ROLE ROLE_SUPERADMIN;

-- Rôle administrateurs
CREATE ROLE ROLE_ADMIN_PAU;

CREATE ROLE ROLE_TECH_PAU;

CREATE ROLE ROLE_RESEAU_PAU;

CREATE ROLE ROLE_USER_PAU;

------------------------------------------------------------------------------
-- GRANT PRIVILEGE TO ROLE
------------------------------------------------------------------------------


-- SUPER ADMIN (délégation de role)
GRANT ROLE_ADMIN_CERGY TO ROLE_SUPERADMIN;
GRANT ROLE_ADMIN_PAU TO ROLE_SUPERADMIN;

-- ADMIN PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ACCOUNT TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ROLE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.SITE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET_TYPE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.TICKET TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.NETWORK TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_ADMIN_PAU;

-- TECHNICIEN PAU
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.ASSET TO ROLE_TECH_PAU;
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.TICKET TO ROLE_TECH_PAU;

-- TECHNICIEN RÉSEAU PAU
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.NETWORK TO ROLE_RESEAU_PAU;
GRANT SELECT, INSERT, UPDATE ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_RESEAU_PAU;
GRANT SELECT ON CY_TECH_CERGY.ASSET TO ROLE_RESEAU_PAU;

-- UTILISATEUR PAU
GRANT INSERT ON CY_TECH_CERGY.TICKET TO ROLE_USER_PAU;

------------------------------------------------------------------------------
-- GRANT ROLE TO USER
------------------------------------------------------------------------------

-- Superadmin 
GRANT ROLE_SUPERADMIN TO  C##SUPERADMIN_CY_TECH;

-- Admin Cergy
GRANT ROLE_ADMIN_CERGY TO C##ADMIN_CERGY;

-- Technicien Cergy
GRANT ROLE_TECH_CERGY TO C##TECH_CERGY;

-- Responsable Réseau Cergy
GRANT ROLE_RESEAU_CERGY TO C##RESEAU_CERGY;

-- Utilisateur standard Cergy
GRANT ROLE_USER_CERGY TO C##USER_CERGY;