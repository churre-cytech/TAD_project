-- ####################################################################################
-- QUERY 1
-- Obtient des statistiques sur les équipements par site et par type
-- ####################################################################################
EXPLAIN PLAN FOR
SELECT 
    s.name AS site_name,
    at.label AS asset_type,
    COUNT(a.asset_id) AS total_assets,
    SUM(CASE WHEN a.status = 'active' THEN 1 ELSE 0 END) AS active_assets,
    SUM(CASE WHEN a.status = 'maintenance' THEN 1 ELSE 0 END) AS maintenance_assets,
    SUM(CASE WHEN a.status = 'decommissioned' THEN 1 ELSE 0 END) AS decommissioned_assets,
    ROUND(AVG(MONTHS_BETWEEN(SYSDATE, a.purchase_date)), 1) AS avg_age_months,
    MIN(a.purchase_date) AS oldest_purchase,
    MAX(a.purchase_date) AS newest_purchase
FROM 
    ASSET a
JOIN 
    ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
JOIN 
    SITE s ON a.site_id = s.site_id
GROUP BY 
    s.name, at.label
ORDER BY 
    s.name, total_assets DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);




-- ####################################################################################
-- QUERY 2
-- Analyse des utilisateurs et des équipements qui leur sont assignés
-- ####################################################################################
EXPLAIN PLAN FOR
SELECT 
    ua.user_id,
    ua.username,
    ua.first_name || ' ' || ua.last_name AS full_name,
    ur.role_name,
    s.name AS site_name,
    COUNT(a.asset_id) AS assigned_assets,
    LISTAGG(at.label || ': ' || a.name, ', ') 
        WITHIN GROUP (ORDER BY at.label) AS asset_details,
    (SELECT COUNT(*) FROM TICKET t WHERE t.user_id = ua.user_id) AS tickets_opened,
    (SELECT COUNT(*) FROM TICKET t WHERE t.assigned_to = ua.user_id) AS tickets_assigned
FROM 
    USER_ACCOUNT ua
JOIN 
    USER_ROLE ur ON ua.role_id = ur.role_id
JOIN 
    SITE s ON ua.site_id = s.site_id
LEFT JOIN 
    ASSET a ON ua.user_id = a.assigned_user_id
LEFT JOIN 
    ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
GROUP BY 
    ua.user_id, ua.username, ua.first_name, ua.last_name, ur.role_name, s.name
ORDER BY 
    s.name, assigned_assets DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ####################################################################################
-- QUERY 3
-- Équipements réseau sans adresse IP
-- ####################################################################################
EXPLAIN PLAN FOR 
WITH networked_assets AS (
    SELECT 
        a.asset_id,
        a.name AS asset_name,
        a.serial,
        at.label AS asset_type,
        s.name AS site_name,
        a.status
    FROM 
        ASSET a
    JOIN 
        ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
    JOIN 
        SITE s ON a.site_id = s.site_id
    WHERE 
        LOWER(at.label) LIKE '%Cisco Router%' OR 
        LOWER(at.label) LIKE '%Juniper EX4300%' OR 
        LOWER(at.label) LIKE '%Netgear ProSAFE%' 
)
SELECT 
    na.*,
    CASE 
        WHEN ip.ip_address IS NULL THEN 'Pas d''IP assignée'
        ELSE ip.ip_address
    END AS ip_address
FROM 
    networked_assets na
LEFT JOIN 
    IP_ADDRESS ip ON na.asset_id = ip.asset_id
WHERE 
    ip.ip_id IS NULL
    AND na.status = 'active'
ORDER BY 
    na.site_name, na.asset_type;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);




-- ####################################################################################
-- QUERY 4
-- Liste des équipements qui nécessitent un renouvellement (> 3 ans d'âge)
-- ####################################################################################
EXPLAIN PLAN FOR
SELECT 
    a.asset_id,
    a.name,
    a.serial,
    at.label AS asset_type,
    s.name AS site_name,
    a.purchase_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, a.purchase_date)/12, 1) AS age_in_years,
    ua.first_name || ' ' || ua.last_name AS assigned_to
FROM 
    ASSET a
JOIN 
    ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
JOIN 
    SITE s ON a.site_id = s.site_id
LEFT JOIN 
    USER_ACCOUNT ua ON a.assigned_user_id = ua.user_id
WHERE 
    a.purchase_date < ADD_MONTHS(SYSDATE, -36)
    AND a.status = 'active'
ORDER BY 
    age_in_years DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ####################################################################################
-- QUERY 5
-- Rapport de planification budgétaire pour le renouvellement des équipements
-- ####################################################################################
EXPLAIN PLAN FOR
WITH asset_age_categories AS (
    SELECT 
        at.label AS asset_type,
        s.name AS site_name,
        CASE 
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 60 THEN 'Urgent (>5 ans)'
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 48 THEN 'Prioritaire (4-5 ans)'
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 36 THEN 'Planifier (3-4 ans)'
            ELSE 'OK (<3 ans)'
        END AS renewal_category,
        COUNT(*) AS equipment_count
    FROM 
        ASSET a
    JOIN 
        ASSET_TYPE at ON a.asset_type_id = at.asset_type_id
    JOIN 
        SITE s ON a.site_id = s.site_id
    WHERE 
        a.status = 'active'
    GROUP BY 
        at.label, s.name,
        CASE 
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 60 THEN 'Urgent (>5 ans)'
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 48 THEN 'Prioritaire (4-5 ans)'
            WHEN MONTHS_BETWEEN(SYSDATE, a.purchase_date) > 36 THEN 'Planifier (3-4 ans)'
            ELSE 'OK (<3 ans)'
        END
)
SELECT 
    site_name,
    asset_type,
    SUM(CASE WHEN renewal_category = 'Urgent (>5 ans)' THEN equipment_count ELSE 0 END) AS urgent_renewal,
    SUM(CASE WHEN renewal_category = 'Prioritaire (4-5 ans)' THEN equipment_count ELSE 0 END) AS priority_renewal,
    SUM(CASE WHEN renewal_category = 'Planifier (3-4 ans)' THEN equipment_count ELSE 0 END) AS plan_renewal,
    SUM(CASE WHEN renewal_category = 'OK (<3 ans)' THEN equipment_count ELSE 0 END) AS no_renewal_needed,
    SUM(equipment_count) AS total_equipment,
    ROUND(SUM(CASE WHEN renewal_category IN ('Urgent (>5 ans)', 'Prioritaire (4-5 ans)') 
               THEN equipment_count ELSE 0 END) * 100.0 / SUM(equipment_count), 1) AS renewal_percentage
FROM 
    asset_age_categories
GROUP BY 
    site_name, asset_type
ORDER BY 
    site_name, renewal_percentage DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ####################################################################################
-- QUERY 6
-- Tableau de bord des tickets en cours
-- ####################################################################################
EXPLAIN PLAN FOR
SELECT 
    t.ticket_id,
    t.subject,
    t.priority,
    t.status,
    s.name AS site,
    creator.first_name || ' ' || creator.last_name AS created_by,
    technician.first_name || ' ' || technician.last_name AS assigned_to,
    ROUND(SYSDATE - t.creation_date) AS age_in_days,
    CASE 
        WHEN t.priority = 'high' AND SYSDATE - t.creation_date > 3 THEN 'Critique'
        WHEN t.priority = 'medium' AND SYSDATE - t.creation_date > 7 THEN 'Attention'
        WHEN t.priority = 'low' AND SYSDATE - t.creation_date > 14 THEN 'À examiner'
        ELSE 'Normal'
    END AS status_alerte
FROM 
    TICKET t
JOIN 
    SITE s ON t.site_id = s.site_id
JOIN 
    USER_ACCOUNT creator ON t.user_id = creator.user_id
LEFT JOIN 
    USER_ACCOUNT technician ON t.assigned_to = technician.user_id
WHERE 
    t.status != 'closed'
ORDER BY 
    CASE t.priority WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END,
    t.creation_date;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



-- ####################################################################################
-- QUERY 7
-- Analyse de l'utilisation des adresses IP
-- ####################################################################################
EXPLAIN PLAN FOR
SELECT 
    n.name AS network_name,
    n.network_address || '/' || n.netmask AS network_cidr,
    s.name AS site_name,
    COUNT(ip.ip_id) AS total_ips,
    SUM(CASE WHEN ip.asset_id IS NOT NULL THEN 1 ELSE 0 END) AS used_ips,
    SUM(CASE WHEN ip.asset_id IS NULL THEN 1 ELSE 0 END) AS available_ips,
    SUM(CASE WHEN ip.is_dynamic = 1 THEN 1 ELSE 0 END) AS dynamic_ips,
    SUM(CASE WHEN ip.is_dynamic = 0 THEN 1 ELSE 0 END) AS static_ips,
    ROUND(SUM(CASE WHEN ip.asset_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(ip.ip_id), 1) AS utilization_percentage,
    CASE 
        WHEN SUM(CASE WHEN ip.asset_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(ip.ip_id) > 90 THEN 'CRITIQUE'
        WHEN SUM(CASE WHEN ip.asset_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(ip.ip_id) > 75 THEN 'ATTENTION'
        ELSE 'OK'
    END AS status
FROM 
    NETWORK n
JOIN 
    SITE s ON n.site_id = s.site_id
LEFT JOIN 
    IP_ADDRESS ip ON n.network_id = ip.network_id
GROUP BY 
    n.name, n.network_address, n.netmask, s.name
ORDER BY 
    utilization_percentage DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
