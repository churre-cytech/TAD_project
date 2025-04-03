-- ###################################################################################
-- DROP EXISTING TRIGGER (if exists) for TICKET table
-- ###################################################################################
DROP TRIGGER trg_ticket_status_update;
DROP TRIGGER trg_ticket_high_priority_assigned;
DROP TRIGGER trg_ticket_site_consistency;
DROP TRIGGER trg_ticket_prevent_closed_update;
DROP TABLE TICKET_AUDIT CASCADE CONSTRAINTS;
DROP TRIGGER trg_ticket_audit;
/


-- ###################################################################################
-- Trigger 1 :
-- When a ticket is updated, the trigger automatically sets the updated_date.
-- Additionally, if the ticket’s status changes to 'closed' (from any other status)
-- and resolution_date is NULL, it sets resolution_date to the current date.
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_ticket_status_update
BEFORE UPDATE ON TICKET
FOR EACH ROW
BEGIN
    -- Automatically update the updated_date with the current date
    :NEW.updated_date := SYSDATE;
    
    -- If the ticket status is changed to 'closed' and it was not 'closed' before,
    -- then, if the resolution_date is still NULL, set it to the current date.
    IF :NEW.status = 'closed' AND :OLD.status <> 'closed' THEN
        IF :NEW.resolution_date IS NULL THEN
            :NEW.resolution_date := SYSDATE;
        END IF;
    END IF;
END;
/

-- ########## Test Section for Trigger 1 ##########
-- Insert a new ticket with status 'open'
-- INSERT INTO TICKET (
--     user_id, site_id, subject, description, status, priority
-- ) VALUES (
--     1,
--     1,
--     'Connection Problem',
--     'Unable to connect to the network',
--     'open',
--     'medium'
-- );

-- COMMIT;

-- Verify that the ticket is inserted with resolution_date as NULL
-- SELECT ticket_id, status, resolution_date, updated_date
-- FROM TICKET
-- WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);

-- -- Update the ticket status to 'closed'
-- UPDATE TICKET
--     SET status = 'closed'
--     WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);

-- COMMIT;

-- -- Verify that the status is updated to 'closed' and resolution_date is set automatically
-- SELECT ticket_id, status, resolution_date, updated_date
-- FROM TICKET
-- WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);





-- ###################################################################################
-- Trigger 2 :
-- This trigger ensures that if a ticket is marked as 'high' priority,
-- the assigned_to field must not be NULL. If it is, an error is raised.
-- ###################################################################################

CREATE OR REPLACE TRIGGER trg_ticket_high_priority_assigned
BEFORE INSERT OR UPDATE ON TICKET
FOR EACH ROW
BEGIN
    -- If the ticket has 'high' priority and no technician is assigned,
    -- raise an error to prevent the insertion or update.
    IF :NEW.priority = 'high' AND :NEW.assigned_to IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'For a high priority ticket, the assigned_to field must be provided.');
    END IF;
END;
/

-- ########## Test Section for Trigger 2 ##########
-- Attempt to insert a high priority ticket without an assigned technician.
-- This should raise an error.
-- INSERT INTO TICKET (user_id, site_id, subject, description, status, priority)
-- VALUES (
--     1,         -- Example user_id
--     1,         -- Example site_id
--     'Urgent Ticket',
--     'Critical network issue',
--     'open',
--     'high'
-- );
-- Expected Error:
-- ORA-20003: For a high priority ticket, the assigned_to field must be provided.

-- Insert a high priority ticket with an assigned technician.
-- INSERT INTO TICKET (user_id, site_id, subject, description, status, priority, assigned_to)
-- VALUES (
--     1,
--     1,
--     'Urgent Ticket',
--     'Critical network issue',
--     'open',
--     'high',
--     4
-- );

-- COMMIT;

-- Suppose there is an existing ticket (ticket_id = 1501) without an assigned technician.
-- Attempt to update its priority to 'high' should fail.
-- UPDATE TICKET
--     SET priority = 'high'
--     WHERE ticket_id = 1501;
-- This update should raise the error defined in the trigger.






-- ###################################################################################
-- Trigger 3 :
-- 
-- 
-- ###################################################################################
CREATE OR REPLACE TRIGGER trg_ticket_site_consistency
BEFORE INSERT OR UPDATE ON TICKET
FOR EACH ROW
DECLARE
    v_creator_site_id  USER_ACCOUNT.site_id%TYPE;
    v_assigned_site_id USER_ACCOUNT.site_id%TYPE;
BEGIN
    -- Retrieve the site of the ticket creator from USER_ACCOUNT
    SELECT site_id
        INTO v_creator_site_id
        FROM USER_ACCOUNT
    WHERE user_id = :NEW.user_id;
    
    -- Ensure that the creator's site matches the ticket's site_id
    IF v_creator_site_id <> :NEW.site_id THEN
        RAISE_APPLICATION_ERROR(-20011,
        'The ticket creator must belong to the same site as the ticket.');
    END IF;
    
    -- If a technician is assigned, verify that his site is the same as the ticket's site
    IF :NEW.assigned_to IS NOT NULL THEN
        SELECT site_id
        INTO v_assigned_site_id
        FROM USER_ACCOUNT
        WHERE user_id = :NEW.assigned_to;
        
        IF v_assigned_site_id <> :NEW.site_id THEN
        RAISE_APPLICATION_ERROR(-20010,
            'The assigned technician must belong to the same site as the ticket.');
        END IF;
    END IF;
END;
/

-- Insertion success : creator and technician both belong to site 1
-- INSERT INTO TICKET (
--     user_id, site_id, subject, description, status, priority, assigned_to
-- )
-- VALUES (
--     2,            -- Creator (site 1)
--     2,            -- Ticket site_id = 1
--     'Valid Ticket',
--     'Ticket where creator and assigned technician are on the same site.',
--     'open',
--     'medium',
--     4480            -- Assigned technician (site 1)
-- );
-- COMMIT;

-- Insertion failed : creator does not belong to site 1
-- INSERT INTO TICKET (
--     user_id, site_id, subject, description, status, priority, assigned_to
-- )
-- VALUES (
--     2,            -- Creator (site 2)
--     1,            -- Ticket site_id = 1 (mismatch)
--     'Invalid Ticket',
--     'Ticket with creator site mismatch.',
--     'open',
--     'medium',
--     10
-- );
-- Expected error: ORA-20011: The ticket creator must belong to the same site as the ticket.

-- Insertion failed : assigned technician does not belong to site 1
-- INSERT INTO TICKET (
--     user_id, site_id, subject, description, status, priority, assigned_to
-- )
-- VALUES (
--     1,            -- Creator (site 1)
--     1,            -- Ticket site_id = 1
--     'Invalid Ticket',
--     'Ticket with assigned technician site mismatch.',
--     'open',
--     'medium',
--     20            -- Assigned technician (supposé appartenir au site 2)
-- );
-- Expected error: ORA-20010: The assigned technician must belong to the same site as the ticket.


-- Suppose ticket_id = 100 exists with site_id = 1.
-- Update assigned_to with an user_id from another site (e.g., user 20 from site 2)
-- UPDATE TICKET
--     SET assigned_to = 20
--     WHERE ticket_id = 100;
-- Expected error: ORA-20010: The assigned technician must belong to the same site as the ticket.





-- ###################################################################################
-- Trigger 4 :
-- If the ticket is already closed, prevent any modifications
-- ###################################################################################\
CREATE OR REPLACE TRIGGER trg_ticket_prevent_closed_update
BEFORE UPDATE ON TICKET
FOR EACH ROW
BEGIN
    IF :OLD.status = 'closed' THEN
        RAISE_APPLICATION_ERROR(-20020, 'Cannot update a closed ticket.');
    END IF;
END;
/

-- INSERT INTO TICKET (user_id, site_id, subject, description, status, priority, assigned_to)
-- VALUES (1, 1, 'Closed Ticket Test', 'This ticket will be closed', 'open', 'medium', 10);
-- COMMIT;

-- UPDATE TICKET
--     SET status = 'closed',
--         updated_by = 1,
--         resolution_date = SYSDATE
--     WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);
-- COMMIT;

-- UPDATE TICKET
--     SET subject = 'Modified subject'
--     WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);




-- ###################################################################################
-- Trigger 5: Audit Ticket Status Changes
-- This table and trigger log changes in the status of tickets.
-- ###################################################################################


-- Create the audit table for ticket status changes
CREATE TABLE TICKET_AUDIT (
    audit_id     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ticket_id    NUMBER,
    change_date  DATE DEFAULT SYSDATE,
    old_status   VARCHAR2(20),
    new_status   VARCHAR2(20),
    changed_by   NUMBER
);

-- Create the audit trigger for the TICKET table
CREATE OR REPLACE TRIGGER trg_ticket_audit
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    -- Record the audit only if the ticket status has changed
    IF :OLD.status <> :NEW.status THEN
        INSERT INTO TICKET_AUDIT(ticket_id, change_date, old_status, new_status, changed_by)
        VALUES(:OLD.ticket_id, SYSDATE, :OLD.status, :NEW.status, :NEW.updated_by);
    END IF;
END;
/

-- #############################################
-- Test Section for the Audit Trigger
-- #############################################

-- -- Insert a new ticket with status 'open'
-- INSERT INTO TICKET (user_id, site_id, subject, description, status, priority, assigned_to)
-- VALUES (1, 1, 'Audit Test Ticket', 'Initial ticket status is open', 'open', 'medium', 10);
-- COMMIT;

-- -- Update the ticket : change status from 'open' to 'pending'
-- UPDATE TICKET
--     SET status = 'pending',
--         updated_by = 5  -- Example user ID performing the change
--     WHERE ticket_id = (SELECT MAX(ticket_id) FROM TICKET);
-- COMMIT;

-- -- Retrieve all records from the audit table to check status changes
-- SELECT * FROM TICKET_AUDIT;

