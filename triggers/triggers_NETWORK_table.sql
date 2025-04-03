CREATE OR REPLACE TRIGGER trg_network_update_timestamp
BEFORE UPDATE ON NETWORK
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/