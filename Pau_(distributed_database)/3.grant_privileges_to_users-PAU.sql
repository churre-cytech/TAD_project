-- ##########################################################################################
-- Une fois que toutes les tables sont crées, on peut attribuer les rôles sur les tables
-- ##########################################################################################


-- #####################################################################################
-- (launch in CY_TECH_PAU-connnection)
-- #####################################################################################
------------------------------------------------------------------------------
-- CREATE ROLE POUR LE SITE DE PAU
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


------------------------------------------------------------------------------
-- GRANT PRIVILEGE TO ROLE
------------------------------------------------------------------------------
-- ADMIN PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.USER_ACCOUNT TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.USER_ROLE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.SITE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.ASSET TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.ASSET_TYPE TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.TICKET TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.NETWORK TO ROLE_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.IP_ADDRESS TO ROLE_ADMIN_PAU;

-- IT TECH PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.ASSET TO ROLE_IT_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.ASSET_TYPE TO ROLE_IT_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.TICKET TO ROLE_IT_TECH_PAU;
GRANT SELECT ON CY_TECH_PAU.NETWORK TO ROLE_IT_TECH_PAU;
GRANT SELECT ON CY_TECH_PAU.IP_ADDRESS TO ROLE_IT_TECH_PAU;

-- NETWORK TECH PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.NETWORK TO ROLE_NETWORK_TECH_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.IP_ADDRESS TO ROLE_NETWORK_TECH_PAU;
GRANT SELECT ON CY_TECH_PAU.ASSET TO ROLE_NETWORK_TECH_PAU;
GRANT SELECT ON CY_TECH_PAU.ASSET_TYPE TO ROLE_NETWORK_TECH_PAU;

-- ACADEMIC ADMIN PAU
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.USER_ACCOUNT TO ROLE_ACADEMIC_ADMIN_PAU;
GRANT SELECT, INSERT, UPDATE, DELETE ON CY_TECH_PAU.USER_ROLE TO ROLE_ACADEMIC_ADMIN_PAU;
GRANT SELECT, INSERT ON CY_TECH_PAU.TICKET TO ROLE_ACADEMIC_ADMIN_PAU;

-- STUDENT/TEACHER PAU
GRANT SELECT, INSERT ON CY_TECH_PAU.TICKET TO ROLE_STUDENT_TEACHER_PAU;


------------------------------------------------------------------------------
-- GRANT ROLE TO USERS
------------------------------------------------------------------------------
-- ADMIN PAU
GRANT ROLE_ADMIN_PAU TO ADMIN_PAU;

-- IT TECH PAU
GRANT ROLE_IT_TECH_PAU TO IT_MANAGER_TECH_PAU;
GRANT ROLE_IT_TECH_PAU TO IT_TECH_PAU;

-- NETWORK IT PAU
GRANT ROLE_NETWORK_TECH_PAU TO NETWORK_TECH_PAU;

-- ACADEMIC ADMIN PAU
GRANT ROLE_ACADEMIC_ADMIN_PAU TO ACADEMIC_ADMIN_PAU;

-- STUDENT/TEACHER PAU
GRANT ROLE_STUDENT_TEACHER_PAU TO STUDENT_TEACHER_PAU;