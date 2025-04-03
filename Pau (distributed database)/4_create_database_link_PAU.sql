------------------------------------------------------------------------------
-- DROP DATABASE LINK
------------------------------------------------------------------------------
DROP DATABASE LINK cergy_link;

---------------------------------------------
-- Création d'un database link pour que le site de Pau puisse communiquer avec le site de Cergy
------------------------------------------------------------------------------

CREATE DATABASE LINK cergy_link
CONNECT TO CY_TECH_CERGY IDENTIFIED BY cergy123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=FREEPDB1)))';

SELECT * FROM user_account@cergy_link;