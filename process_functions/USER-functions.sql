-- Functions for user management

-- Function for Student role
-- Add a new student to the system
CREATE OR REPLACE PROCEDURE add_new_student(
    p_firstname VARCHAR2,
    p_lastname VARCHAR2,
    p_email VARCHAR2,
    p_site_id NUMBER
) IS
    v_username VARCHAR2(50);
    v_default_password VARCHAR2(255) := 'changeme123';
    v_student_role_id NUMBER;
    v_site_exists NUMBER;
BEGIN
    -- Check if site exists
    SELECT COUNT(*) INTO v_site_exists 
    FROM SITE 
    WHERE site_id = p_site_id;
    
    IF v_site_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Site not found');
    END IF;
    
    -- Get student role ID
    BEGIN
        SELECT role_id INTO v_student_role_id 
        FROM USER_ROLE 
        WHERE role_name = 'Student';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20008, 'Student role not found');
    END;
    
    -- Create username based on firstname and lastname (e.g., john.doe)
    v_username := LOWER(p_firstname || '.' || p_lastname);
    
    -- Check if username already exists and modify if needed
    DECLARE
        v_count NUMBER;
        v_suffix NUMBER := 1;
    BEGIN
        LOOP
            SELECT COUNT(*) INTO v_count 
            FROM USER_ACCOUNT 
            WHERE username = v_username;
            
            EXIT WHEN v_count = 0;
            
            -- Append number to username if it exists
            v_username := LOWER(p_firstname || '.' || p_lastname || v_suffix);
            v_suffix := v_suffix + 1;
        END LOOP;
    END;
    
    -- Insert the new student
    INSERT INTO USER_ACCOUNT (
        username,
        password,
        first_name,
        last_name,
        email,
        site_id,
        role_id,
        created_at,
        updated_at
    ) VALUES (
        v_username,
        v_default_password,
        p_firstname,
        p_lastname,
        p_email,
        p_site_id,
        v_student_role_id,
        SYSTIMESTAMP,
        SYSTIMESTAMP
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END add_new_student;
/

-- ######################################
-- Test add_new_student()
-- ######################################
-- 1. Test pour add_new_student (Academic Administrator)
-- Cas normal
BEGIN
    add_new_student('Jean', 'Dupont', 'jean.dupont@student.cytech.fr', 1);
    DBMS_OUTPUT.PUT_LINE('Étudiant ajouté avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test avec site inexistant
BEGIN
    add_new_student('Pierre', 'Martin', 'pierre.martin@student.cytech.fr', 3);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Update a student's email
CREATE OR REPLACE PROCEDURE update_student_email(
    p_user_id NUMBER,
    p_new_email VARCHAR2
) IS
    v_user_exists NUMBER;
    v_is_student NUMBER;
BEGIN
    -- Check if user exists and is a student
    SELECT COUNT(*) INTO v_user_exists 
    FROM USER_ACCOUNT ua
    JOIN USER_ROLE ur ON ua.role_id = ur.role_id
    WHERE ua.user_id = p_user_id
    AND ur.role_name = 'Student';
    
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Student not found');
    END IF;
    
    -- Check if email is already used by another user
    DECLARE
        v_email_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_email_exists 
        FROM USER_ACCOUNT 
        WHERE email = p_new_email
        AND user_id != p_user_id;
        
        IF v_email_exists > 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Email already in use by another user');
        END IF;
    END;
    
    -- Update the email
    UPDATE USER_ACCOUNT
    SET email = p_new_email,
        updated_at = SYSTIMESTAMP
    WHERE user_id = p_user_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_student_email;
/

-- ######################################
-- Test update_student_email()
-- ######################################
-- Cas normal (avec un étudiant)
BEGIN
    -- Sélection d'un étudiant de Cergy
    DECLARE
        v_student_id NUMBER;
    BEGIN
        SELECT ua.user_id INTO v_student_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Student' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        update_student_email(v_student_id, 'nouveau.email@studentcytech.fr');
        DBMS_OUTPUT.PUT_LINE('Email mis à jour avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec un étudiant inexistant
BEGIN
    update_student_email(999, 'inexistant@student.cytech.fr');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Test avec un utilisateur qui n'est pas un étudiant
BEGIN
    -- Sélection d'un employé de Cergy
    DECLARE
        v_employee_id NUMBER;
    BEGIN
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        update_student_email(v_employee_id, 'employe.email@cytech.fr');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/

-- Function for IT Manager
-- Add a new user (any role except student)
CREATE OR REPLACE PROCEDURE add_new_user(
    p_firstname VARCHAR2,
    p_lastname VARCHAR2,
    p_role VARCHAR2,
    p_email VARCHAR2,
    p_site_id NUMBER
) IS
    v_username VARCHAR2(50);
    v_default_password VARCHAR2(255) := 'changeme123'; -- Default password that should be changed on first login
    v_role_id NUMBER;
    v_site_exists NUMBER;
BEGIN
    -- Check if site exists
    SELECT COUNT(*) INTO v_site_exists 
    FROM SITE 
    WHERE site_id = p_site_id;
    
    IF v_site_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Site not found');
    END IF;
    
    -- Check if role is not student role
    IF p_role = 'Student' THEN
        RAISE_APPLICATION_ERROR(-20011, 'Please use add_new_student procedure for student accounts');
    END IF;
    
    -- Get role ID
    BEGIN
        SELECT role_id INTO v_role_id 
        FROM USER_ROLE 
        WHERE role_name = p_role;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20012, 'Role not found');
    END;
    
    -- Create username based on firstname and lastname (e.g., john.doe)
    v_username := LOWER(p_firstname || '.' || p_lastname);
    
    -- Check if username already exists and modify if needed
    DECLARE
        v_count NUMBER;
        v_suffix NUMBER := 1;
    BEGIN
        LOOP
            SELECT COUNT(*) INTO v_count 
            FROM USER_ACCOUNT 
            WHERE username = v_username;
            
            EXIT WHEN v_count = 0;
            
            -- Append number to username if it exists
            v_username := LOWER(p_firstname || '.' || p_lastname || v_suffix);
            v_suffix := v_suffix + 1;
        END LOOP;
    END;
    
    -- Insert the new user
    INSERT INTO USER_ACCOUNT (
        username,
        password,
        first_name,
        last_name,
        email,
        site_id,
        role_id,
        created_at,
        updated_at
    ) VALUES (
        v_username,
        v_default_password,
        p_firstname,
        p_lastname,
        p_email,
        p_site_id,
        v_role_id,
        SYSTIMESTAMP,
        SYSTIMESTAMP
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END add_new_user;
/

-- ######################################
-- Test add_new_user()
-- ######################################
-- Cas normal pour un technicien
BEGIN
    add_new_user('Paul', 'Technicien', 'Technician', 'paul.tech@cytech.fr', 1);
    DBMS_OUTPUT.PUT_LINE('Utilisateur ajouté avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test pour un rôle inexistant
BEGIN
    add_new_user('Marc', 'Test', 'ROLE_INEXISTANT', 'marc.test@cytech.fr', 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Test avec le rôle étudiant (qui devrait utiliser add_new_student à la place)
BEGIN
    add_new_user('Sophie', 'Étudiante', 'Student', 'sophie.etu@student.cytech.fr', 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Function for IT Manager
-- Assign an asset to a user
CREATE OR REPLACE PROCEDURE assign_asset_to_user(
    p_asset_id NUMBER,
    p_user_id NUMBER
) IS
    v_asset_exists NUMBER;
    v_user_exists NUMBER;
    v_asset_status VARCHAR2(20);
BEGIN
    -- Check if asset exists
    SELECT COUNT(*) INTO v_asset_exists 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    IF v_asset_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Asset not found');
    END IF;
    
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_exists 
    FROM USER_ACCOUNT 
    WHERE user_id = p_user_id;
    
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'User not found');
    END IF;
    
    -- Check if asset is available (not decommissioned)
    SELECT status INTO v_asset_status 
    FROM ASSET 
    WHERE asset_id = p_asset_id;
    
    IF v_asset_status = 'decommissioned' THEN
        RAISE_APPLICATION_ERROR(-20015, 'Cannot assign decommissioned asset');
    END IF;
    
    -- Update the asset
    UPDATE ASSET
    SET assigned_user_id = p_user_id,
        updated_at = SYSTIMESTAMP
    WHERE asset_id = p_asset_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END assign_asset_to_user;
/

-- ######################################
-- Test assign_asset_to_user()
-- ######################################
-- Cas normal
BEGIN
    -- Sélection d'un asset actif de Cergy
    DECLARE
        v_asset_id NUMBER;
        v_employee_id NUMBER;
    BEGIN
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        assign_asset_to_user(v_asset_id, v_employee_id);
        DBMS_OUTPUT.PUT_LINE('Asset assigné avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec asset inexistant
BEGIN
    -- Sélection d'un employé de Cergy
    DECLARE
        v_employee_id NUMBER;
    BEGIN
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        assign_asset_to_user(999, v_employee_id);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/

-- Function for IT Manager
-- Change asset status
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
        RAISE_APPLICATION_ERROR(-20016, 'Asset not found');
    END IF;
    
    -- Check if status is valid
    SELECT COUNT(*) INTO v_valid_status 
    FROM (
        SELECT 'active' AS status FROM dual
        UNION ALL SELECT 'maintenance' FROM dual
        UNION ALL SELECT 'decommissioned' FROM dual
    ) 
    WHERE status = p_new_status;
    
    IF v_valid_status = 0 THEN
        RAISE_APPLICATION_ERROR(-20017, 'Invalid status. Must be active, maintenance, or decommissioned');
    END IF;
    
    -- Update the asset status
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
    -- Sélection d'un asset actif de Cergy
    DECLARE
        v_asset_id NUMBER;
    BEGIN
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        change_asset_status(v_asset_id, 'maintenance');
        DBMS_OUTPUT.PUT_LINE('Statut changé avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Test avec statut invalide
BEGIN
    -- Sélection d'un asset actif de Cergy
    DECLARE
        v_asset_id NUMBER;
    BEGIN
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
        change_asset_status(v_asset_id, 'invalid_status');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
    END;
END;
/

-- Function for Employee
-- Create a new ticket
CREATE OR REPLACE PROCEDURE create_ticket(
    p_user_id NUMBER,
    p_asset_id NUMBER,
    p_description VARCHAR2
) IS
    v_user_exists NUMBER;
    v_asset_exists NUMBER;
    v_ticket_id NUMBER;
BEGIN
    -- Check if user exists
    SELECT COUNT(*) INTO v_user_exists 
    FROM USER_ACCOUNT 
    WHERE user_id = p_user_id;
    
    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'User not found');
    END IF;
    
    -- Check if asset exists (if provided)
    IF p_asset_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_asset_exists 
        FROM ASSET 
        WHERE asset_id = p_asset_id;
        
        IF v_asset_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20019, 'Asset not found');
        END IF;
    END IF;
    
    -- Get the site_id of the user
    DECLARE
        v_site_id NUMBER;
    BEGIN
        SELECT site_id INTO v_site_id
        FROM USER_ACCOUNT
        WHERE user_id = p_user_id;
        
        -- Insert the ticket
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
            v_site_id,
            'Support Request',
            p_description,
            'open',
            'medium',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        )
        RETURNING ticket_id INTO v_ticket_id;
        
        COMMIT;
    END;
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
    -- Sélection d'un employé de Cergy
    DECLARE
        v_employee_id NUMBER;
        v_asset_id NUMBER;
    BEGIN
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        SELECT a.asset_id INTO v_asset_id
        FROM ASSET a
        JOIN SITE s ON a.site_id = s.site_id
        WHERE s.name = 'Cergy' AND a.status = 'active'
        AND ROWNUM = 1;
        
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
    -- Sélection d'un employé de Cergy
    DECLARE
        v_employee_id NUMBER;
    BEGIN
        SELECT ua.user_id INTO v_employee_id
        FROM USER_ACCOUNT ua
        JOIN USER_ROLE ur ON ua.role_id = ur.role_id
        JOIN SITE s ON ua.site_id = s.site_id
        WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
        AND ROWNUM = 1;
        
        create_ticket(v_employee_id, NULL, 'Demande d''accès au réseau Wi-Fi');
        DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
    END;
END;
/

-- Function for IT Manager
-- Resolve a ticket
CREATE OR REPLACE PROCEDURE resolve_ticket(
    p_ticket_id NUMBER
) IS
    v_ticket_exists NUMBER;
    v_ticket_status VARCHAR2(20);
BEGIN
    -- Check if ticket exists
    SELECT COUNT(*) INTO v_ticket_exists 
    FROM TICKET 
    WHERE ticket_id = p_ticket_id;
    
    IF v_ticket_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Ticket not found');
    END IF;
    
    -- Check if ticket is already resolved
    SELECT status INTO v_ticket_status 
    FROM TICKET 
    WHERE ticket_id = p_ticket_id;
    
    IF v_ticket_status = 'closed' THEN
        RAISE_APPLICATION_ERROR(-20021, 'Ticket is already resolved');
    END IF;
    
    -- Update the ticket
    UPDATE TICKET
    SET status = 'closed',
        resolution_date = SYSTIMESTAMP,
        updated_date = SYSTIMESTAMP
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
    -- Sélection d'un ticket ouvert de Cergy
    DECLARE
        v_ticket_id NUMBER;
    BEGIN
        SELECT t.ticket_id INTO v_ticket_id
        FROM TICKET t
        JOIN SITE s ON t.site_id = s.site_id
        WHERE s.name = 'Cergy' AND t.status = 'open'
        AND ROWNUM = 1;
        
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
    resolve_ticket(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/ 