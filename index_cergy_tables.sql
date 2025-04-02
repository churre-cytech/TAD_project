------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- QUERY TO RETRIEVE INDEXES OF A GIVEN TABLE
SELECT index_name, table_name 
FROM dba_indexes 
WHERE table_name = 'ASSET_TYPE';

-- QUERY TO RETRIEVE INDEXES WITH ASSOCIATED TABLESPACE
SELECT index_name, tablespace_name 
FROM user_indexes;



DROP TABLESPACE cergy_indexes INCLUDING CONTENTS AND DATAFILES;
------------------------------------------------------------------------------
-- CREATE INDEX TABLESPACE cergy_indexes
------------------------------------------------------------------------------
CREATE TABLESPACE cergy_indexes
DATAFILE 'cergy_indexes.dbf' SIZE 100M
EXTENT MANAGEMENT LOCAL AUTOALLOCATE;



------------------------------------------------------------------------------
-- ALTER EXISTANT INDEXES TO TABLESPACE cergy_indexes
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


------------------------------------------------------------------------------
-- INDEXES RELATED TO USER_ACCOUNT
------------------------------------------------------------------------------
CREATE INDEX idx_useraccount_role 
    ON USER_ACCOUNT(role_id)
    TABLESPACE cergy_indexes;

-- Principe de "leftmost prefix" 
-- <=> utilisation de 'idx_useraccount_site_username'
-- CREATE INDEX idx_useraccount_site 
--     ON USER_ACCOUNT(site_id)
--     TABLESPACE cergy_indexes;
CREATE INDEX idx_useraccount_site_username
    ON USER_ACCOUNT(site_id, username)
    TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO ASSETS
------------------------------------------------------------------------------
CREATE INDEX idx_asset_type ON ASSET(asset_type_id);

CREATE INDEX idx_asset_assigned_user
    ON ASSET(assigned_user_id)
    TABLESPACE cergy_indexes;
    
CREATE INDEX idx_asset_purchase_date
    ON ASSET(purchase_date)
    TABLESPACE cergy_indexes;

-- Principe de "leftmost prefix" 
-- CREATE INDEX idx_asset_site ON ASSET(site_id);

CREATE INDEX idx_asset_site_status
    ON ASSET(site_id, status, serial)
    TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO IP_ADDRESS
------------------------------------------------------------------------------
CREATE INDEX idx_ipasset_asset
    ON IP_ADDRESS(asset_id)
    TABLESPACE cergy_indexes;

CREATE INDEX idx_ipasset_network
    ON IP_ADDRESS(network_id)
    TABLESPACE cergy_indexes;


------------------------------------------------------------------------------
-- INDEXES RELATED TO NETWORK
------------------------------------------------------------------------------
CREATE INDEX idx_network_address
    ON NETWORK(network_address)
    TABLESPACE cergy_indexes;

CREATE INDEX idx_network_site
    ON NETWORK(site_id)
    TABLESPACE cergy_indexes;



------------------------------------------------------------------------------
-- INDEXES RELATED TO TICKETS
------------------------------------------------------------------------------
CREATE INDEX idx_ticket_user 
    ON TICKET(user_id)
    TABLESPACE cergy_indexes;
    
CREATE INDEX idx_ticket_site 
    ON TICKET(site_id)
    TABLESPACE cergy_indexes;

CREATE INDEX idx_ticket_status 
    ON TICKET(status)
    TABLESPACE cergy_indexes;

CREATE INDEX idx_ticket_assigned_status
    ON TICKET(assigned_to, status)
    TABLESPACE cergy_indexes;
    
CREATE INDEX idx_ticket_priority
    ON TICKET(priority)
    TABLESPACE cergy_indexes;


