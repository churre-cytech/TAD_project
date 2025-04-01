------------------------------------------------------------------------------
-- Commands to check configuration
------------------------------------------------------------------------------
SELECT username FROM dba_users;
SELECT pdb_name FROM dba_pdbs;

-- Check CDB (container database)
SHOW CON_NAME;
SELECT sys_context('USERENV', 'CON_NAME') AS current_container FROM dual;




------------------------------------------------------------------------------
-- DROP USER CY_TECH_PAU IF EXISTS
------------------------------------------------------------------------------
DROP USER C##CY_TECH_PAU CASCADE;

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_PAU
------------------------------------------------------------------------------
CREATE USER C##CY_TECH_PAU
    IDENTIFIED BY pau123
    DEFAULT TABLESPACE USERS       -- Remplacez USERS par le tablespace de données approprié
    TEMPORARY TABLESPACE TEMP      -- Remplacez TEMP par le tablespace temporaire de votre environnement
    QUOTA UNLIMITED ON USERS;        -- Ajustez le quota selon vos besoins

-- Attribution des privilèges nécessaires
GRANT DBA, RESOURCE, CONNECT TO C##CY_TECH_PAU;




------------------------------------------------------------------------------
-- DROP PAU USERS IF EXIST
------------------------------------------------------------------------------
DROP USER C##ADMIN_PAU CASCADE;
DROP USER C##IT_TECH_PAU CASCADE;
DROP USER C##NETWORK_TECH_PAU CASCADE;
DROP USER C##ACADEMIC_ADMIN_PAU CASCADE;
DROP USER C##STUDENT_TEACHER_PAU CASCADE;


------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Pau
------------------------------------------------------------------------------
-- Utilisateur ADMIN_PAU : aura tous les droits sur les objets de Pau
CREATE USER C##ADMIN_PAU IDENTIFIED BY adminPau123;
-- Vous accorderez ultérieurement tous les privilèges d'administration nécessaires à cet utilisateur.

-- Utilisateur IT_TECH_PAU : pour la gestion des assets (matériels) et des tickets
CREATE USER C##IT_TECH_PAU IDENTIFIED BY itTechPau123;
-- Privilèges à attribuer : gestion des tables d'assets, tickets, etc.

-- Utilisateur NETWORK_TECH_PAU : pour la gestion des réseaux et des adresses IP
CREATE USER C##NETWORK_TECH_PAU IDENTIFIED BY networkTechPau123;
-- Privilèges à attribuer : gestion des objets liés aux réseaux et aux IP.

-- Utilisateur ACADEMIC_ADMIN_PAU : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER C##ACADEMIC_ADMIN_PAU IDENTIFIED BY academicAdminPau123;
-- Privilèges à attribuer : modification et administration des comptes utilisateurs.

-- Utilisateur STUDENT_TEACHER_PAU : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER C##STUDENT_TEACHER_PAU IDENTIFIED BY studentTeacherPau123;
-- Privilèges à attribuer : insertion et éventuellement consultation des tickets (que les tickets propres au user, pas de vue globale).




------------------------------------------------------------------------------
-- DROP PAU ROLE IF EXIST
------------------------------------------------------------------------------
DROP ROLE C##ROLE_ADMIN_PAU;
DROP ROLE C##ROLE_IT_TECH_PAU;
DROP ROLE C##ROLE_NETWORK_TECH_PAU;
DROP ROLE C##ROLE_ACADEMIC_ADMIN_PAU;
DROP ROLE C##ROLE_STUDENT_TEACHER_PAU;


------------------------------------------------------------------------------
-- CREATION DES ROLES POUR LE SITE DE PAU
------------------------------------------------------------------------------
-- Rôle administrateur : gestion globale et supervision du site
CREATE ROLE C##ROLE_ADMIN_PAU;

-- Rôle IT techniciens : pour la gestion des assets (matériels) et des tickets
CREATE ROLE C##ROLE_IT_TECH_PAU;

-- Rôle réseau : pour la gestion des réseaux et des adresses IP
-- (+ peut voir les assets et les assets_types existants)
CREATE ROLE C##ROLE_NETWORK_TECH_PAU;

-- Rôle académique administrateur : pour la gestion des comptes utilisateurs (ajout, modification, etc.) 
-- + potentielle update des user_role. 
CREATE ROLE C##ROLE_ACADEMIC_ADMIN_PAU;

-- Rôle étudiants/enseignants : qui insèrent (+ consultations) des tickets
CREATE ROLE C##ROLE_STUDENT_TEACHER_PAU;


------------------------------------------------------------------------------
-- GRANT PRIVILEGE TO ROLE
------------------------------------------------------------------------------
-- ADMIN PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.USER_ACCOUNT TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.USER_ROLE TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.SITE TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.ASSET TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.ASSET_TYPE TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.TICKET TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.NETWORK TO C##ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.IP_ADDRESS TO C##ROLE_ADMIN_PAU;

-- IT TECH PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.ASSET TO C##ROLE_IT_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.ASSET_TYPE TO C##ROLE_IT_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.TICKET TO C##ROLE_IT_TECH_PAU;
GRANT SELECT ON C##CY_TECH_PAU.NETWORK TO C##ROLE_IT_TECH_PAU;
GRANT SELECT ON C##CY_TECH_PAU.IP_ADDRESS TO C##ROLE_IT_TECH_PAU;

-- NETWORK TECH PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.NETWORK TO C##ROLE_NETWORK_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.IP_ADDRESS TO C##ROLE_NETWORK_TECH_PAU;
GRANT SELECT ON C##CY_TECH_PAU.ASSET TO C##ROLE_NETWORK_TECH_PAU;
GRANT SELECT ON C##CY_TECH_PAU.ASSET_TYPE TO C##ROLE_NETWORK_TECH_PAU;

-- ACADEMIC ADMIN PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.USER_ACCOUNT TO C##ROLE_ACADEMIC_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON C##CY_TECH_PAU.USER_ROLE TO C##ROLE_ACADEMIC_ADMIN_PAU;
GRANT SELECT, INSERT ON C##CY_TECH_PAU.TICKET TO C##ROLE_ACADEMIC_ADMIN_PAU;

-- STUDENT/TEACHER PAU
GRANT SELECT, INSERT ON C##CY_TECH_PAU.TICKET TO C##ROLE_STUDENT_TEACHER_PAU;


------------------------------------------------------------------------------
-- GRANT ROLE TO USERS
------------------------------------------------------------------------------
-- ADMIN PAU
GRANT C##ROLE_ADMIN_PAU TO C##ADMIN_PAU;

-- IT TECH PAU
GRANT C##ROLE_IT_TECH_PAU TO C##IT_TECH_PAU;

-- NETWORK IT PAU
GRANT C##ROLE_NETWORK_TECH_PAU TO C##NETWORK_TECH_PAU;

-- ACADEMIC ADMIN PAU
GRANT C##ROLE_ACADEMIC_ADMIN_PAU TO C##ACADEMIC_ADMIN_PAU;

-- STUDENT/TEACHER PAU
GRANT C##ROLE_STUDENT_TEACHER_PAU TO C##STUDENT_TEACHER_PAU;