------------------------------------------------------------------
-- VUES GLOBALES POUR CY TECH (CERGY + PAU)
------------------------------------------------------------------

------------------------------------------------------------------
-- DROP GLOBAL VIEWS AND SYNONYMS 
------------------------------------------------------------------
-- Supprimer les synonymes s'ils existent
BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_users_materials';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_pending_tickets';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_students';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_materials_to_replace';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_network_usage';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM global_ticket_stats';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer les vues globales s'ils existent
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_STATE_ASSET_USER';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_NETWORK_USAGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_TICKET_STATISTICS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_UNRESOLVED_TICKETS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_STUDENTS_INFO';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW GLOBAL_VIEW_ASSET_TO_REPLACE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer le tablespace (avec données associées)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLESPACE ts_global_views INCLUDING CONTENTS AND DATAFILES';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-----------------------------------------------------------
-- CREER UN TABLESPACE POUR LES VUES GLOBALES
-----------------------------------------------------------

CREATE TABLESPACE ts_global_views
DATAFILE 'ts_global_views01.dbf'
SIZE 200M
AUTOEXTEND ON
NEXT 20M
MAXSIZE 2G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-----------------------------------------------------------
-- VUE GLOBALE : État du matériel affecté à chaque utilisateur (POUR TECHNICIEN IT)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_STATE_ASSET_USER AS
SELECT 
    user_ID,
    username,
    id_asset,
    name_asset,
    state,
    site,
    'CERGY' AS database_source
FROM users_materials_cergy
UNION ALL
SELECT 
    user_ID,
    username,
    id_asset,
    name_asset,
    state,
    site,
    'PAU' AS database_source
FROM users_materials_pau;
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_users_materials
FOR GLOBAL_VIEW_STATE_ASSET_USER;

-----------------------------------------------------------
-- VUE GLOBALE : Utilisation des réseaux (POUR ADMIN RÉSEAU)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_NETWORK_USAGE AS
SELECT 
    NETWORK_ID,
    network_name,
    site_name,
    NETWORK_ADDRESS,
    NETMASK,
    total_ips,
    used_ips,
    available_ips,
    usage_percentage,
    'CERGY' AS database_source
FROM network_usage_cergy
UNION ALL
SELECT 
    NETWORK_ID,
    network_name,
    site_name,
    NETWORK_ADDRESS,
    NETMASK,
    total_ips,
    used_ips,
    available_ips,
    usage_percentage,
    'PAU' AS database_source
FROM network_usage_pau;
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_network_usage
FOR GLOBAL_VIEW_NETWORK_USAGE;

-----------------------------------------------------------
-- VUE GLOBALE : Statistiques des tickets (POUR MANAGERS)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_TICKET_STATISTICS AS
-- Vue consolidée des deux sites
SELECT 
    site_name,
    total_tickets,
    open_tickets,
    pending_tickets,
    closed_tickets,
    high_priority,
    medium_priority,
    low_priority,
    avg_resolution_time_days,
    'CERGY' AS database_source
FROM ticket_stats_cergy
UNION ALL
SELECT 
    site_name,
    total_tickets,
    open_tickets,
    pending_tickets,
    closed_tickets,
    high_priority,
    medium_priority,
    low_priority,
    avg_resolution_time_days,
    'PAU' AS database_source
FROM ticket_stats_pau
UNION ALL
-- Ajout d'une vue totale pour l'ensemble du groupe CY TECH
SELECT 
    'TOTAL CY TECH' AS site_name,
    SUM(total_tickets) AS total_tickets,
    SUM(open_tickets) AS open_tickets,
    SUM(pending_tickets) AS pending_tickets,
    SUM(closed_tickets) AS closed_tickets,
    SUM(high_priority) AS high_priority,
    SUM(medium_priority) AS medium_priority,
    SUM(low_priority) AS low_priority,
    ROUND(AVG(avg_resolution_time_days), 1) AS avg_resolution_time_days,
    'GLOBAL' AS database_source
FROM (
    SELECT * FROM ticket_stats_cergy
    UNION ALL
    SELECT * FROM ticket_stats_pau
);
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_ticket_stats
FOR GLOBAL_VIEW_TICKET_STATISTICS;

-----------------------------------------------------------
-- VUE GLOBALE : Tickets non résolus (POUR TECHNICIEN)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_UNRESOLVED_TICKETS AS
SELECT 
    TICKET_ID,
    SUBJECT,
    DESCRIPTION,
    PRIORITY,
    CREATION_DATE,
    user_full_name,
    USERNAME,
    EMAIL,
    site_name,
    'CERGY' AS database_source
FROM pending_ticket_cergy
UNION ALL
SELECT 
    TICKET_ID,
    SUBJECT,
    DESCRIPTION,
    PRIORITY,
    CREATION_DATE,
    user_full_name,
    USERNAME,
    EMAIL,
    site_name,
    'PAU' AS database_source
FROM pending_ticket_pau;
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_pending_tickets
FOR GLOBAL_VIEW_UNRESOLVED_TICKETS;

-----------------------------------------------------------
-- VUE GLOBALE : Liste des étudiants (POUR ADMIN ACADÉMIQUE)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_STUDENTS_INFO AS
SELECT 
    USER_ID,
    fullname,
    USERNAME,
    EMAIL,
    'CERGY' AS database_source
FROM all_student_cergy
UNION ALL
SELECT 
    USER_ID,
    fullname,
    USERNAME,
    EMAIL,
    'PAU' AS database_source
FROM all_student_pau;
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_students
FOR GLOBAL_VIEW_STUDENTS_INFO;

-----------------------------------------------------------
-- VUE GLOBALE : Matériel à remplacer (POUR TECHNICIEN)
-----------------------------------------------------------

CREATE OR REPLACE VIEW GLOBAL_VIEW_ASSET_TO_REPLACE AS
SELECT 
    ASSET_ID,
    asset_name AS NAME,
    asset_type AS TYPE_NAME,
    PURCHASE_DATE,
    ROUND(MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE)/12, 1) AS AGE_IN_YEARS,
    STATUS,
    CASE 
        WHEN STATUS = 'maintenance' THEN 'High'
        WHEN MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE) > 60 THEN 'High'
        WHEN MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE) > 48 THEN 'Medium'
        ELSE 'Low'
    END AS REPLACEMENT_PRIORITY,
    site_name AS SITE_NAME,
    'CERGY' AS database_source
FROM material_to_replace_cergy
UNION ALL
SELECT 
    ASSET_ID,
    asset_name AS NAME,
    asset_type AS TYPE_NAME,
    PURCHASE_DATE,
    ROUND(MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE)/12, 1) AS AGE_IN_YEARS,
    STATUS,
    CASE 
        WHEN STATUS = 'maintenance' THEN 'High'
        WHEN MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE) > 60 THEN 'High'
        WHEN MONTHS_BETWEEN(SYSDATE, PURCHASE_DATE) > 48 THEN 'Medium'
        ELSE 'Low'
    END AS REPLACEMENT_PRIORITY,
    site_name AS SITE_NAME,
    'PAU' AS database_source
FROM material_to_replace_pau;
/

-- Création d'un synonyme global
CREATE PUBLIC SYNONYM global_materials_to_replace
FOR GLOBAL_VIEW_ASSET_TO_REPLACE;

-----------------------------------------------------------
-- COMMANDES POUR TESTER LES VUES GLOBALES
-----------------------------------------------------------

-- Afficher les états du matériel pour tous les sites
-- SELECT * FROM global_users_materials;

-- Afficher l'utilisation des réseaux pour tous les sites
-- SELECT * FROM global_network_usage;

-- Afficher les statistiques des tickets pour tous les sites
-- SELECT * FROM global_ticket_stats;

-- Afficher les tickets non résolus pour tous les sites
-- SELECT * FROM global_pending_tickets;

-- Afficher tous les étudiants de l'école
-- SELECT * FROM global_students;

-- Afficher tout le matériel à remplacer
-- SELECT * FROM global_materials_to_replace;
