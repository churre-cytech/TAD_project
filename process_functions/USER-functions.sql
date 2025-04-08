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
-- 1. Test pour add_new_student (ROLE_ACADEMIC_ADMIN_CERGY)
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
-- Cas normal (supposons que l'ID 1 est un étudiant)
BEGIN
    update_student_email(63, 'nouveau.email@studentcytech.fr');
    DBMS_OUTPUT.PUT_LINE('Email mis à jour avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
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



-- Function for ROLE_IT_MANAGER
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
    IF p_role = 'ROLE_STUDENT_TEACHER_CERGY' THEN
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