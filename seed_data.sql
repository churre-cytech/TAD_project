SELECT user FROM dual;



--------------------------------------------------------------------
-- Insertion dans SITE
--------------------------------------------------------------------
SELECT * FROM SITE;

INSERT INTO SITE (name, location)
VALUES ('Cergy', '95000 Cergy');

INSERT INTO SITE (name, location)
VALUES ('Pau', '64000 Pau');

COMMIT;



--------------------------------------------------------------------
-- Insertion dans USER_ROLE
--------------------------------------------------------------------
SELECT * FROM USER_ROLE;

DELETE FROM USER_ROLE;
COMMIT;

INSERT INTO USER_ROLE (role_name, description)
VALUES ('Super Administrator', 'Full control over the entire system, including configuration, security, and user management');

INSERT INTO USER_ROLE (role_name, description)
VALUES ('Academic Administrator', 'Manages academic aspects such as student attendance, timetables, and academic records');

INSERT INTO USER_ROLE (role_name, description)
VALUES ('IT Manager', 'Oversees IT operations, including asset management, ticket handling, and maintenance supervision');

INSERT INTO USER_ROLE (role_name, description)
VALUES ('Technician', 'Provides technical support and maintenance; access to technical tools and troubleshooting functionalities');

INSERT INTO USER_ROLE (role_name, description)
VALUES ('Employee', 'General user with limited access: can view personal information and submit support tickets');

INSERT INTO USER_ROLE (role_name, description)
VALUES ('Student', 'Very restricted access, mainly read-only access to general information');

COMMIT;



--------------------------------------------------------------------
-- Insertion dans USER_ACCOUNT
--------------------------------------------------------------------
-- LINK WITH ROLE_ID :
-- role_id | role_name
--      1  | Super Administrator
--      2  | Academic Administrator
--      3  | IT Manager
--      4  | Technician
--      5  | Employee
--      6  | Student

SELECT * FROM USER_ACCOUNT;

-- QUERY TO RETRIEVE ALL STUDENTS
SELECT *
FROM USER_ACCOUNT u
JOIN USER_ROLE r ON u.role_id = r.role_id
JOIN SITE s ON u.site_id = s.site_id
WHERE r.role_name = 'Student'
  AND s.name = 'Cergy';

DELETE FROM USER_ACCOUNT;
COMMIT;

DECLARE
  v_first_name VARCHAR2(50);
  v_last_name  VARCHAR2(50);
  v_username   VARCHAR2(50);
  v_password   VARCHAR2(50);
  v_email      VARCHAR2(100);
  v_phone      VARCHAR2(20);
  v_random_num NUMBER;
BEGIN
  FOR i IN 1..100 LOOP
    -- Génère un prénom aléatoire de 6 lettres majuscules
    v_first_name := DBMS_RANDOM.STRING('U', 6);
    -- Génère un nom de famille aléatoire de 8 lettres minuscules
    v_last_name  := DBMS_RANDOM.STRING('L', 8);
    
    -- Construit un username unique en concaténant prénom, nom et un suffixe numérique aléatoire
    v_username := LOWER(v_first_name || '.' || v_last_name || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100, 1000))));
    v_email := v_username || '@example.com';
    
    -- Génère un mot de passe alphanumérique de 10 caractères
    v_password := DBMS_RANDOM.STRING('A', 10);
    
    -- Génère un numéro de téléphone aléatoire : "06" suivi de 8 chiffres
    v_random_num := TRUNC(DBMS_RANDOM.VALUE(10000000, 100000000));
    v_phone := '06' || TO_CHAR(v_random_num);
    
    INSERT INTO USER_ACCOUNT (
      username,
      password,
      first_name,
      last_name,
      email,
      phone,
      site_id,
      role_id,
      created_at,
      updated_at
    )
    VALUES (
      v_username,
      v_password,
      v_first_name,
      v_last_name,
      v_email,
      v_phone,
      CASE WHEN MOD(i, 2) = 0 THEN 2 ELSE 1 END,  -- site_id aléatoire entre 1 et 2
      TRUNC(DBMS_RANDOM.VALUE(1,7)), -- random role_id between 1 and 6
      SYSTIMESTAMP,
      SYSTIMESTAMP
    );
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Random data for USER_ACCOUNT inserted successfully.');
END;




--------------------------------------------------------------------
-- Insertion dans ASSET_TYPE
--------------------------------------------------------------------
SELECT * FROM ASSET_TYPE;

DELETE FROM ASSET_TYPE;
COMMIT;

BEGIN
  --------------------------------------------------------------------
  -- Ordinateurs de bureau
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('desktop', 'Desktop Computer', 'Dell Optiplex 7070', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('desktop', 'Desktop Computer', 'HP ProDesk 600 G5', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('desktop', 'Desktop Computer', 'Lenovo ThinkCentre M720', 1);
  
  --------------------------------------------------------------------
  -- Ordinateurs portables
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('laptop', 'Laptop', 'Lenovo ThinkPad', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('laptop', 'Laptop', 'Dell Inspiron 15', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('laptop', 'Laptop', 'HP EliteBook 840', 1);
  
  --------------------------------------------------------------------
  -- Imprimante avec scanner intégré
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('printer_scanner', 'Printer & Scanner', 'HP LaserJet Pro', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('printer_scanner', 'Printer & Scanner', 'Canon Pixma', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('printer_scanner', 'Printer & Scanner', 'Brother HL-L2350DW', 1);
  
  --------------------------------------------------------------------
  -- Équipement d'affichage (tableau interactif ou projecteur)
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('display_equipment', 'Display Equipment', 'Interactive Whiteboard / Projector', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('display_equipment', 'Display Equipment', 'Samsung Flip', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('display_equipment', 'Display Equipment', 'BenQ Interactive Display', 1);
  
  --------------------------------------------------------------------
  -- Tablettes
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('tablet', 'Tablet', 'Apple iPad', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('tablet', 'Tablet', 'Samsung Galaxy Tab', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('tablet', 'Tablet', 'Microsoft Surface Go', 1);

  --------------------------------------------------------------------
  -- Claviers
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('keyboard', 'Keyboard', 'Logitech K780', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('keyboard', 'Keyboard', 'Corsair K95', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('keyboard', 'Keyboard', 'Microsoft Sculpt Ergonomic', 1);
  
  --------------------------------------------------------------------
  -- Souris
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('mouse', 'Mouse', 'Logitech MX Master', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('mouse', 'Mouse', 'Razer DeathAdder', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('mouse', 'Mouse', 'Logitech G502', 1);
  
  --------------------------------------------------------------------
  -- Équipements réseau
  --------------------------------------------------------------------
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('network_equipment', 'Network Equipment', 'Cisco Router', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('network_equipment', 'Network Equipment', 'Juniper EX4300', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('network_equipment', 'Network Equipment', 'Netgear ProSAFE', 1);

  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('ethernet_cable', 'Ethernet Cable', 'TP-Link Cat6', 1);
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Asset types inserted successfully.');
END;



--------------------------------------------------------------------
-- Insertion dans ASSET
--------------------------------------------------------------------
SELECT * FROM ASSET;

--------------------------------------------------------------------
-- PROCEDURE FOR ASSET TABLE (insert_asset)
--------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_asset (
  p_system_name   IN VARCHAR2,
  p_model_name    IN VARCHAR2,
  p_name          IN VARCHAR2,
  p_serial        IN VARCHAR2,
  p_assigned_user_id IN VARCHAR2,
  p_purchase_date IN DATE,
  p_site_id       IN NUMBER,
  p_status        IN VARCHAR2 DEFAULT 'active'
) IS
  v_asset_type_id NUMBER;
  v_asset_id      NUMBER;
  v_dummy NUMBER;
BEGIN

  -- Test if p_assigned_user_id exists in USER_ACCOUNT 
  IF p_assigned_user_id IS NOT NULL THEN
    BEGIN
      SELECT 1 FROM v_dummy
      FROM USER_ACCOUNT
      WHERE user_id = p_assigned_user_id
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Assigned user with user_id ' || p_assigned_user_id || ' does not exist.');
    END;
  END IF;

  -- Récupération de l'asset_type_id basé sur system_name et model_name
  SELECT asset_type_id 
  INTO v_asset_type_id 
  FROM ASSET_TYPE 
  WHERE system_name = p_system_name 
    AND model_name = p_model_name;
  
  -- Insertion dans ASSET
  INSERT INTO ASSET (
      asset_type_id,
      name,
      serial,
      assigned_user_id,
      purchase_date,
      site_id,
      status,
      created_at,
      updated_at
  )
  VALUES (
      v_asset_type_id,
      p_name,
      p_serial,
      p_assigned_user_id,
      p_purchase_date,
      p_site_id,
      p_status,
      SYSTIMESTAMP,
      SYSTIMESTAMP
  )
  RETURNING asset_id INTO v_asset_id;
  
  DBMS_OUTPUT.PUT_LINE('Asset inserted with asset_id = ' || v_asset_id);
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No asset type found for the given criteria.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END insert_asset;






--------------------------------------------------------------------
-- PROCEDURE FOR ASSET TABLE (insert_asset)
--------------------------------------------------------------------

-- Testing if insert_asset is working
BEGIN
  insert_asset(
    p_system_name   => 'desktop',
    p_model_name    => 'Dell Optiplex 7070',
    p_name          => 'Office Desktop A',
    p_serial        => 'SN-0012345',
    p_assigned_user_id => TRUNC(DBMS_RANDOM.VALUE(1,200)),
    p_purchase_date => TO_DATE('2023-10-10','YYYY-MM-DD'),
    p_site_id       => 1,
    p_status        => 'active'
  );
END;


-- Seeding with PL/SQL script
DECLARE
  v_asset_id         NUMBER;
  v_asset_type_id    NUMBER;
  v_name             VARCHAR2(100);
  v_serial           VARCHAR2(100);
  v_purchase_date    DATE;
  v_random_num       NUMBER;
  v_days_offset      NUMBER;
  v_site_id          NUMBER;
  v_status           VARCHAR2(20) := 'active';
  v_base_date        DATE := TO_DATE('2020-01-01','YYYY-MM-DD');
  v_assigned_user_id NUMBER;
BEGIN
  FOR i IN 1..100 LOOP
    -- Generate a random asset type id (assumes IDs 1 to 10 exist)
    v_asset_type_id := TRUNC(DBMS_RANDOM.VALUE(1, 11));
    
    -- Generate a random asset name (e.g., "Asset_ABCDE")
    v_name := 'Asset_' || DBMS_RANDOM.STRING('U', 5);
    
    -- Generate a random serial number (e.g., "SN-123456")
    v_random_num := TRUNC(DBMS_RANDOM.VALUE(100000, 1000000));
    v_serial := 'SN-' || TO_CHAR(v_random_num);
    
    -- Generate a random purchase date by adding a random number of days to a base date
    v_days_offset := TRUNC(DBMS_RANDOM.VALUE(0, 1500));
    v_purchase_date := v_base_date + v_days_offset;
    
    -- Randomly assign a site_id (either 1 or 2)
    v_site_id := TRUNC(DBMS_RANDOM.VALUE(1, 3));
    
    -- For assigned_user_id: 50% chance to assign a random user (between 1 and 100) or leave NULL
    IF DBMS_RANDOM.VALUE(0,1) < 0.5 THEN
      v_assigned_user_id := NULL;
    ELSE
      v_assigned_user_id := TRUNC(DBMS_RANDOM.VALUE(27, 128));
    END IF;
    
    -- Insert the asset into ASSET
    INSERT INTO ASSET (
      asset_type_id,
      name,
      serial,
      assigned_user_id,
      purchase_date,
      site_id,
      status,
      created_at,
      updated_at
    )
    VALUES (
      v_asset_type_id,
      v_name,
      v_serial,
      v_assigned_user_id,
      v_purchase_date,
      v_site_id,
      v_status,
      SYSTIMESTAMP,
      SYSTIMESTAMP
    )
    RETURNING asset_id INTO v_asset_id;
    
    DBMS_OUTPUT.PUT_LINE('Inserted asset ' || v_name || 
                        ' with asset_id = ' || v_asset_id || 
                        ', asset_type_id = ' || v_asset_type_id ||
                        ', site_id = ' || v_site_id ||
                        ', assigned_user_id = ' || NVL(TO_CHAR(v_assigned_user_id), 'NULL'));
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('All assets inserted successfully.');
END;

