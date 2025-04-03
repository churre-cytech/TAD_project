------------------------------------------------------------------------------
-- Commands to check configuration
------------------------------------------------------------------------------
SELECT username FROM dba_users;
SELECT pdb_name FROM dba_pdbs;
SELECT role FROM dba_roles;

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

-- Attribution des privilèges nécessaires
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_CERGY;




------------------------------------------------------------------------------
-- DROP CERGY USERS IF EXIST
------------------------------------------------------------------------------
DROP USER ADMIN_CERGY CASCADE;
DROP USER IT_MANAGER_TECH_CERGY CASCADE;
DROP USER IT_TECH_CERGY CASCADE;
DROP USER NETWORK_TECH_CERGY CASCADE;
DROP USER ACADEMIC_ADMIN_CERGY CASCADE;
DROP USER STUDENT_TEACHER_CERGY CASCADE;
/

------------------------------------------------------------------------------
-- DROP CERGY ROLE IF EXIST
------------------------------------------------------------------------------
DROP ROLE ROLE_ADMIN_CERGY;
DROP ROLE ROLE_IT_TECH_CERGY;
DROP ROLE ROLE_NETWORK_TECH_CERGY;
DROP ROLE ROLE_ACADEMIC_ADMIN_CERGY;
DROP ROLE ROLE_STUDENT_TEACHER_CERGY;
/


-- #####################################################################################
-- (launch in sys-connnection)
-- #####################################################################################
------------------------------------------------------------------------------
-- DROP USER CY_TECH_CERGY IF EXISTS (with CASCADE)
------------------------------------------------------------------------------
DROP USER CY_TECH_CERGY CASCADE;
/

------------------------------------------------------------------------------
-- DROP TABLESPACE CY_TECH_CERGY_DATA IF EXISTS (with contents and datafiles)
------------------------------------------------------------------------------
DROP TABLESPACE CY_TECH_CERGY_DATA INCLUDING CONTENTS AND DATAFILES;
/

------------------------------------------------------------------------------
-- Création du tablespace pour CY_TECH_CERGY
------------------------------------------------------------------------------
CREATE TABLESPACE CY_TECH_CERGY_DATA
DATAFILE 'CY_TECH_CERGY_DATA.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
/

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_CERGY (première création)
------------------------------------------------------------------------------
CREATE USER CY_TECH_CERGY
    IDENTIFIED BY cergy123
    DEFAULT TABLESPACE CY_TECH_CERGY_DATA
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON CY_TECH_CERGY_DATA;
/

------------------------------------------------------------------------------
-- Attribution des privilèges nécessaires à l'utilisateur
------------------------------------------------------------------------------
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_CERGY;
/



--------------------------------------------------------------------------------------------------------
-- CREATE SCRIPT
--------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Cergy
------------------------------------------------------------------------------
-- Utilisateur ADMIN_CERGY : aura tous les droits sur les objets de Cergy
CREATE USER ADMIN_CERGY IDENTIFIED BY adminCergy123;

-- Utilisateur IT_TECH_CERGY : pour la gestion des assets (matériels) et des tickets
CREATE USER IT_MANAGER_TECH_CERGY IDENTIFIED BY itTechManagerCergy123;
CREATE USER IT_TECH_CERGY IDENTIFIED BY itTechCergy123;

-- Utilisateur NETWORK_TECH_CERGY : pour la gestion des réseaux et des adresses IP
CREATE USER NETWORK_TECH_CERGY IDENTIFIED BY networkTechCergy123;

-- Utilisateur ACADEMIC_ADMIN_CERGY : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER ACADEMIC_ADMIN_CERGY IDENTIFIED BY academicAdminCergy123;

-- Utilisateur STUDENT_TEACHER_CERGY : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER STUDENT_TEACHER_CERGY IDENTIFIED BY studentTeacherCergy123;


------------------------------------------------------------------------------
-- GRANT CREATE SESSION pour que les users puissent se connecter
------------------------------------------------------------------------------
GRANT CREATE SESSION TO ADMIN_CERGY;
GRANT CREATE SESSION TO IT_MANAGER_TECH_CERGY;
GRANT CREATE SESSION TO IT_TECH_CERGY;
GRANT CREATE SESSION TO NETWORK_TECH_CERGY;
GRANT CREATE SESSION TO ACADEMIC_ADMIN_CERGY;
GRANT CREATE SESSION TO STUDENT_TEACHER_CERGY;


------------------------------------------------------------------------------
-- CREATE ROLE POUR LE SITE DE CERGY
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

-- STUDENT/TEACHER CERGY
GRANT SELECT, INSERT ON CY_TECH_CERGY.TICKET TO ROLE_STUDENT_TEACHER_CERGY;


------------------------------------------------------------------------------
-- GRANT ROLE TO USERS
------------------------------------------------------------------------------
-- ADMIN CERGY
GRANT ROLE_ADMIN_CERGY TO ADMIN_CERGY;

-- IT TECH CERGY
GRANT ROLE_IT_TECH_CERGY TO IT_MANAGER_TECH_CERGY;
GRANT ROLE_IT_TECH_CERGY TO IT_TECH_CERGY;

-- NETWORK IT CERGY
GRANT ROLE_NETWORK_TECH_CERGY TO NETWORK_TECH_CERGY;

-- ACADEMIC ADMIN CERGY
GRANT ROLE_ACADEMIC_ADMIN_CERGY TO ACADEMIC_ADMIN_CERGY;

-- STUDENT/TEACHER CERGY
GRANT ROLE_STUDENT_TEACHER_CERGY TO STUDENT_TEACHER_CERGY;



-- CY_TECH_ADMIN CREATION
CREATE USER CY_TECH_ADMIN IDENTIFIED BY admin123;
GRANT ROLE_ADMIN_CERGY TO CY_TECH_ADMIN;
GRANT ROLE_ADMIN_PAU TO CY_TECH_ADMIN;
GRANT CREATE SESSION TO CY_TECH_ADMIN;
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_CERGY.view_state_asset_user TO CY_TECH_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.view_state_asset_user TO CY_TECH_ADMIN;
