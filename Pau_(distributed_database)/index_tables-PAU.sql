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
DROP INDEX idx_asset_purchase_date_pau;
DROP INDEX idx_asset_assigned_user_id_pau;
DROP INDEX idx_asset_name_pau;
DROP INDEX idx_ipasset_asset_pau;
DROP INDEX idx_ticket_user_pau;
DROP INDEX idx_ticket_assigned_to_status_pau;



------------------------------------------------------------------------------
-- INDEX TABLESPACE 'pau_indexes'
------------------------------------------------------------------------------
-- ################################################
-- ## DROP TABLESPACE pau_indexes
-- ################################################
DROP TABLESPACE pau_indexes INCLUDING CONTENTS AND DATAFILES;

-- ################################################
-- ## CREATE TABLESPACE pau_indexes
-- ################################################
CREATE TABLESPACE pau_indexes
    DATAFILE 'pau_indexes.dbf' SIZE 100M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;



------------------------------------------------------------------------------
-- ALTER EXISTANT INDEXES TO TABLESPACE pau_indexes (CONSTRAINT CREATED IN tables creation)
------------------------------------------------------------------------------
ALTER INDEX PK_SITE REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_ROLE REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_USER_ACCOUNT REBUILD TABLESPACE pau_indexes;
ALTER INDEX UQ_USERNAME REBUILD TABLESPACE pau_indexes;
ALTER INDEX UQ_EMAIL REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_ASSET_TYPE REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_ASSET REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_NETWORK REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_IP_ADDRESS REBUILD TABLESPACE pau_indexes;
ALTER INDEX UQ_NETWORK_IP REBUILD TABLESPACE pau_indexes;
ALTER INDEX PK_TICKET REBUILD TABLESPACE pau_indexes;
ALTER INDEX UQ_ASSET_SERIAL REBUILD TABLESPACE pau_indexes;



------------------------------------------------------------------------------
-- USEFUL INDEXES
------------------------------------------------------------------------------
CREATE INDEX idx_asset_purchase_date_pau
    ON ASSET(purchase_date)
    TABLESPACE pau_indexes;
CREATE INDEX idx_asset_assigned_user_id_pau
    ON ASSET(assigned_user_id)
    TABLESPACE pau_indexes;
CREATE INDEX idx_asset_name_pau
    ON ASSET(name)
    TABLESPACE pau_indexes;
CREATE INDEX idx_ipasset_asset_pau
    ON IP_ADDRESS(asset_id)
    TABLESPACE pau_indexes;
CREATE INDEX idx_ticket_user_pau
    ON TICKET(user_id)
    TABLESPACE pau_indexes;
CREATE INDEX idx_ticket_assigned_to_status_pau
    ON TICKET(assigned_to, status)
    TABLESPACE pau_indexes;











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
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON SITE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_useraccount_site_id;

-- CREATE INDEX idx_useraccount_site_id
--     ON USER_ACCOUNT(site_id)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON SITE_ID and ROLE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_useraccount_site_id_role_id;

-- CREATE INDEX idx_useraccount_site_id_role_id
--     ON USER_ACCOUNT(site_id, role_id)
--     TABLESPACE pau_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO ASSETS
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON PURCHASE_DATE (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_purchase_date
--     ON ASSET(purchase_date)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON ASSET_TYPE_ID (USELESS)
-- ################################################
-- DROP INDEX idx_asset_type;

-- CREATE INDEX idx_asset_type
--     ON ASSET(asset_type_id)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON ASSIGNED_USER_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_assigned_user_id
--     ON ASSET(assigned_user_id)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX composite ON SITE_ID and STATUS (USELESS)
-- ################################################
-- DROP INDEX idx_asset_site_id_status;

-- CREATE INDEX idx_asset_site_id_status
--     ON ASSET(site_id, status)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON NAME (USEFUL)
-- ################################################
-- CREATE INDEX idx_asset_name
--     ON ASSET(name)
--     TABLESPACE pau_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO IP_ADDRESS
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON ASSET_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_ipasset_asset
--     ON IP_ADDRESS(asset_id)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON NETWORK_ID (USELESS)
-- ################################################
-- DROP INDEX idx_ipasset_network_id;

-- CREATE INDEX idx_ipasset_network_id
--     ON IP_ADDRESS(network_id)
--     TABLESPACE pau_indexes;



-----------------------------------------------------------------------------
-- INDEXES RELATED TO TICKET
------------------------------------------------------------------------------
-- ################################################
-- ## INDEX ON USER_ID (USEFUL)
-- ################################################
-- CREATE INDEX idx_ticket_user
--     ON TICKET(user_id)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON ASSIGNED_TO and STATUS (USEFUL)
-- ################################################
-- CREATE INDEX idx_ticket_assigned_to_status
--     ON TICKET(assigned_to, status)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON PRIORITY (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_priority;

-- CREATE INDEX idx_ticket_priority
--     ON TICKET(priority)
--     TABLESPACE pau_indexes;

-- ################################################
-- ## INDEX ON STATUS and PRIORITY (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_status_priority;

-- CREATE INDEX idx_ticket_status_priority
--     ON TICKET(status, priority)
--     TABLESPACE pau_indexes;


-- ################################################
-- ## INDEX ON CREATION_DATE and USER_ID (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_creation_date_user_id;

-- CREATE INDEX idx_ticket_creation_date_user_id
--     ON TICKET(creation_date, user_id)
--     TABLESPACE pau_indexes;

-- ################################################
-- ## INDEX ON CREATION_DATE and STATUS (USELESS)
-- ################################################
-- DROP INDEX idx_ticket_creation_date_status;

-- CREATE INDEX idx_ticket_creation_date_status
--     ON TICKET(creation_date, status)
--     TABLESPACE pau_indexes; 