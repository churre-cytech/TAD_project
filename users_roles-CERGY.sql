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
DROP USER C##CY_TECH_CERGY CASCADE;

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_CERGY (FIRST TO CREATE)
------------------------------------------------------------------------------
CREATE USER C##CY_TECH_CERGY
    IDENTIFIED BY cergy123
    DEFAULT TABLESPACE USERS       -- Remplacez USERS par le tablespace de données approprié
    TEMPORARY TABLESPACE TEMP      -- Remplacez TEMP par le tablespace temporaire de votre environnement
    QUOTA UNLIMITED ON USERS;        -- Ajustez le quota selon vos besoins

-- Attribution des privilèges nécessaires
GRANT DBA, RESOURCE, CONNECT TO C##CY_TECH_CERGY;




------------------------------------------------------------------------------
-- DROP CERGY USERS IF EXIST
------------------------------------------------------------------------------
DROP USER C##ADMIN_CERGY CASCADE;
DROP USER C##IT_TECH_CERGY CASCADE;
DROP USER C##NETWORK_TECH_CERGY CASCADE;
DROP USER C##ACADEMIC_ADMIN_CERGY CASCADE;
DROP USER C##STUDENT_TEACHER_CERGY CASCADE;


------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Cergy
------------------------------------------------------------------------------
-- Utilisateur ADMIN_CERGY : aura tous les droits sur les objets de Cergy
CREATE USER C##ADMIN_CERGY IDENTIFIED BY adminCergy123;
-- Vous accorderez ultérieurement tous les privilèges d'administration nécessaires à cet utilisateur.

-- Utilisateur IT_TECH_CERGY : pour la gestion des assets (matériels) et des tickets
CREATE USER C##IT_TECH_CERGY IDENTIFIED BY itTechCergy123;
-- Privilèges à attribuer : gestion des tables d'assets, tickets, etc.

-- Utilisateur NETWORK_TECH_CERGY : pour la gestion des réseaux et des adresses IP
CREATE USER C##NETWORK_TECH_CERGY IDENTIFIED BY networkTechCergy123;
-- Privilèges à attribuer : gestion des objets liés aux réseaux et aux IP.

-- Utilisateur ACADEMIC_ADMIN_CERGY : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER C##ACADEMIC_ADMIN_CERGY IDENTIFIED BY academicAdminCergy123;
-- Privilèges à attribuer : modification et administration des comptes utilisateurs.

-- Utilisateur STUDENT_TEACHER_CERGY : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER C##STUDENT_TEACHER_CERGY IDENTIFIED BY studentTeacherCergy123;
-- Privilèges à attribuer : insertion et éventuellement consultation des tickets (que les tickets propres au user, pas de vue globale).

------------------------------------------------------------------------------
-- GRANT CREATE SESSION Pour que les USER puissent se connecter
------------------------------------------------------------------------------
GRANT CREATE SESSION TO C##ADMIN_CERGY;
GRANT CREATE SESSION TO C##IT_TECH_CERGY;
GRANT CREATE SESSION TO C##NETWORK_TECH_CERGY;
GRANT CREATE SESSION TO C##ACADEMIC_ADMIN_CERGY;
GRANT CREATE SESSION TO C##STUDENT_TEACHER_CERGY;

------------------------------------------------------------------------------
-- DROP CERGY ROLE IF EXIST
------------------------------------------------------------------------------
DROP ROLE C##ROLE_ADMIN_CERGY;
DROP ROLE C##ROLE_IT_TECH_CERGY;
DROP ROLE C##ROLE_NETWORK_TECH_CERGY;
DROP ROLE C##ROLE_ACADEMIC_ADMIN_CERGY;
DROP ROLE C##ROLE_STUDENT_TEACHER_CERGY;


------------------------------------------------------------------------------
-- CREATION DES ROLES POUR LE SITE DE CERGY
------------------------------------------------------------------------------
-- Rôle administrateur : gestion globale et supervision du site
CREATE ROLE C##ROLE_ADMIN_CERGY;

-- Rôle IT techniciens : pour la gestion des assets (matériels) et des tickets
CREATE ROLE C##ROLE_IT_TECH_CERGY;

-- Rôle réseau : pour la gestion des réseaux et des adresses IP
-- (+ peut voir les assets et les assets_types existants)
CREATE ROLE C##ROLE_NETWORK_TECH_CERGY;

-- Rôle académique administrateur : pour la gestion des comptes utilisateurs (ajout, modification, etc.) 
-- + potentielle update des user_role. 
CREATE ROLE C##ROLE_ACADEMIC_ADMIN_CERGY;

-- Rôle étudiants/enseignants : qui insèrent (+ consultations) des tickets
CREATE ROLE C##ROLE_STUDENT_TEACHER_CERGY;


------------------------------------------------------------------------------
-- GRANT PRIVILEGE TO ROLE
------------------------------------------------------------------------------
-- ADMIN CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.USER_ACCOUNT TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.USER_ROLE TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.SITE TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.ASSET TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.ASSET_TYPE TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.TICKET TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.NETWORK TO C##ROLE_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.IP_ADDRESS TO C##ROLE_ADMIN_CERGY;

-- IT TECH CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.ASSET TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.ASSET_TYPE TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.TICKET TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.NETWORK TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.IP_ADDRESS TO C##ROLE_IT_TECH_CERGY;

-- NETWORK TECH CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.NETWORK TO C##ROLE_NETWORK_TECH_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.IP_ADDRESS TO C##ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.ASSET TO C##ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.ASSET_TYPE TO C##ROLE_NETWORK_TECH_CERGY;

-- ACADEMIC ADMIN CERGY
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.USER_ACCOUNT TO C##ROLE_ACADEMIC_ADMIN_CERGY;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_CERGY.USER_ROLE TO C##ROLE_ACADEMIC_ADMIN_CERGY;
GRANT SELECT, INSERT ON C##CY_TECH_CERGY.TICKET TO C##ROLE_ACADEMIC_ADMIN_CERGY;

-- STUDENT/TEACHER CERGY
GRANT SELECT, INSERT ON C##CY_TECH_CERGY.TICKET TO C##ROLE_STUDENT_TEACHER_CERGY;


------------------------------------------------------------------------------
-- GRANT ROLE TO USERS
------------------------------------------------------------------------------
-- ADMIN CERGY
GRANT C##ROLE_ADMIN_CERGY TO C##ADMIN_CERGY;

-- IT TECH CERGY
GRANT C##ROLE_IT_TECH_CERGY TO C##IT_TECH_CERGY;

-- NETWORK IT CERGY
GRANT C##ROLE_NETWORK_TECH_CERGY TO C##NETWORK_TECH_CERGY;

-- ACADEMIC ADMIN CERGY
GRANT C##ROLE_ACADEMIC_ADMIN_CERGY TO C##ACADEMIC_ADMIN_CERGY;

-- STUDENT/TEACHER CERGY
GRANT C##ROLE_STUDENT_TEACHER_CERGY TO C##STUDENT_TEACHER_CERGY;