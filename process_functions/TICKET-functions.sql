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
