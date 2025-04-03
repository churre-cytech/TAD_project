------------------------------------------------------------------------------
-- Création d'un database link pour que le site de Cergy puisse communiquer avec le site de Pau
------------------------------------------------------------------------------
DROP DATABASE LINK pau_link;

CREATE DATABASE LINK pau_link
CONNECT TO CY_TECH_PAU IDENTIFIED BY pau123
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XEPDB1)))';