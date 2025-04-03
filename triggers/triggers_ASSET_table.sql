-- ###################################################################################
-- DROP EXISTING TRIGGER (if exists) for ASSET ticket
-- ###################################################################################
DROP TRIGGER trg_asset_status_check;
DROP TRIGGER trg_asset_site_consistency;
DROP TRIGGER trg_asset_purchase_date_check;
DROP TABLE ASSET_AUDIT CASCADE CONSTRAINTS;
DROP TRIGGER trg_asset_audit;
/


-- ###################################################################################
-- Trigger 1: Asset Status Check
-- This trigger updates the "updated_at" timestamp on every insert or update.
-- Additionally, if the asset's status is set to 'decommissioned', it ensures that
-- no user is assigned to this asset (i.e., assigned_user_id must be NULL).
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_asset_status_check
BEFORE INSERT OR UPDATE ON ASSET
FOR EACH ROW
BEGIN
    -- Always update the updated_at column with the current timestamp
    :NEW.updated_at := SYSTIMESTAMP;
    
    -- If the asset status is 'decommissioned',
    -- then ensure that the asset is not assigned to any user.
    IF :NEW.status = 'decommissioned' AND :NEW.assigned_user_id IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Asset cannot be assigned if its status is decommissioned.');
    END IF;
END;
/

-- ###################################################################################
-- Verify current data in ASSET table
-- ###################################################################################
-- SELECT * FROM ASSET;

-- SELECT *
    -- FROM ASSET
    -- WHERE asset_id = 1;

-- ###################################################################################
-- Test Update: Setting asset status to 'decommissioned' 
-- and ensuring that assigned_user_id is set to NULL
-- ###################################################################################
-- UPDATE ASSET
--     SET status = 'decommissioned',
--         assigned_user_id = NULL
--     WHERE asset_id = 1;
-- COMMIT;

-- Uncomment the following block to test the error case:
-- This update should raise an error because the asset is decommissioned
-- but an assigned user is provided.
--
-- UPDATE ASSET
--    SET status = 'decommissioned',
--        assigned_user_id = 10  -- Example: asset is assigned to a user
--  WHERE asset_id = 1;
--
-- Expected error:
-- ORA-20030: Asset cannot be assigned if its status is decommissioned.




-- ###################################################################################
-- Trigger 2 :
-- 
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_asset_site_consistency
BEFORE INSERT OR UPDATE ON ASSET
FOR EACH ROW
DECLARE
    v_assigned_site_id USER_ACCOUNT.site_id%TYPE;
BEGIN
    -- If an assigned user is specified, verify that his site matches the asset's site
    IF :NEW.assigned_user_id IS NOT NULL THEN
        SELECT site_id
        INTO v_assigned_site_id
        FROM USER_ACCOUNT
        WHERE user_id = :NEW.assigned_user_id;
        
        IF v_assigned_site_id <> :NEW.site_id THEN
        RAISE_APPLICATION_ERROR(-20032, 'The assigned user must belong to the same site as the asset.');
        END IF;
    END IF;
END;
/


-- ###################################################################################
-- Test update and insert
-- ###################################################################################
-- INSERT INTO ASSET (asset_type_id, name, serial, assigned_user_id, site_id, purchase_date, status)
-- VALUES (1, 'Ordinateur Portable', 'SN12345', 10, 2, DATE '2023-06-15', 'active');
-- COMMIT;

-- UPDATE ASSET
--     SET assigned_user_id = 2 -- Suppose user_id 20 belongs to site_id = 2
--     WHERE asset_id = 5002; -- Suppose user_id 20 belongs to site_id = 1
-- COMMIT;
-- Expected error: ORA-20032: The assigned user must belong to the same site as the asset.




-- ###################################################################################
-- Trigger 3 :
-- 
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_asset_purchase_date_check
BEFORE INSERT OR UPDATE ON ASSET
FOR EACH ROW
BEGIN
    -- If a purchase_date is provided, ensure that it is not in the future.
    IF :NEW.purchase_date IS NOT NULL AND :NEW.purchase_date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20031, 'Purchase date cannot be in the future.');
    END IF;
END;
/


-- ###################################################################################
-- Test update and insert
-- ###################################################################################
-- INSERT INTO ASSET (asset_type_id, name, serial, assigned_user_id, site_id, purchase_date, status)
-- VALUES (
--     1, 
--     'Test Asset Valid', 
--     'SN0001', 
--     NULL, 
--     1, 
--     SYSDATE - 1, -- Yesterday
--     'active'
-- );
-- COMMIT;

-- INSERT INTO ASSET (asset_type_id, name, serial, assigned_user_id, site_id, purchase_date, status)
-- VALUES (
--     1, 
--     'Test Asset Future', 
--     'SN0002', 
--     NULL, 
--     1, 
--     SYSDATE + 1,  -- Tomorrow
--     'active'
-- );
-- COMMIT;
-- ORA-20031: Purchase date cannot be in the future.




-- ###################################################################################
-- Trigger 4 : AUDIT TABLE FOR ASSETS
-- 
-- ###################################################################################
CREATE TABLE ASSET_AUDIT (
    audit_id               NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    asset_id               NUMBER,
    change_date            TIMESTAMP DEFAULT SYSTIMESTAMP,
    old_status             VARCHAR2(20),
    new_status             VARCHAR2(20),
    old_assigned_user_id   NUMBER,
    new_assigned_user_id   NUMBER
);

CREATE OR REPLACE TRIGGER trg_asset_audit
AFTER UPDATE ON ASSET
FOR EACH ROW
BEGIN
    IF ( ( :OLD.status IS NULL AND :NEW.status IS NOT NULL )
        OR ( :OLD.status IS NOT NULL AND :NEW.status IS NULL )
        OR (:OLD.status <> :NEW.status)
        OR ( :OLD.assigned_user_id IS NULL AND :NEW.assigned_user_id IS NOT NULL )
        OR ( :OLD.assigned_user_id IS NOT NULL AND :NEW.assigned_user_id IS NULL )
        OR (:OLD.assigned_user_id <> :NEW.assigned_user_id)
        )
    THEN
        INSERT INTO ASSET_AUDIT (
        asset_id,
        change_date,
        old_status,
        new_status,
        old_assigned_user_id,
        new_assigned_user_id
        )
        VALUES (
        :OLD.asset_id,
        SYSTIMESTAMP,
        :OLD.status,
        :NEW.status,
        :OLD.assigned_user_id,
        :NEW.assigned_user_id
        );
    END IF;
END;
/

-- Mise à jour du statut d'un actif
-- UPDATE ASSET
--     SET status = 'maintenance'
--     WHERE asset_id = 1;
-- COMMIT;

-- Vérifiez que l'audit a été enregistré
-- SELECT * FROM ASSET_AUDIT
-- WHERE asset_id = 1;


-- ###################################################################################
-- Trigger 4 : AUDIT TABLE FOR ASSETS
-- Empêche la modification du numéro de série après création
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_asset_protect_serial
BEFORE UPDATE OF serial ON ASSET
FOR EACH ROW
BEGIN
    IF :OLD.serial IS NOT NULL AND :NEW.serial <> :OLD.serial THEN
        RAISE_APPLICATION_ERROR(-20004, 'Le numéro de série ne peut pas être modifié');
    END IF;
END;
/