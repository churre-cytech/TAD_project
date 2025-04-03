-- ####################################################################################################
-- (launch in sys-connnection)
-- ####################################################################################################


DROP USER CY_TECH_ADMIN CASCADE;
/
-- ##########################################################################################
-- ## CY_TECH_ADMIN CREATION
-- ##########################################################################################
CREATE USER CY_TECH_ADMIN IDENTIFIED BY admin123;
GRANT DBA, RESOURCE, CONNECT TO CY_TECH_ADMIN;
GRANT CREATE SESSION TO CY_TECH_ADMIN;

-- (launch in CY_TECH_CERGY-connnection)
GRANT ROLE_ADMIN_CERGY TO CY_TECH_ADMIN;
-- (launch in CY_TECH_PAU-connnection)
GRANT ROLE_ADMIN_PAU TO CY_TECH_ADMIN;


