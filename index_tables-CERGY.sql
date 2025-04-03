------------------------------------------------------------------------------
-- QUERY TO RETRIEVE INDEXES OF A GIVEN TABLE
------------------------------------------------------------------------------
-- SELECT index_name, table_name 
-- FROM dba_indexes 
-- WHERE table_name = 'ASSET_TYPE';
------------------------------------------------------------------------------
-- QUERY TO RETRIEVE INDEXES WITH ASSOCIATED TABLESPACE
------------------------------------------------------------------------------
-- SELECT index_name, tablespace_name 
-- FROM user_indexes;



------------------------------------------------------------------------------
-- DROP INDEX IF EXIST
------------------------------------------------------------------------------
DROP INDEX idx_asset_purchase_date_cergy;
DROP INDEX idx_asset_assigned_user_id_cergy;
DROP INDEX idx_asset_name_cergy;
DROP INDEX idx_ipasset_asset_cergy;
DROP INDEX idx_ticket_user_cergy;
DROP INDEX idx_ticket_assigned_to_status_cergy;



------------------------------------------------------------------------------
-- INDEX TABLESPACE 'cergy_indexes'
------------------------------------------------------------------------------
-- ################################################
-- ## DROP TABLESPACE cergy_indexes
-- ################################################
DROP TABLESPACE cergy_indexes INCLUDING CONTENTS AND DATAFILES;

-- ################################################
-- ## CREATE TABLESPACE cergy_indexes
-- ################################################
CREATE TABLESPACE cergy_indexes
    DATAFILE 'cergy_indexes.dbf' SIZE 100M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;



------------------------------------------------------------------------------
-- ALTER EXISTANT INDEXES TO TABLESPACE cergy_indexes (CONSTRAINT CREATED IN tables creation)
------------------------------------------------------------------------------
ALTER INDEX PK_SITE REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_ROLE REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_USER_ACCOUNT REBUILD TABLESPACE cergy_indexes;
ALTER INDEX UQ_USERNAME REBUILD TABLESPACE cergy_indexes;
ALTER INDEX UQ_EMAIL REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_ASSET_TYPE REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_ASSET REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_NETWORK REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_IP_ADDRESS REBUILD TABLESPACE cergy_indexes;
ALTER INDEX UQ_NETWORK_IP REBUILD TABLESPACE cergy_indexes;
ALTER INDEX PK_TICKET REBUILD TABLESPACE cergy_indexes;
ALTER INDEX UQ_ASSET_SERIAL REBUILD TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- USEFUL INDEXES
------------------------------------------------------------------------------

-- ASSET
CREATE INDEX idx_asset_purchase_date_cergy
    ON ASSET(purchase_date)
    TABLESPACE cergy_indexes;
CREATE INDEX idx_asset_assigned_user_id_cergy
    ON ASSET(assigned_user_id)
    TABLESPACE cergy_indexes;
CREATE INDEX idx_asset_name_cergy
    ON ASSET(name)
    TABLESPACE cergy_indexes;
-- IP_ADDRESS
CREATE INDEX idx_ipasset_asset_cergy
    ON IP_ADDRESS(asset_id)
    TABLESPACE cergy_indexes;
-- TICKET
CREATE INDEX idx_ticket_user_cergy 
    ON TICKET(user_id)
    TABLESPACE cergy_indexes;
CREATE INDEX idx_ticket_assigned_to_status_cergy
    ON TICKET(assigned_to, status)
    TABLESPACE cergy_indexes;






------------------------------------------------------------------------------
-- EXPLAIN PLAN FOR command TO CHECK IF INDEX USEFUL OR USELESS 
------------------------------------------------------------------------------
-- EXPLAIN PLAN FOR
-- SELECT *
-- FROM table
-- WHERE  = '';

-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


------------------------------------------------------------------------------
-- INDEXES RELATED TO USER_ACCOUNT 
-- UQ_EMAIL and UQ_USERNAME already indexed with CONSTRAINT (unique).
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON ROLE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_useraccount_role;

-- CREATE INDEX idx_useraccount_role 
--     ON USER_ACCOUNT(role_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON SITE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_useraccount_site_id;

-- CREATE INDEX idx_useraccount_site_id
--     ON USER_ACCOUNT(site_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON SITE_ID and ROLE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_useraccount_site_id_role_id;

-- CREATE INDEX idx_useraccount_site_id_role_id 
--     ON USER_ACCOUNT(site_id, role_id)
--     TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO ASSETS
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON PURCHASE_DATE (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_purchase_date
--     ON ASSET(purchase_date)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON ASSET_TYPE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_asset_type;

-- CREATE INDEX idx_asset_type 
--     ON ASSET(asset_type_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON ASSIGNED_USER_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_assigned_user_id 
--     ON ASSET(assigned_user_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX composite ON SITE_ID and STATUS (USELESS)
-- ################################################
-- DROP INDEX idx_asset_site_id_status;

-- CREATE INDEX idx_asset_site_id_status 
--     ON ASSET(site_id, status)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON NAME (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_name 
--     ON ASSET(name)
--     TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO IP_ADDRESS
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON ASSET_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_ipasset_asset
--     ON IP_ADDRESS(asset_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON NETWORK_ID (USELESS)
-- ################################################
-- DROP INDEX idx_ipasset_network_id;

-- CREATE INDEX idx_ipasset_network_id
--     ON IP_ADDRESS(network_id)
--     TABLESPACE cergy_indexes;



-----------------------------------------------------------------------------
-- INDEXES RELATED TO TICKET
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON USER_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_ticket_user 
--     ON TICKET(user_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON ASSIGNED_TO and STATUS (USEFUL)
-- ################################################
-- CREATE INDEX idx_ticket_assigned_to_status
--     ON TICKET(assigned_to, status)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON PRIORITY (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_priority;

-- CREATE INDEX idx_ticket_priority
--     ON TICKET(priority)
--     TABLESPACE cergy_indexes;

-- ################################################
-- ## INDEX ON STATUS and PRIORITY (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_status_priority;

-- CREATE INDEX idx_ticket_status_priority
--     ON TICKET(status, priority)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON CREATION_DATE and USER_ID (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_creation_date_user_id;

-- CREATE INDEX idx_ticket_creation_date_user_id
--     ON TICKET(creation_date, user_id)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON CREATION_DATE and STATUS (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_creation_date_status;

-- CREATE INDEX idx_ticket_creation_date_status
--     ON TICKET(creation_date, status)
--     TABLESPACE cergy_indexes;


-- ################################################
-- ## INDEX ON CREATION_DATE (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_creation_date;

-- CREATE INDEX idx_ticket_creation_date
--     ON TICKET(creation_date, status)
--     TABLESPACE cergy_indexes;
