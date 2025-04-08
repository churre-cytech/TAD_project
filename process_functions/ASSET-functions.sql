-- -- Procedure to assign an asset to a user
-- CREATE OR REPLACE PROCEDURE assign_asset_to_user(
--     p_asset_id NUMBER,
--     p_user_id NUMBER
-- ) IS
--     v_asset_site_id NUMBER;
--     v_user_site_id NUMBER;
--     v_status VARCHAR2(50);
-- BEGIN

--     BEGIN
--         SELECT site_id, status INTO v_asset_site_id, v_status 
--         FROM ASSET 
--         WHERE asset_id = p_asset_id;
        
--         IF v_status != 'active' THEN
--             RAISE_APPLICATION_ERROR(-20001, 'Asset is not active and cannot be assigned');
--         END IF;
--     EXCEPTION
--         WHEN NO_DATA_FOUND THEN
--             RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
--     END;
    

--     BEGIN
--         SELECT site_id INTO v_user_site_id 
--         FROM USER_ACCOUNT 
--         WHERE user_id = p_user_id;
--     EXCEPTION
--         WHEN NO_DATA_FOUND THEN
--             RAISE_APPLICATION_ERROR(-20003, 'User not found');
--     END;
    
--     -- Verify site consistency
--     IF v_asset_site_id != v_user_site_id THEN
--         RAISE_APPLICATION_ERROR(-20004, 'Site mismatch: Asset and user must belong to the same site');
--     END IF;
    
--     -- Assign the asset
--     UPDATE ASSET
--     SET assigned_user_id = p_user_id,
--         updated_at = SYSTIMESTAMP
--     WHERE asset_id = p_asset_id;
    
--     COMMIT;
-- EXCEPTION
--     WHEN OTHERS THEN
--         ROLLBACK;
--         RAISE;
-- END assign_asset_to_user;
-- /

-- -- Function to get all assets assigned to a specific user
-- CREATE OR REPLACE FUNCTION get_user_assets(
--     p_user_id NUMBER
-- ) RETURN SYS_REFCURSOR IS
--     v_result SYS_REFCURSOR;
-- BEGIN
--     OPEN v_result FOR
--     SELECT a.asset_id, a.name, at.label AS asset_type, a.serial, a.status 
--     FROM ASSET a
--     JOIN ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
--     WHERE a.assigned_user_id = p_user_id;
    
--     RETURN v_result;
-- END get_user_assets;
-- /

-- -- Procedure to release an asset from a user
-- CREATE OR REPLACE PROCEDURE release_asset(
--     p_asset_id NUMBER
-- ) IS
-- BEGIN
--     -- Check if asset exists
--     DECLARE
--         v_asset_exists NUMBER;
--     BEGIN
--         SELECT COUNT(*) INTO v_asset_exists 
--         FROM ASSET 
--         WHERE asset_id = p_asset_id;
        
--         IF v_asset_exists = 0 THEN
--             RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
--         END IF;
--     END;
    
--     -- Release the asset
--     UPDATE ASSET
--     SET assigned_user_id = NULL,
--         updated_at = SYSTIMESTAMP
--     WHERE asset_id = p_asset_id;
    
--     COMMIT;
-- EXCEPTION
--     WHEN OTHERS THEN
--         ROLLBACK;
--         RAISE;
-- END release_asset;
-- /
