CREATE OR REPLACE PROCEDURE report_maintenance_assets IS
    CURSOR c_maintenance_assets IS
    SELECT asset_id, name, assigned_user_id, updated_at
        FROM ASSET
        WHERE status = 'maintenance';
    
    v_asset_record c_maintenance_assets%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== Maintenance Assets Report =====');
    
    OPEN c_maintenance_assets;
    LOOP
    FETCH c_maintenance_assets INTO v_asset_record;
    EXIT WHEN c_maintenance_assets%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE(
        'Asset ID: ' || v_asset_record.asset_id ||
        ' | Name: ' || v_asset_record.name ||
        ' | Assigned User: ' || NVL(TO_CHAR(v_asset_record.assigned_user_id), 'None') ||
        ' | Last Updated: ' || TO_CHAR(v_asset_record.updated_at, 'DD-MON-YYYY HH24:MI:SS')
    );
    END LOOP;
    CLOSE c_maintenance_assets;
    
    DBMS_OUTPUT.PUT_LINE('===== End of Report =====');
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END report_maintenance_assets;
/

SET SERVEROUTPUT ON;
EXEC report_maintenance_assets;


CREATE OR REPLACE PROCEDURE report_outdated_maintenance_assets IS
    CURSOR c_assets IS
        SELECT asset_id, name, updated_at, status
        FROM ASSET
        WHERE status = 'maintenance';
    
    v_asset c_assets%ROWTYPE;
    v_threshold DATE := SYSDATE - 1000;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== Outdated Maintenance Assets Report =====');
    
    OPEN c_assets;
    LOOP
    FETCH c_assets INTO v_asset;
    EXIT WHEN c_assets%NOTFOUND;
    
    IF v_asset.updated_at < v_threshold THEN
        DBMS_OUTPUT.PUT_LINE('Asset ID: ' || v_asset.asset_id ||
                            ' | Name: ' || v_asset.name ||
                            ' | Last Updated: ' || TO_CHAR(v_asset.updated_at, 'DD-MON-YYYY'));
        END IF;
    END LOOP;
    CLOSE c_assets;
    
    DBMS_OUTPUT.PUT_LINE('===== End of Report =====');
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END report_outdated_maintenance_assets;
/

SET SERVEROUTPUT ON;
EXEC report_outdated_maintenance_assets;




SET SERVEROUTPUT ON;
DECLARE
    CURSOR cur_inconsistent_assets IS
        SELECT a.asset_id, a.site_id, u.site_id AS assigned_site
        FROM ASSET a
        JOIN USER_ACCOUNT u ON a.assigned_user_id = u.user_id
        WHERE a.site_id <> u.site_id;
        
    v_asset cur_inconsistent_assets%ROWTYPE;
BEGIN
    FOR v_asset IN cur_inconsistent_assets LOOP
        DBMS_OUTPUT.PUT_LINE('Asset ID: ' || v_asset.asset_id ||
                            ' | Asset Site: ' || v_asset.site_id ||
                            ' | Assigned Site: ' || v_asset.assigned_site);
    END LOOP;  
END;
/   

