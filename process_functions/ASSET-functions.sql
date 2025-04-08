-- Procedure to assign an asset to a user
CREATE OR REPLACE PROCEDURE assign_asset(
    p_asset_id NUMBER,
    p_user_id NUMBER
) IS
    v_asset_status VARCHAR2(20);
    v_asset_exists NUMBER;
    v_user_exists NUMBER;
BEGIN
    -- Check if asset exists
    SELECT COUNT(*) INTO v_asset_exists 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    IF v_asset_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
    END IF;
    
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_exists 
    FROM USER_ACCOUNT 
    WHERE user_id = p_user_id;
    
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'User not found');
    END IF;
    
    -- Get current asset status
    SELECT status INTO v_asset_status 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    -- Check if asset is available for assignment
    IF v_asset_status != 'active' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Asset is not available for assignment');
    END IF;
    
    -- Update asset and assign to user (keeping status as 'active')
    UPDATE ASSET
    SET assigned_user_id = p_user_id,
        updated_at = SYSTIMESTAMP
    WHERE asset_id = p_asset_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END assign_asset;
/

-- ######################################
-- Test assign_asset()
-- ######################################
-- Cas normal
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_employee_id NUMBER;
        v_asset_id NUMBER;
    BEGIN
        -- Sélection d'un employé de Cergy
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        -- Sélection d'un actif actif de Cergy
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        -- Attribution de l'actif
        assign_asset(v_asset_id, v_employee_id);
        DBMS_OUTPUT.PUT_LINE('Actif attribué avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec actif inexistant
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_employee_id NUMBER;
    BEGIN
        -- Sélection d'un employé de Cergy
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        -- Tentative d'attribution d'un actif inexistant
        assign_asset(999, v_employee_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/

-- Procedure to release an asset from a user
CREATE OR REPLACE PROCEDURE release_asset(
    p_asset_id NUMBER
) IS
    v_asset_exists NUMBER;
    v_assigned_user_id NUMBER;
BEGIN
    -- Check if asset exists
    SELECT COUNT(*) INTO v_asset_exists 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    IF v_asset_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
    END IF;
    
    -- Get current assigned user
    SELECT assigned_user_id INTO v_assigned_user_id 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    -- Check if asset is assigned
    IF v_assigned_user_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Asset is not assigned to any user');
    END IF;
    
    -- Release asset
    UPDATE ASSET
    SET assigned_user_id = NULL,
        updated_at = SYSTIMESTAMP
    WHERE asset_id = p_asset_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END release_asset;
/

-- ######################################
-- Test release_asset()
-- ######################################
-- Cas normal
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_asset_id NUMBER;
    BEGIN
        -- Sélection d'un actif assigné de Cergy
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.assigned_user_id IS NOT NULL
        AND ROWNUM = 1;
        
        -- Libération de l'actif
        release_asset(v_asset_id);
        DBMS_OUTPUT.PUT_LINE('Actif libéré avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec actif inexistant
BEGIN
    -- Tentative de libération d'un actif inexistant
    release_asset(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Procedure to change asset status
CREATE OR REPLACE PROCEDURE change_asset_status(
    p_asset_id NUMBER,
    p_new_status VARCHAR2
) IS
    v_asset_exists NUMBER;
    v_valid_status NUMBER;
BEGIN
    -- Check if asset exists
    SELECT COUNT(*) INTO v_asset_exists 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    IF v_asset_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
    END IF;
    
    -- Check if new status is valid
    SELECT COUNT(*) INTO v_valid_status 
    FROM (
        SELECT 'active' as status FROM DUAL
        UNION ALL SELECT 'maintenance' FROM DUAL
        UNION ALL SELECT 'decommissioned' FROM DUAL
    ) 
    WHERE status = p_new_status;
    
    IF v_valid_status = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid asset status');
    END IF;
    
    -- Update asset status
    UPDATE ASSET
    SET status = p_new_status,
        updated_at = SYSTIMESTAMP
    WHERE asset_id = p_asset_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END change_asset_status;
/

-- ######################################
-- Test change_asset_status()
-- ######################################
-- Cas normal
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_asset_id NUMBER;
    BEGIN
        -- Sélection d'un actif actif de Cergy
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        -- Changement du statut en maintenance
        change_asset_status(v_asset_id, 'maintenance');
        DBMS_OUTPUT.PUT_LINE('Statut de l''actif modifié avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec statut invalide
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_asset_id NUMBER;
    BEGIN
        -- Sélection d'un actif actif de Cergy
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        -- Tentative de changement vers un statut invalide
        change_asset_status(v_asset_id, 'invalid_status');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/
