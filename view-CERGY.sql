------------------------------------------------------------------
-- DROP 
------------------------------------------------------------------
-- Supprimer les synonymes s'ils existent
BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM users_materials';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM pending_ticket';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_student';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM material_to_replace';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer la vue logique
BEGIN
  EXECUTE IMMEDIATE 'DROP VIEW C##CY_TECH_CERGY.view_state_asset_user';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Supprimer les vues matérialisées
BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW C##CY_TECH_CERGY.vm_unresolved_tickets_details';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_students_info';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_asset_to_replace';
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
-- VIEW : Afficher l’état du matériel affecté à chaque utilisateur (POUR TECHNICIEN)
-----------------------------------------------------------

CREATE OR REPLACE VIEW C##CY_TECH_CERGY.view_state_asset_user AS
SELECT 
    u.USER_ID AS id_utilisateur,
    u.FIRST_NAME || ' ' || u.LAST_NAME AS username,
    a.ASSET_ID AS id_materiel,
    a.NAME AS nom_materiel,
    a.STATUS AS etat,
    s.NAME AS site
FROM C##CY_TECH_CERGY.USER_ACCOUNT u
JOIN C##CY_TECH_CERGY.ASSET a ON a.ASSIGNED_USER_ID = u.USER_ID
JOIN C##CY_TECH_CERGY.SITE s ON s.SITE_ID = a.SITE_ID;
/
-- Création d'un synonyme
--DROP PUBLIC SYNONYM users_materials;
CREATE PUBLIC SYNONYM users_materials
FOR C##CY_TECH_CERGY.view_state_asset_user;  

--SELECT * FROM users_materials;

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
--DROP MATERIALIZED VIEW C##CY_TECH_CERGY.vm_unresolved_tickets_details;

CREATE MATERIALIZED VIEW C##CY_TECH_CERGY.vm_unresolved_tickets_details
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
FROM C##CY_TECH_CERGY.TICKET t
JOIN C##CY_TECH_CERGY.USER_ACCOUNT u ON t.USER_ID = u.USER_ID
JOIN C##CY_TECH_CERGY.SITE s ON t.SITE_ID = s.SITE_ID
WHERE t.STATUS != 'pending'
ORDER BY
  CASE t.PRIORITY
    WHEN 'high' THEN 1
    WHEN 'medium' THEN 2
    WHEN 'low' THEN 3
    ELSE 4
  END;
/
--SELECT * from ticket;

-- Création d'un synonyme
CREATE PUBLIC SYNONYM pending_ticket
FOR C##CY_TECH_CERGY.vm_unresolved_tickets_details;

--SELECT * FROM pending_ticket;

-- CODE POUR RAFFRAICHIR LA VUE MATERIEL
BEGIN
  DBMS_MVIEW.REFRESH('C##CY_TECH_CERGY.VM_UNRESOLVED_TICKETS_DETAILS');
END;
/

-----------------------------------------------------------
-- MATERIALIZED VIEW : Vue qui permet de voir les Etudiants de l'école (POUR ADMIN ACADEMIQUE)
-- RAFRAICHISSEMENT : Après chaque COMMIT
-----------------------------------------------------------
--DROP MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_students_info;

CREATE MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_students_info
TABLESPACE ts_matviews_cergy
BUILD IMMEDIATE
REFRESH ON COMMIT
AS
SELECT 
    u.USER_ID,
    u.FIRST_NAME || ' ' || u.LAST_NAME AS fullname,
    u.USERNAME,
    u.EMAIL
FROM C##CY_TECH_CERGY.USER_ACCOUNT u
WHERE u.ROLE_ID = 7;  -- "student"
/

-- Création d'un synonyme
CREATE PUBLIC SYNONYM all_student
FOR C##CY_TECH_CERGY.materialized_view_students_info;

--SELECT * FROM all_student;

-----------------------------------------------------------
-- MATERIALIZED VIEW : Vue qui permet au technicien de voir le matériel trop vieux et le matériel à remplacer (POUR TECHNICIEN)
-- RAFRAICHISSEMENT : Intervalle régulier (1 fois par jour)
-----------------------------------------------------------

--DROP MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_asset_to_replace;

CREATE MATERIALIZED VIEW C##CY_TECH_CERGY.materialized_view_asset_to_replace
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
FROM C##CY_TECH_CERGY.ASSET m
JOIN C##CY_TECH_CERGY.SITE s ON m.SITE_ID = s.SITE_ID
JOIN C##CY_TECH_CERGY.ASSET_TYPE t ON m.ASSET_TYPE_ID = t.ASSET_TYPE_ID
WHERE m.STATUS = 'maintenance' 
   OR m.PURCHASE_DATE <= ADD_MONTHS(SYSDATE, -48);
/

-- On créer un SYNONYM car le nom de la vue est trop longue...
--DROP PUBLIC SYNONYM material_to_replace ;
CREATE PUBLIC SYNONYM material_to_replace 
FOR C##CY_TECH_CERGY.materialized_view_asset_to_replace;  

--SELECT * FROM material_to_replace;

--select * from user_role;


-----------------------------------------------------------
-- ATTRIBUTION DES ROLES 
-----------------------------------------------------------

GRANT SELECT ON C##CY_TECH_CERGY.view_state_asset_user TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.vm_unresolved_tickets_details TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON C##CY_TECH_CERGY.materialized_view_asset_to_replace TO C##ROLE_IT_TECH_CERGY;

GRANT SELECT ON C##CY_TECH_CERGY.materialized_view_students_info TO C##ROLE_ACADEMIC_ADMIN_CERGY;

-----------------------------------------------------------
-- ATTRIBUTION DES SYNONYMES
-----------------------------------------------------------

GRANT SELECT ON users_materials TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON pending_ticket TO C##ROLE_IT_TECH_CERGY;
GRANT SELECT ON material_to_replace TO C##ROLE_IT_TECH_CERGY;

GRANT SELECT ON all_student TO C##ROLE_ACADEMIC_ADMIN_CERGY;
