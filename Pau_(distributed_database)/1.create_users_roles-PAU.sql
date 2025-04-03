
------------------------------------------------------------------------------
-- DROP PAU USERS 
------------------------------------------------------------------------------
DROP USER ADMIN_PAU CASCADE;
DROP USER IT_MANAGER_TECH_PAU CASCADE;
DROP USER IT_TECH_PAU CASCADE;
DROP USER NETWORK_TECH_PAU CASCADE;
DROP USER ACADEMIC_ADMIN_PAU CASCADE;
DROP USER STUDENT_TEACHER_PAU CASCADE;
/

------------------------------------------------------------------------------
-- DROP PAU ROLE IF EXIST
------------------------------------------------------------------------------
DROP ROLE ROLE_ADMIN_PAU;
DROP ROLE ROLE_IT_TECH_PAU;
DROP ROLE ROLE_NETWORK_TECH_PAU;
DROP ROLE ROLE_ACADEMIC_ADMIN_PAU;
DROP ROLE ROLE_STUDENT_TEACHER_PAU;
/


-- #####################################################################################
-- (launch in sys-connnection)
-- #####################################################################################
------------------------------------------------------------------------------
-- DROP USER CY_TECH_PAU IF EXISTS (with CASCADE) 
------------------------------------------------------------------------------
DROP USER CY_TECH_PAU CASCADE;
/

------------------------------------------------------------------------------
-- DROP TABLESPACE CY_TECH_PAU_DATA IF EXISTS (with contents and datafiles)
------------------------------------------------------------------------------
DROP TABLESPACE CY_TECH_PAU_DATA INCLUDING CONTENTS AND DATAFILES;
/

------------------------------------------------------------------------------
-- Création du tablespace pour CY_TECH_PAU
------------------------------------------------------------------------------
CREATE TABLESPACE CY_TECH_PAU_DATA
DATAFILE 'CY_TECH_PAU_DATA.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL AUTOALLOCATE;
/

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_PAU (première création)
------------------------------------------------------------------------------
------------------------------------------------------------------------------
CREATE USER CY_TECH_PAU
    IDENTIFIED BY pau123
    DEFAULT TABLESPACE CY_TECH_PAU_DATA     
    TEMPORARY TABLESPACE TEMP      
    QUOTA UNLIMITED ON CY_TECH_PAU_DATA;      
/

-- Attribution des privilèges nécessaires
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_PAU;



-- #####################################################################################
-- (launch in CY_TECH_PAU-connnection)
-- #####################################################################################
--------------------------------------------------------------------------------------------------------
-- CREATE SCRIPT
--------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Pau
------------------------------------------------------------------------------
-- Utilisateur ADMIN_PAU : aura tous les droits sur les objets de Pau
CREATE USER ADMIN_PAU IDENTIFIED BY adminPau123;

-- Utilisateur IT_TECH_PAU : pour la gestion des assets (matériels) et des tickets
CREATE USER IT_MANAGER_TECH_PAU IDENTIFIED BY itTechManagerPau123;
CREATE USER IT_TECH_PAU IDENTIFIED BY itTechPau123;

-- Utilisateur NETWORK_TECH_PAU : pour la gestion des réseaux et des adresses IP
CREATE USER NETWORK_TECH_PAU IDENTIFIED BY networkTechPau123;

-- Utilisateur ACADEMIC_ADMIN_PAU : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER ACADEMIC_ADMIN_PAU IDENTIFIED BY academicAdminPau123;

-- Utilisateur STUDENT_TEACHER_PAU : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER STUDENT_TEACHER_PAU IDENTIFIED BY studentTeacherPau123;


------------------------------------------------------------------------------
-- GRANT CREATE SESSION pour que les users puissent se connecter
------------------------------------------------------------------------------
GRANT CREATE SESSION TO ADMIN_PAU;
GRANT CREATE SESSION TO IT_MANAGER_TECH_PAU;
GRANT CREATE SESSION TO IT_TECH_PAU;
GRANT CREATE SESSION TO NETWORK_TECH_PAU;
GRANT CREATE SESSION TO ACADEMIC_ADMIN_PAU;
GRANT CREATE SESSION TO STUDENT_TEACHER_PAU;
