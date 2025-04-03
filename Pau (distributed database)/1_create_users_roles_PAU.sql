------------------------------------------------------------------------------
-- DROP USER CY_TECH_PAU IF EXISTS
------------------------------------------------------------------------------
DROP USER CY_TECH_PAU CASCADE;

------------------------------------------------------------------------------
-- Création de l'utilisateur CY_TECH_PAU ATTENTION : A FAIRE EN PREMIER
------------------------------------------------------------------------------
CREATE USER CY_TECH_PAU
    IDENTIFIED BY pau123
    DEFAULT TABLESPACE USERS     
    TEMPORARY TABLESPACE TEMP      
    QUOTA UNLIMITED ON USERS;      

-- Attribution des privilèges nécessaires
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_PAU;


------------------------------------------------------------------------------
-- DROP PAU USERS 
------------------------------------------------------------------------------
DROP USER ADMIN_PAU CASCADE;
DROP USER IT_TECH_PAU CASCADE;
DROP USER NETWORK_TECH_PAU CASCADE;
DROP USER ACADEMIC_ADMIN_PAU CASCADE;
DROP USER STUDENT_TEACHER_PAU CASCADE;


------------------------------------------------------------------------------
-- Création des utilisateurs pour le site de Pau
------------------------------------------------------------------------------
-- Utilisateur ADMIN_PAU : aura tous les droits sur les objets de Pau
CREATE USER ADMIN_PAU IDENTIFIED BY adminPau123;
-- Vous accorderez ultérieurement tous les privilèges d'administration nécessaires à cet utilisateur.

-- Utilisateur IT_TECH_PAU : pour la gestion des assets (matériels) et des tickets
CREATE USER IT_TECH_PAU IDENTIFIED BY itTechPau123;
-- Privilèges à attribuer : gestion des tables d'assets, tickets, etc.

-- Utilisateur NETWORK_TECH_PAU : pour la gestion des réseaux et des adresses IP
CREATE USER NETWORK_TECH_PAU IDENTIFIED BY networkTechPau123;
-- Privilèges à attribuer : gestion des objets liés aux réseaux et aux IP.

-- Utilisateur ACADEMIC_ADMIN_PAU : responsable de la gestion des comptes utilisateurs (ajout, modification, etc.)
CREATE USER ACADEMIC_ADMIN_PAU IDENTIFIED BY academicAdminPau123;
-- Privilèges à attribuer : modification et administration des comptes utilisateurs.

-- Utilisateur STUDENT_TEACHER_PAU : aura des droits limités, par exemple, pour insérer des tickets uniquement
CREATE USER STUDENT_TEACHER_PAU IDENTIFIED BY studentTeacherPau123;
-- Privilèges à attribuer : insertion et éventuellement consultation des tickets (que les tickets propres au user, pas de vue globale).




------------------------------------------------------------------------------
-- DROP PAU ROLE IF EXIST
------------------------------------------------------------------------------
DROP ROLE ROLE_ADMIN_PAU;
DROP ROLE ROLE_IT_TECH_PAU;
DROP ROLE ROLE_NETWORK_TECH_PAU;
DROP ROLE ROLE_ACADEMIC_ADMIN_PAU;
DROP ROLE ROLE_STUDENT_TEACHER_PAU;


------------------------------------------------------------------------------
-- CREATION DES ROLES POUR LE SITE DE PAU
------------------------------------------------------------------------------
-- Rôle administrateur : gestion globale et supervision du site
CREATE ROLE ROLE_ADMIN_PAU;

-- Rôle IT techniciens : pour la gestion des assets (matériels) et des tickets
CREATE ROLE ROLE_IT_TECH_PAU;

-- Rôle réseau : pour la gestion des réseaux et des adresses IP
-- (+ peut voir les assets et les assets_types existants)
CREATE ROLE ROLE_NETWORK_TECH_PAU;

-- Rôle académique administrateur : pour la gestion des comptes utilisateurs (ajout, modification, etc.) 
-- + potentielle update des user_role. 
CREATE ROLE ROLE_ACADEMIC_ADMIN_PAU;

-- Rôle étudiants/enseignants : qui insèrent (+ consultations) des tickets
CREATE ROLE ROLE_STUDENT_TEACHER_PAU;