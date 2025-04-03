------------------------------------------------------------------
-- DROP 
------------------------------------------------------------------
-- Supprimer les synonymes s'ils existent
BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM users_materials_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM pending_ticket_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_student_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM material_to_replace_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM network_usage_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ticket_stats_cergy';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer la vue logique
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW CY_TECH_CERGY.view_state_asset_user';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW CY_TECH_CERGY.view_network_usage';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW CY_TECH_CERGY.view_ticket_statistics';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer les vues matérialisées
BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CY_TECH_CERGY.vm_unresolved_tickets_details';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CY_TECH_CERGY.materialized_view_students_info';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW CY_TECH_CERGY.materialized_view_asset_to_replace';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer le tablespace (avec données associées)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLESPACE ts_matviews_cergy INCLUDING CONTENTS AND DATAFILES';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-----------------------------------------------------------
-- VIEW : Afficher l'état du matériel affecté à chaque utilisateur (POUR TECHNICIEN IT)
-----------------------------------------------------------

CREATE OR REPLACE VIEW CY_TECH_CERGY.view_state_asset_user AS
SELECT 
    u.USER_ID AS user_ID,
    u.FIRST_NAME || ' ' || u.LAST_NAME AS username,
    a.ASSET_ID AS id_asset,
    a.NAME AS name_asset,
    a.STATUS AS state,
    s.NAME AS site
FROM CY_TECH_CERGY.USER_ACCOUNT u
JOIN CY_TECH_CERGY.ASSET a ON a.ASSIGNED_USER_ID = u.USER_ID
JOIN CY_TECH_CERGY.SITE s ON s.SITE_ID = a.SITE_ID;
/
-- Création d'un synonyme
CREATE PUBLIC SYNONYM users_materials_cergy
FOR CY_TECH_CERGY.view_state_asset_user;  

--SELECT * FROM users_materials_cergy;

-----------------------------------------------------------
-- VIEW : Afficher l'utilisation des réseaux par site (POUR ADMIN RÉSEAU)
-----------------------------------------------------------

CREATE OR REPLACE VIEW CY_TECH_CERGY.view_network_usage AS
SELECT 
    n.NETWORK_ID,
    n.NAME AS network_name,
    s.NAME AS site_name,
    n.NETWORK_ADDRESS,
    n.NETMASK,
    COUNT(ip.IP_ID) AS total_ips,
    SUM(CASE WHEN ip.ASSET_ID IS NOT NULL THEN 1 ELSE 0 END) AS used_ips,
    COUNT(ip.IP_ID) - SUM(CASE WHEN ip.ASSET_ID IS NOT NULL THEN 1 ELSE 0 END) AS available_ips,
    ROUND((SUM(CASE WHEN ip.ASSET_ID IS NOT NULL THEN 1 ELSE 0 END) / COUNT(ip.IP_ID)) * 100, 2) AS usage_percentage
FROM CY_TECH_CERGY.NETWORK n
JOIN CY_TECH_CERGY.SITE s ON n.SITE_ID = s.SITE_ID
LEFT JOIN CY_TECH_CERGY.IP_ADDRESS ip ON n.NETWORK_ID = ip.NETWORK_ID
GROUP BY n.NETWORK_ID, n.NAME, s.NAME, n.NETWORK_ADDRESS, n.NETMASK;
/
-- Création d'un synonyme
CREATE PUBLIC SYNONYM network_usage_cergy
FOR CY_TECH_CERGY.view_network_usage;

--SELECT * FROM network_usage_cergy;

-----------------------------------------------------------
-- VIEW : Statistiques sur les tickets (POUR MANAGERS)
-----------------------------------------------------------

CREATE OR REPLACE VIEW CY_TECH_CERGY.view_ticket_statistics AS
SELECT 
    s.NAME AS site_name,
    COUNT(t.TICKET_ID) AS total_tickets,
    SUM(CASE WHEN t.STATUS = 'open' THEN 1 ELSE 0 END) AS open_tickets,
    SUM(CASE WHEN t.STATUS = 'pending' THEN 1 ELSE 0 END) AS pending_tickets,
    SUM(CASE WHEN t.STATUS = 'closed' THEN 1 ELSE 0 END) AS closed_tickets,
    SUM(CASE WHEN t.PRIORITY = 'high' THEN 1 ELSE 0 END) AS high_priority,
    SUM(CASE WHEN t.PRIORITY = 'medium' THEN 1 ELSE 0 END) AS medium_priority,
    SUM(CASE WHEN t.PRIORITY = 'low' THEN 1 ELSE 0 END) AS low_priority,
    ROUND(AVG(CASE WHEN t.STATUS = 'closed' AND t.RESOLUTION_DATE IS NOT NULL 
              THEN t.RESOLUTION_DATE - t.CREATION_DATE 
              ELSE NULL END), 1) AS avg_resolution_time_days
FROM CY_TECH_CERGY.TICKET t
JOIN CY_TECH_CERGY.SITE s ON t.SITE_ID = s.SITE_ID
GROUP BY s.NAME;
/
-- Création d'un synonyme
CREATE PUBLIC SYNONYM ticket_stats_cergy
FOR CY_TECH_CERGY.view_ticket_statistics;

--SELECT * FROM ticket_stats_cergy;

-----------------------------------------------------------
-- CREER UN TABLESPACE QUI VA STOCKÉ LES VUES MATERIALISE
-----------------------------------------------------------

CREATE TABLESPACE ts_matviews_cergy
DATAFILE 'ts_matviews_cergy01.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE 1G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-----------------------------------------------------------
-- MATERIALIZED VIEW : Vue qui permet de voir les tickets non résolus avec infos utilisateur et site (POUR TECHNICIEN)
-- RAFRAICHISSEMENT : A la demande
-----------------------------------------------------------

CREATE MATERIALIZED VIEW CY_TECH_CERGY.vm_unresolved_tickets_details
TABLESPACE ts_matviews_cergy
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    t.TICKET_ID,
    t.SUBJECT,
    t.DESCRIPTION,
    t.PRIORITY,
    t.CREATION_DATE,
    u.FIRST_NAME || ' ' || u.LAST_NAME AS user_full_name,
    u.USERNAME,
    u.EMAIL,
    s.NAME AS site_name
FROM CY_TECH_CERGY.TICKET t
JOIN CY_TECH_CERGY.USER_ACCOUNT u ON t.USER_ID = u.USER_ID
JOIN CY_TECH_CERGY.SITE s ON t.SITE_ID = s.SITE_ID
WHERE t.STATUS != 'pending'
ORDER BY
  CASE t.PRIORITY
    WHEN 'high' THEN 1
    WHEN 'medium' THEN 2
    WHEN 'low' THEN 3
    ELSE 4
  END;
/

-- Création d'un synonyme
CREATE PUBLIC SYNONYM pending_ticket_cergy
FOR CY_TECH_CERGY.vm_unresolved_tickets_details;

--SELECT * FROM pending_ticket_cergy;

-- CODE POUR RAFFRAICHIR LA VUE MATERIEL
BEGIN
  DBMS_MVIEW.REFRESH('CY_TECH_CERGY.VM_UNRESOLVED_TICKETS_DETAILS');
END;
/

-----------------------------------------------------------
-- MATERIALIZED VIEW : Vue qui permet de voir les Etudiants de l'école (POUR ADMIN ACADEMIQUE)
-- RAFRAICHISSEMENT : Après chaque COMMIT
-----------------------------------------------------------

CREATE MATERIALIZED VIEW CY_TECH_CERGY.materialized_view_students_info
TABLESPACE ts_matviews_cergy
BUILD IMMEDIATE
REFRESH ON COMMIT
AS
SELECT 
    u.USER_ID,
    u.FIRST_NAME || ' ' || u.LAST_NAME AS fullname,
    u.USERNAME,
    u.EMAIL
FROM CY_TECH_CERGY.USER_ACCOUNT u
WHERE u.ROLE_ID = 7;  -- "student"
/

-- Création d'un synonyme
CREATE PUBLIC SYNONYM all_student_cergy
FOR CY_TECH_CERGY.materialized_view_students_info;

--SELECT * FROM all_student_cergy;

-----------------------------------------------------------
-- MATERIALIZED VIEW : Vue qui permet au technicien de voir le matériel trop vieux et le matériel à remplacer (POUR TECHNICIEN)
-- RAFRAICHISSEMENT : Intervalle régulier (1 fois par jour)
-----------------------------------------------------------

CREATE MATERIALIZED VIEW CY_TECH_CERGY.materialized_view_asset_to_replace
TABLESPACE ts_matviews_cergy
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH SYSDATE
NEXT SYSDATE + 1
AS
SELECT 
    m.ASSET_ID,
    m.NAME AS asset_name,
    t.SYSTEM_NAME AS asset_type,
    m.PURCHASE_DATE,
    m.STATUS,
    s.NAME AS site_name
FROM CY_TECH_CERGY.ASSET m
JOIN CY_TECH_CERGY.SITE s ON m.SITE_ID = s.SITE_ID
JOIN CY_TECH_CERGY.ASSET_TYPE t ON m.ASSET_TYPE_ID = t.ASSET_TYPE_ID
WHERE m.STATUS = 'maintenance' 
    OR m.PURCHASE_DATE <= ADD_MONTHS(SYSDATE, -48);
/

-- On créer un SYNONYM car le nom de la vue est trop longue...
CREATE PUBLIC SYNONYM material_to_replace_cergy 
FOR CY_TECH_CERGY.materialized_view_asset_to_replace;  

--SELECT * FROM material_to_replace_cergy;

-----------------------------------------------------------
-- ATTRIBUTION DES ROLES 
-----------------------------------------------------------

GRANT SELECT ON CY_TECH_CERGY.view_state_asset_user TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.vm_unresolved_tickets_details TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.materialized_view_asset_to_replace TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.view_network_usage TO ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON CY_TECH_CERGY.view_ticket_statistics TO IT_MANAGER_TECH_CERGY;

GRANT SELECT ON CY_TECH_CERGY.materialized_view_students_info TO ROLE_ACADEMIC_ADMIN_CERGY;

-----------------------------------------------------------
-- ATTRIBUTION DES SYNONYMES
-----------------------------------------------------------

GRANT SELECT ON users_materials_cergy TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON pending_ticket_cergy TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON material_to_replace_cergy TO ROLE_IT_TECH_CERGY;
GRANT SELECT ON network_usage_cergy TO ROLE_NETWORK_TECH_CERGY;
GRANT SELECT ON ticket_stats_cergy TO IT_MANAGER_TECH_CERGY;

GRANT SELECT ON all_student_cergy TO ROLE_ACADEMIC_ADMIN_CERGY; 