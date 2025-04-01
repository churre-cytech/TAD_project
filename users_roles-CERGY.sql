------------------------------------------------------------------------------
-- Commands to check configuration
------------------------------------------------------------------------------
SELECT username FROM dba_users;
SELECT pdb_name FROM dba_pdbs;

-- Check CDB (container database)
SHOW CON_NAME;
SELECT sys_context('USERENV', 'CON_NAME') AS current_container FROM dual;



------------------------------------------------------------------------------
-- DROP USER CY_TECH_CERGY IF EXISTS
------------------------------------------------------------------------------
DROP USER CY_TECH_CERGY CASCADE;

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_CERGY (FIRST TO CREATE)
------------------------------------------------------------------------------
CREATE USER CY_TECH_CERGY
    IDENTIFIED BY cergy123
    DEFAULT TABLESPACE USERS       -- Remplacez USERS par le tablespace de données approprié
    TEMPORARY TABLESPACE TEMP      -- Remplacez TEMP par le tablespace temporaire de votre environnement
    QUOTA UNLIMITED ON USERS;        -- Ajustez le quota selon vos besoins

-- Attribution des privilèges nécessaires, incluant CREATE SESSION
GRANT CREATE SESSION,
        CREATE TABLE,
        CREATE VIEW,
        CREATE SEQUENCE,
        CREATE PROCEDURE,
        CREATE TRIGGER,
        ALTER SESSION,
        CREATE SYNONYM,
        CREATE DATABASE LINK,
        CREATE MATERIALIZED VIEW
    TO CY_TECH_CERGY;




------------------------------------------------------------------------------
-- DROP CERGY USERS IF EXIST
------------------------------------------------------------------------------
DROP USER ADMIN_CERGY CASCADE;
DROP USER IT_TECH_CERGY CASCADE;
DROP USER NETWORK_TECH_CERGY CASCADE;
DROP USER ACADEMIC_ADMIN_CERGY CASCADE;
DROP USER STUDENT_TEACHER_CERGY CASCADE;


------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Cergy
------------------------------------------------------------------------------
-- Utilisateur ADMIN_CERGY : aura tous les droits sur les objets de Cergy
CREATE USER ADMIN_CERGY IDENTIFIED BY adminCergy123;
-- Vous accorderez ultérieurement tous les privilèges d'administration nécessaires à cet utilisateur.

-- Utilisateur IT_TECH_CERGY : pour la gestion des assets (matériels) et des tickets
CREATE USER IT_TECH_CERGY IDENTIFIED BY itTechCergy123;
-- Privilèges à attribuer : gestion des tables d'assets, tickets, etc.

-- Utilisateur NETWORK_TECH_CERGY : pour la gestion des réseaux et des adresses IP
CREATE USER NETWORK_TECH_CERGY IDENTIFIED BY networkTechCergy123;
-- Privilèges à attribuer : gestion des objets liés aux réseaux et aux IP.

-- Utilisateur ACADEMIC_ADMIN_CERGY : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER ACADEMIC_ADMIN_CERGY IDENTIFIED BY academicAdminCergy123;
-- Privilèges à attribuer : modification et administration des comptes utilisateurs.

-- Utilisateur STUDENT_TEACHER_CERGY : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER STUDENT_TEACHER_CERGY IDENTIFIED BY studentTeacherCergy123;
-- Privilèges à attribuer : insertion et éventuellement consultation des tickets (que les tickets propres au user, pas de vue globale).



------------------------------------------------------------------------------
-- CREATION DES ROLES POUR LE SITE DE CERGY
------------------------------------------------------------------------------
-- Rôle administrateur : gestion globale et supervision du site
CREATE ROLE ROLE_ADMIN_CERGY;

-- Rôle IT techniciens : pour la gestion des assets (matériels) et des tickets
CREATE ROLE ROLE_IT_TECH_CERGY;

-- Rôle réseau : pour la gestion des réseaux et des adresses IP
-- (+ peut voir les assets et les assets_types existants)
CREATE ROLE ROLE_NETWORK_TECH_CERGY;

-- Rôle académique administrateur : pour la gestion des comptes utilisateurs (ajout, modification, etc.) 
-- + potentielle update des user_role. 
CREATE ROLE ROLE_ACADEMIC_ADMIN_CERGY;

-- Rôle étudiants/enseignants : qui insèrent (+ consultations) des tickets
CREATE ROLE ROLE_STUDENT_TEACHER_CERGY;


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

-- IT TECH CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET TO ROLE_IT_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.ASSET_TYPE TO ROLE_IT_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.TICKET TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.NETWORK TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_IT_TECH_CERGY;

-- NETWORK TECH CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.NETWORK TO ROLE_NETWORK_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.IP_ADDRESS TO ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.ASSET TO ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.ASSET_TYPE TO ROLE_NETWORK_TECH_CERGY;

-- ACADEMIC ADMIN CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ACCOUNT TO ROLE_ACADEMIC_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.USER_ROLE TO ROLE_ACADEMIC_ADMIN_CERGY;
GRANT SELECT, INSERT ON CY_TECH_CERGY.TICKET TO ROLE_ACADEMIC_ADMIN_CERGY;
-- FIXME : Voir si ajouter GRANT DELETE dans le cas : user veut retirer son ticket ?

-- STUDENT/TEACHER CERGY
GRANT SELECT, INSERT ON CY_TECH_CERGY.TICKET TO ROLE_STUDENT_TEACHER_CERGY;
-- FIXME : Voir si ajouter GRANT DELETE dans le cas : user veut retirer son ticket ?


------------------------------------------------------------------------------
-- GRANT ROLE TO USERS
------------------------------------------------------------------------------
-- ADMIN CERGY
GRANT ROLE_ADMIN_CERGY TO ADMIN_CERGY;

-- IT TECH CERGY
GRANT ROLE_IT_TECH_CERGY TO IT_TECH_CERGY;

-- NETWORK IT CERGY
GRANT ROLE_NETWORK_TECH_CERGY TO NETWORK_TECH_CERGY;

-- ACADEMIC ADMIN CERGY
GRANT ROLE_ACADEMIC_ADMIN_CERGY TO ACADEMIC_ADMIN_CERGY;

-- STUDENT/TEACHER CERGY
GRANT ROLE_STUDENT_TEACHER_CERGY TO STUDENT_TEACHER_CERGY;