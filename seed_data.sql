-- SELECT user FROM dual;



--------------------------------------------------------------------
-- Insertion dans SITE
--------------------------------------------------------------------
--SELECT * FROM SITE;

--DELETE FROM SITE;
--COMMIT;



BEGIN
  INSERT INTO SITE (name, location)
  VALUES ('Cergy', '95000 Cergy');

  INSERT INTO SITE (name, location)
  VALUES ('Pau', '64000 Pau');

  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Sites inserted successfully.');
END;
/



--------------------------------------------------------------------
-- Insertion dans USER_ROLE
--------------------------------------------------------------------
--SELECT * FROM USER_ROLE;

--DELETE FROM USER_ROLE;
--COMMIT;

BEGIN 
  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('Super Administrator', 'Full control over the entire system, including configuration, security, and user management');

  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('Academic Administrator', 'Manages academic aspects such as student attendance, timetables, and academic records');

  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('IT Manager', 'Oversees IT operations, including asset management, ticket handling, and maintenance supervision');

  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('Technician', 'Provides technical support and maintenance; access to technical tools and troubleshooting functionalities');

  INSERT INTO USER_ROLE (role_name, description) 
  VALUES ('Network manager', 'Manages networks and IP addresses');

  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('Employee', 'General user with limited access: can view personal information and submit support tickets');

  INSERT INTO USER_ROLE (role_name, description)
  VALUES ('Student', 'Very restricted access, mainly read-only access to general information');

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('User roles inserted successfully.');
END;
/


--------------------------------------------------------------------
-- Insertion dans USER_ACCOUNT
--------------------------------------------------------------------
-- LINK WITH ROLE_ID :
-- role_id | role_name
--      1  | Super Administrator
--      2  | Academic Administrator
--      3  | IT Manager
--      4  | Technician
--      5  | Network manager
--      6  | Employee
--      7  | Student

--SELECT * FROM USER_ACCOUNT;

-- QUERY TO RETRIEVE ALL STUDENTS FROM Cergy
--SELECT *
--FROM USER_ACCOUNT u
--JOIN USER_ROLE r ON u.role_id = r.role_id
---JOIN SITE s ON u.site_id = s.site_id
--WHERE r.role_name = 'Student'
  --AND s.name = 'Cergy';

--DELETE FROM USER_ACCOUNT;
--COMMIT;

DECLARE
  v_first_name VARCHAR2(50);
  v_last_name  VARCHAR2(50);
  v_username   VARCHAR2(50);
  v_password   VARCHAR2(50);
  v_email      VARCHAR2(100);
  v_phone      VARCHAR2(20);
  v_random_num NUMBER;
BEGIN
  FOR i IN 1..4500 LOOP
    -- Génère un prénom aléatoire de 6 lettres 
    v_first_name := DBMS_RANDOM.STRING('L', 6);
    -- Génère un nom de famille aléatoire de 8 lettres majuscules
    v_last_name  := DBMS_RANDOM.STRING('U', 8);
    
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
      TRUNC(DBMS_RANDOM.VALUE(1,8)), -- random role_id between 1 and 7
      SYSTIMESTAMP,
      SYSTIMESTAMP
    );
    
    IF MOD(i, 1000) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Inserted ' || i || ' rows into USER_ACCOUNT.');
    END IF;

  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Random data for USER_ACCOUNT inserted successfully.');
END;
/



--------------------------------------------------------------------
-- Insertion dans ASSET_TYPE
--------------------------------------------------------------------
-- SELECT * FROM ASSET_TYPE;

-- DELETE FROM ASSET_TYPE;
-- COMMIT;

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
  VALUES ('printer_scanner', 'Printer and Scanner', 'HP LaserJet Pro', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('printer_scanner', 'Printer and Scanner', 'Canon Pixma', 1);
  
  INSERT INTO ASSET_TYPE (system_name, label, model_name, is_active)
  VALUES ('printer_scanner', 'Printer and Scanner', 'Brother HL-L2350DW', 1);
  
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
/


--------------------------------------------------------------------
-- Insertion dans ASSET
--------------------------------------------------------------------
-- SELECT * FROM ASSET;

--------------------------------------------------------------------
-- PROCEDURE FOR ASSET TABLE (insert_asset)
--------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_asset (
  p_system_name   IN VARCHAR2,
  p_model_name    IN VARCHAR2,
  p_name          IN VARCHAR2,
  p_serial        IN VARCHAR2,
  p_assigned_user_id IN NUMBER,
  p_purchase_date IN DATE,
  p_site_id       IN NUMBER,
  p_status        IN VARCHAR2
) IS
  v_asset_type_id NUMBER;
  v_asset_id      NUMBER;
  v_dummy NUMBER;
BEGIN

  -- Test if p_assigned_user_id exists in USER_ACCOUNT 
  IF p_assigned_user_id IS NOT NULL THEN
    BEGIN
      SELECT 1 INTO v_dummy
      FROM USER_ACCOUNT
      WHERE user_id = p_assigned_user_id;
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
  
  -- DBMS_OUTPUT.PUT_LINE('Asset inserted with asset_id = ' || v_asset_id);
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No asset type found for the given criteria.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END insert_asset;
/





--------------------------------------------------------------------
-- PROCEDURE FOR ASSET TABLE (insert_asset)
--------------------------------------------------------------------

-- Testing if insert_asset is working
-- BEGIN
--   insert_asset(
--     p_system_name   => 'desktop',
--     p_model_name    => 'Dell Optiplex 7070',
--     p_name          => 'Office Desktop A',
--     p_serial        => 'SN-0012345',
--     p_assigned_user_id => TRUNC(DBMS_RANDOM.VALUE(1,200)),
--     p_purchase_date => TO_DATE('2023-10-10','YYYY-MM-DD'),
--     p_site_id       => 1,
--     p_status        => 'active'
--   );
-- END;


-- Seeding with PL/SQL script
DECLARE
  v_asset_id         ASSET.asset_id%TYPE;
  v_asset_type_id    ASSET.asset_type_id%TYPE;
  v_name             ASSET.name%TYPE;
  v_serial           ASSET.serial%TYPE;
  v_purchase_date    ASSET.purchase_date%TYPE;
  v_random_num       NUMBER;
  v_count            NUMBER;
  v_days_offset      NUMBER;
  v_site_id          ASSET.site_id%TYPE;
  v_status           ASSET.status%TYPE;
  v_base_date        DATE := TO_DATE('2020-01-01','YYYY-MM-DD');
  v_assigned_user_id ASSET.assigned_user_id%TYPE;
  v_rand_status      NUMBER;
  v_created_at       DATE;
  v_updated_at       DATE;
BEGIN
  FOR i IN 1..5000 LOOP
    -- Generate a random asset type id (assumes IDs 1 to 10 exist)
    v_asset_type_id := TRUNC(DBMS_RANDOM.VALUE(1, 11));
    
    -- Generate a random asset name (e.g., "Asset_ABCDE")
    v_name := 'Asset_' || DBMS_RANDOM.STRING('U', 5);
    
    LOOP
      v_random_num := TRUNC(DBMS_RANDOM.VALUE(100000, 1000000));
      v_serial := 'SN-' || DBMS_RANDOM.STRING('X', 8) || TO_CHAR(v_random_num);

      SELECT COUNT(*) INTO v_count 
      FROM asset 
      WHERE serial = v_serial;

      EXIT WHEN v_count = 0;
    END LOOP;    

    -- Generate a random purchase date by adding a random number of days to a base date
    v_days_offset := TRUNC(DBMS_RANDOM.VALUE(0, 1500));
    v_purchase_date := v_base_date + v_days_offset;
    
    -- Randomly assign a site_id (either 1 or 2)
    v_site_id := TRUNC(DBMS_RANDOM.VALUE(1, 3));
    
    IF DBMS_RANDOM.VALUE(0,1) < 0.1 THEN
      v_assigned_user_id := NULL;
    ELSE
      BEGIN
        SELECT user_id
          INTO v_assigned_user_id
          FROM (
            SELECT user_id
              FROM USER_ACCOUNT
            WHERE site_id = v_site_id
            ORDER BY DBMS_RANDOM.VALUE
          )
        WHERE ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_assigned_user_id := NULL;
      END;
    END IF;
    
    -- 80% chance 'active', 10% chance 'maintenance', 10% chance 'decommissioned' and v_assigned_user_id = NULL
    v_rand_status := DBMS_RANDOM.VALUE(0,1);
    IF v_rand_status < 0.8 THEN
      v_status := 'active';
    ELSIF v_rand_status < 0.9 THEN
      v_status := 'maintenance';
    ELSE
      v_status := 'decommissioned';
      v_assigned_user_id := NULL;
    END IF;

    v_created_at := v_base_date + TRUNC(DBMS_RANDOM.VALUE(0, 1500));
    v_updated_at := v_created_at + TRUNC(DBMS_RANDOM.VALUE(0, 31));
    
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
      v_created_at,
      v_updated_at
    )
    RETURNING asset_id INTO v_asset_id;
    
    -- DBMS_OUTPUT.PUT_LINE('Inserted asset ' || v_name || 
    --                     ' with asset_id = ' || v_asset_id || 
    --                     ', asset_type_id = ' || v_asset_type_id ||
    --                     ', site_id = ' || v_site_id ||
    --                     ', assigned_user_id = ' || NVL(TO_CHAR(v_assigned_user_id), 'NULL') ||
    --                     ', status = ' || v_status);
    IF MOD(i, 1000) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Inserted ' || i || ' rows into ASSET.');
    END IF;

  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('All assets inserted successfully.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting asset: ' || SQLERRM);
    RAISE;
END;
/


--------------------------------------------------------------------
-- Insertion dans TICKET
--------------------------------------------------------------------
-- SELECT * FROM TICKET;

-- SELECT 
--     t.ticket_id,
--     t.site_id AS ticket_site,
--     ua.site_id AS creator_site,
--     aa.site_id AS assigned_site
-- FROM TICKET t
-- JOIN USER_ACCOUNT ua ON t.user_id = ua.user_id
-- LEFT JOIN USER_ACCOUNT aa ON t.assigned_to = aa.user_id
-- WHERE NOT (
--     ua.site_id = t.site_id
--     AND (t.assigned_to IS NULL OR aa.site_id = t.site_id)
-- );

-- DELETE FROM TICKET;
-- COMMIT;

DECLARE
  v_ticket_id         TICKET.ticket_id%TYPE;
  v_user_id           TICKET.user_id%TYPE;
  v_site_id           TICKET.site_id%TYPE;
  v_subject           TICKET.subject%TYPE;
  v_description       TICKET.description%TYPE;
  v_status            TICKET.status%TYPE;
  v_priority          TICKET.priority%TYPE;
  v_creation_date     TICKET.creation_date%TYPE;
  v_updated_date      TICKET.updated_date%TYPE;
  v_resolution_date   TICKET.resolution_date%TYPE;
  v_assigned_to       TICKET.assigned_to%TYPE;
  v_updated_by        TICKET.updated_by%TYPE;
  v_rand_status       NUMBER;
  v_role_id           USER_ACCOUNT.role_id%TYPE;
BEGIN
  FOR i IN 1..1500 LOOP
    -- Randomly assign a site_id (1 or 2)
    v_site_id := TRUNC(DBMS_RANDOM.VALUE(1, 3));

    -- Select a random creator (user_id) for the given site
    BEGIN
      SELECT user_id
        INTO v_user_id
        FROM (
          SELECT user_id
            FROM USER_ACCOUNT
            WHERE site_id = v_site_id
            ORDER BY DBMS_RANDOM.VALUE
          )
        WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_user_id := NULL;
    END;

    -- First, determine the creator's role
    BEGIN
      SELECT role_id 
        INTO v_role_id 
        FROM USER_ACCOUNT 
      WHERE user_id = v_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_role_id := NULL;
    END;

    -- If the creator's role is 4, assign the ticket to another user with role_id = 4 
    -- on the same site (v_site_id) and different from the creator.
    IF v_role_id = 4 THEN
      BEGIN
        SELECT user_id 
          INTO v_assigned_to
          FROM (
                SELECT user_id
                  FROM USER_ACCOUNT
                  WHERE role_id = 4
                    AND user_id <> v_user_id
                    AND site_id = v_site_id
                  ORDER BY DBMS_RANDOM.VALUE
              )
        WHERE ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_assigned_to := NULL; -- No alternative user found on the same site
      END;
    ELSE
      -- Otherwise, randomly assign a technician from the same site with a 10% chance to be NULL.
      IF DBMS_RANDOM.VALUE(0,1) < 0.1 THEN
        v_assigned_to := NULL;
      ELSE
        BEGIN
          SELECT user_id
            INTO v_assigned_to
            FROM (
                  SELECT user_id
                    FROM USER_ACCOUNT
                    WHERE site_id = v_site_id
                    ORDER BY DBMS_RANDOM.VALUE
                )
          WHERE ROWNUM = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_assigned_to := NULL;
        END;
      END IF;
    END IF;
    
    -- Generate ticket subject and description
    v_subject := 'Ticket ' || i || ': Hardware Issue';
    v_description := 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' ||
                      'Ticket number ' || i || ': This equipment overheats after a few minutes of use.';

    -- Randomly choose a ticket status ('open', 'pending', or 'closed')
    v_status := CASE TRUNC(DBMS_RANDOM.VALUE(1, 4))
                  WHEN 1 THEN 'open'
                  WHEN 2 THEN 'pending'
                  WHEN 3 THEN 'closed'
                END;

    -- Randomly choose a ticket priority ('low', 'medium', or 'high')
    v_priority := CASE TRUNC(DBMS_RANDOM.VALUE(1, 4))
                    WHEN 1 THEN 'low'
                    WHEN 2 THEN 'medium'
                    WHEN 3 THEN 'high'
                  END;

    -- If ticket priority is 'high' and no technician is assigned,
    -- force an assignment to a technician from the same site (with role_id = 4)
    IF v_priority = 'high' AND v_assigned_to IS NULL THEN
      BEGIN
        SELECT user_id
          INTO v_assigned_to
          FROM (
                SELECT user_id
                  FROM USER_ACCOUNT
                  WHERE site_id = v_site_id
                    AND role_id = 4
                    AND user_id <> v_user_id
                  ORDER BY DBMS_RANDOM.VALUE
                )
          WHERE ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT user_id
              INTO v_assigned_to
              FROM (
                    SELECT user_id
                      FROM USER_ACCOUNT
                      WHERE site_id = v_site_id
                        AND user_id <> v_user_id
                      ORDER BY DBMS_RANDOM.VALUE
                    )
              WHERE ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_assigned_to := NULL;
          END;
      END;
    END IF;

    -- Generate random dates for creation and update
    v_creation_date := DATE '2020-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 1000));
    v_updated_date := v_creation_date + TRUNC(DBMS_RANDOM.VALUE(0, 31));

    -- If status is 'closed', set resolution_date; otherwise, leave it NULL
    IF v_status = 'closed' THEN
      v_resolution_date := v_updated_date + TRUNC(DBMS_RANDOM.VALUE(1, 31));
    ELSE
      v_resolution_date := NULL;
    END IF;

    -- Randomly determine updated_by (either the assigned technician or the creator)
    IF DBMS_RANDOM.VALUE(0,1) < 0.75 THEN
      v_updated_by := v_assigned_to;
    ELSE
      v_updated_by := v_user_id;
    END IF;

    -- Insert the ticket into the TICKET table
    INSERT INTO TICKET (
      user_id, 
      site_id, 
      subject, 
      description, 
      status, 
      priority, 
      creation_date, 
      updated_date, 
      resolution_date, 
      assigned_to, 
      updated_by
    )
    VALUES (
      v_user_id, 
      v_site_id, 
      v_subject, 
      v_description, 
      v_status, 
      v_priority, 
      v_creation_date, 
      v_updated_date, 
      v_resolution_date, 
      v_assigned_to, 
      v_updated_by
    )
    RETURNING ticket_id INTO v_ticket_id;

    -- Output progress every 100 rows inserted
    IF MOD(i, 100) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Inserted ' || i || ' rows into TICKET.');
    END IF;
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('All tickets inserted successfully.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting ticket: ' || SQLERRM);
    RAISE;
END;
/

--------------------------------------------------------------------
-- Insertion dans NETWORK
--------------------------------------------------------------------
-- SELECT * FROM NETWORK;

-- DELETE FROM NETWORK;
-- COMMIT;

BEGIN
  INSERT INTO NETWORK (site_id, name, network_address, netmask, gateway)
  VALUES (1, 'Réseau Cergy', '192.168.1.0', '255.255.255.0', '192.168.1.1');

  INSERT INTO NETWORK (site_id, name, network_address, netmask, gateway)
  VALUES (2, 'Réseau Pau', '192.168.2.0', '255.255.255.0', '192.168.2.1');

  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Networks inserted successfully.');
END;
/


--------------------------------------------------------------------
-- Insertion dans IP_ADDRESS
--------------------------------------------------------------------
--SELECT * FROM IP_ADDRESS;

-- DELETE FROM IP_ADDRESS;
-- COMMIT;

DECLARE
  v_ip_id       IP_ADDRESS.ip_id%TYPE;
  v_network_id  IP_ADDRESS.network_id%TYPE;
  v_asset_id    IP_ADDRESS.asset_id%TYPE;
  v_ip_address  IP_ADDRESS.ip_address%TYPE;
  v_is_dynamic  IP_ADDRESS.is_dynamic%TYPE;
BEGIN
  FOR i IN 1..4000 LOOP
    -- Sélection aléatoire d'un network_id : 1 ou 2
    v_network_id := TRUNC(DBMS_RANDOM.VALUE(1, 3));  -- Retourne 1 ou 2

    -- Définir is_dynamic : 80% statique (0), 20% dynamique (1)
    IF DBMS_RANDOM.VALUE(0,1) < 0.8 THEN
      v_is_dynamic := 0;
    ELSE
      v_is_dynamic := 1;
    END IF;
    
    -- Pour asset_id : 15% de chance de rester NULL, sinon sélectionner un asset_id aléatoire
    -- dont le site (site_id) correspond à v_network_id
    IF DBMS_RANDOM.VALUE(0,1) < 0.15 THEN
      v_asset_id := NULL;
    ELSE
      BEGIN
        SELECT asset_id
          INTO v_asset_id
          FROM (
            SELECT asset_id 
              FROM ASSET
              WHERE site_id = v_network_id
              ORDER BY DBMS_RANDOM.VALUE
            )
          WHERE ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_asset_id := NULL;
      END;
    END IF;
    
    -- Génération d'une adresse IP basée sur le network_id
    IF v_network_id = 1 THEN
      v_ip_address := '192.168.1.' || i;
    ELSIF v_network_id = 2 THEN
      v_ip_address := '192.168.2.' || i;
    ELSE
      -- Cas par défaut (normalement ne doit pas arriver)
      v_ip_address := '192.168.1.' || i;
    END IF;
    
    -- Insertion dans IP_ADDRESS
    INSERT INTO IP_ADDRESS (
      network_id,
      asset_id,
      ip_address,
      is_dynamic,
      created_at,
      updated_at
    )
    VALUES (
      v_network_id,
      v_asset_id,
      v_ip_address,
      v_is_dynamic,
      SYSTIMESTAMP,
      SYSTIMESTAMP
    )
    RETURNING ip_id INTO v_ip_id;
    
    IF MOD(i, 1000) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Inserted ' || i || ' rows into IP_ADDRESS.');
    END IF;
    
  END LOOP;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('All IP addresses inserted successfully.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting IP address: ' || SQLERRM);
    RAISE;
END;
/
