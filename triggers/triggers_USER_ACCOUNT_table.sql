CREATE OR REPLACE TRIGGER trg_user_account_update_timestamp
BEFORE UPDATE ON USER_ACCOUNT
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/


CREATE OR REPLACE TRIGGER trg_normalize_user_email
BEFORE INSERT OR UPDATE OF email ON USER_ACCOUNT
FOR EACH ROW
BEGIN
    IF :NEW.email IS NOT NULL THEN
        :NEW.email := LOWER(:NEW.email);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_validate_user_email
BEFORE INSERT OR UPDATE OF email ON USER_ACCOUNT
FOR EACH ROW
BEGIN
    IF :NEW.email IS NOT NULL AND 
        NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Format d''email invalide');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_validate_phone_number
BEFORE INSERT OR UPDATE OF phone ON USER_ACCOUNT
FOR EACH ROW
BEGIN
    IF :NEW.phone IS NOT NULL AND 
        NOT REGEXP_LIKE(:NEW.phone, '^\+?[0-9]{10,15}$') THEN
        RAISE_APPLICATION_ERROR(-20007, 'Format de numéro de téléphone invalide');
    END IF;
END;
/



-- -- Jeu de tests (autre alternative 'INSERT INTO VALUES()')
SET SERVEROUTPUT ON;

DECLARE
    v_site_id NUMBER;
    v_role_id NUMBER;
    
    -- Variables pour vérifier les résultats
    v_email VARCHAR2(255);
    v_success BOOLEAN;
    v_result VARCHAR2(255);
    v_count NUMBER;
    v_user_id NUMBER;
BEGIN

    SELECT site_id INTO v_site_id FROM SITE WHERE name = 'Cergy';
    SELECT role_id INTO v_role_id FROM USER_ROLE WHERE role_name = 'Student';
    
    DBMS_OUTPUT.PUT_LINE('=== Test du trigger trg_normalize_user_email ===');
    
    -- Test 1 : Email avec majuscules qui devrait être converti en minuscules
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, email, site_id, role_id)
        VALUES ('testuser1', 'password123', 'TEST.User@Example.COM', v_site_id, v_role_id)
        RETURNING user_id INTO v_user_id;
        
        SELECT email INTO v_email FROM USER_ACCOUNT WHERE user_id = v_user_id;
        DBMS_OUTPUT.PUT_LINE('Test 1 - Email normalisé: ' || 
            CASE WHEN v_email = 'test.user@example.com' THEN 'SUCCESS' ELSE 'FAILED - Obtenu: ' || v_email END);
            
        -- DELETE FROM USER_ACCOUNT WHERE user_id = v_user_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Test 1 - ERREUR: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== Test du trigger trg_validate_user_email ===');
    
    -- Test 2 : Email valide
    v_success := TRUE;
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, email, site_id, role_id)
        VALUES ('testuser2', 'password123', 'valid.email@example.com', v_site_id, v_role_id)
        RETURNING user_id INTO v_user_id;
        
        DBMS_OUTPUT.PUT_LINE('Test 2 - Email valide: SUCCESS');
        
        DELETE FROM USER_ACCOUNT WHERE user_id = v_user_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Test 2 - Email valide' || SQLERRM);
    END;
    
    -- Test 3: Email invalide
    v_success := TRUE;
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, email, site_id, role_id)
        VALUES ('testuser3', 'password123', 'invalid-email', v_site_id, v_role_id);
        
        DBMS_OUTPUT.PUT_LINE('Test 3 - Email invalide: FAILED - Aucune erreur levée');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20006 THEN
                DBMS_OUTPUT.PUT_LINE('Test 3 - Email invalide: SUCCESS - ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Test 3 - Email invalide: FAILED - ' || SQLERRM);
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== Test du trigger trg_validate_phone_number ===');
    
    -- Test 4: Téléphone valide
    v_success := TRUE;
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, phone, site_id, role_id)
        VALUES ('testuser4', 'password123', '0123456789', v_site_id, v_role_id)
        RETURNING user_id INTO v_user_id;
        
        DBMS_OUTPUT.PUT_LINE('Test 4 - Téléphone valide: SUCCESS ');
        
        -- Nettoyage
        DELETE FROM USER_ACCOUNT WHERE user_id = v_user_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Test 4 - Téléphone valide: FAILED - ' || SQLERRM);
    END;
    
    -- Test 5: Téléphone avec préfixe
    v_success := TRUE;
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, phone, site_id, role_id)
        VALUES ('testuser5', 'password123', '+33123456789', v_site_id, v_role_id)
        RETURNING user_id INTO v_user_id;
        
        DBMS_OUTPUT.PUT_LINE('Test 5 - Téléphone avec préfixe: SUCCESS');
        
        DELETE FROM USER_ACCOUNT WHERE user_id = v_user_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Test 5 - Téléphone avec préfixe: FAILED - ' || SQLERRM);
    END;
    
    -- Test 6: Téléphone invalide
    v_success := TRUE;
    BEGIN
        INSERT INTO USER_ACCOUNT (username, password, phone, site_id, role_id)
        VALUES ('testuser6', 'password123', '123-456-789', v_site_id, v_role_id);
        
        DBMS_OUTPUT.PUT_LINE('Test 6 - Téléphone invalide: FAILED - Aucune erreur levée');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20007 THEN
                DBMS_OUTPUT.PUT_LINE('Test 6 - Téléphone invalide: SUCCESS - ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Test 6 - Téléphone invalide: FAILED - ' || SQLERRM);
            END IF;
    END;
    
END;
/