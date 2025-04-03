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