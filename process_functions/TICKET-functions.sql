-- Procedure to create a ticket
CREATE OR REPLACE PROCEDURE create_ticket(
    p_user_id NUMBER,
    p_asset_id NUMBER,
    p_description CLOB
) IS
    v_user_site_id NUMBER;
    v_user_exists NUMBER;
    v_asset_exists NUMBER;
    v_subject VARCHAR2(100);
BEGIN
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_exists 
    FROM USER_ACCOUNT 
    WHERE user_id = p_user_id;
    
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'User not found');
    END IF;
    
    -- Get site_id from user
    SELECT site_id INTO v_user_site_id 
    FROM USER_ACCOUNT 
    WHERE user_id = p_user_id;
    
    -- Check if asset exists if provided
    IF p_asset_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_asset_exists 
        FROM ASSET 
        WHERE asset_id = p_asset_id;
        
        IF v_asset_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Asset not found');
        END IF;
        
        -- Create subject based on asset
        SELECT 'Issue with ' || name INTO v_subject
        FROM ASSET
        WHERE asset_id = p_asset_id;
    ELSE
        -- Default subject if no asset is specified
        v_subject := 'General support request';
    END IF;
    
    -- Create the ticket
    INSERT INTO TICKET (
        user_id,
        site_id,
        subject,
        description,
        status,
        priority,
        creation_date,
        updated_date
    ) VALUES (
        p_user_id,
        v_user_site_id,
        v_subject,
        p_description,
        'open',
        'medium',
        SYSDATE,
        SYSDATE
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END create_ticket;
/

-- ######################################
-- Test create_ticket()
-- ######################################
-- Cas normal avec asset
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_employee_id NUMBER;
        v_asset_id NUMBER;
        v_site_id NUMBER;
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
        
        -- Création d'un ticket
        create_ticket(v_employee_id, v_asset_id, 'L''ordinateur affiche un écran bleu fréquemment');
        DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Cas normal sans asset (NULL pour asset_id)
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_student_id NUMBER;
    BEGIN
        -- Sélection d'un étudiant de Cergy
        SELECT ua.user_id INTO v_student_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Student' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        -- Création d'un ticket sans actif
        create_ticket(v_student_id, NULL, 'Demande d''accès au réseau Wi-Fi');
        DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec utilisateur inexistant
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
        
        -- Tentative de création d'un ticket avec un utilisateur inexistant
        create_ticket(9999, v_asset_id, 'Test avec utilisateur inexistant');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/

-- Procedure to resolve a ticket
CREATE OR REPLACE PROCEDURE resolve_ticket(
    p_ticket_id NUMBER
) IS
    v_ticket_exists NUMBER;
BEGIN
    -- Check if ticket exists
    SELECT COUNT(*) INTO v_ticket_exists 
    FROM TICKET 
    WHERE ticket_id = p_ticket_id;
    
    IF v_ticket_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Ticket not found');
    END IF;
    
    -- Mark ticket as resolved
    UPDATE TICKET
    SET status = 'closed',
        resolution_date = SYSDATE,
        updated_date = SYSDATE
    WHERE ticket_id = p_ticket_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END resolve_ticket;
/

-- ######################################
-- Test resolve_ticket()
-- ######################################
-- Cas normal
BEGIN
    -- Déclaration des variables pour les tests
    DECLARE
        v_ticket_id NUMBER;
    BEGIN
        -- Sélection d'un ticket ouvert de Cergy
        SELECT t.ticket_id INTO v_ticket_id
        FROM TICKET t
        JOIN SITE s ON t.site_id = s.site_id
        WHERE s.name = 'Cergy' AND t.status = 'open'
        AND ROWNUM = 1;
        
        -- Résolution du ticket
        resolve_ticket(v_ticket_id);
        DBMS_OUTPUT.PUT_LINE('Ticket résolu avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec ticket inexistant
BEGIN
    -- Tentative de résolution d'un ticket inexistant
    resolve_ticket(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/
