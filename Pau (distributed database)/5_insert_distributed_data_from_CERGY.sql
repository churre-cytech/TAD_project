-- ATTENTION : DEPUIS LA BDD Cergy : On donne les données de Cergy à Pau

------------------------------------------------------------------------------
-- RÉPLICATION : SITE
------------------------------------------------------------------------------
-- on supprime les anciennes données s'il y en a
DELETE FROM SITE@pau_link;

-- Réplication des données à l’identique
INSERT INTO SITE@pau_link
SELECT * FROM SITE;

------------------------------------------------------------------------------
-- RÉPLICATION : USER_ROLE
------------------------------------------------------------------------------
-- on supprime les anciennes données s'il y en a
DELETE FROM USER_ROLE@pau_link;

-- Réplication des données à l’identique
INSERT INTO USER_ROLE@pau_link
SELECT * FROM USER_ROLE;

------------------------------------------------------------------------------
-- RÉPLICATION : ASSET_TYPE
------------------------------------------------------------------------------
-- on supprime les anciennes données s'il y en a
DELETE FROM ASSET_TYPE@pau_link;

-- Réplication des données à l’identique
INSERT INTO ASSET_TYPE@pau_link
SELECT * FROM ASSET_TYPE;


------------------------------------------------------------------------------
-- FRAGMENTATION HORIZONTALE : USER_ACCOUNT (Les user de chez Cergy à cergy, les users de chez Pau à Pau)
------------------------------------------------------------------------------
-- on supprime les anciennes données s'il y en a
DELETE FROM USER_ACCOUNT@pau_link;
-- On selectionne toutes les données de chez Cergy où l'utilisateur est à Pau, pour la mettre dans la table de chez Pau
INSERT INTO USER_ACCOUNT@pau_link
SELECT * FROM CY_TECH_CERGY.USER_ACCOUNT
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

------------------------------------------------------------------------------
-- FRAGMENTATION HORIZONTALE : ASSET (Les ASSET de chez Cergy à cergy, les ASSET de chez Pau à Pau)
------------------------------------------------------------------------------
-- on supprime les anciennes données s'il y en a
DELETE FROM ASSET@pau_link;
-- On selectionne toutes les données de chez Cergy où l'utilisateur est à Pau, pour la mettre dans la table de chez Pau
INSERT INTO ASSET@pau_link
SELECT * FROM CY_TECH_CERGY.ASSET
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

-- Pour vérifier qu'un matériel n'est pas sur le même site qu'un utilisateur
-- SELECT ua.user_id,
--        ua.username,
--        ua.site_id     AS user_site_id,
--        a.asset_id,
--        a.name         AS asset_name,
--        a.site_id      AS asset_site_id
-- FROM USER_ACCOUNT ua
-- JOIN ASSET a ON a.assigned_user_id = ua.user_id
-- WHERE ua.site_id <> a.site_id;

------------------------------------------------------------------------------
-- FRAGMENTATION HORIZONTALE : TICKET (Les tickets de chez Cergy à cergy, les tickets de chez Pau à Pau)
------------------------------------------------------------------------------

DELETE FROM TICKET@pau_link;

-- On selectionne toutes les données de chez Cergy où l'utilisateur est à Pau, pour la mettre dans la table de chez Pau
INSERT INTO TICKET@pau_link
SELECT * FROM CY_TECH_CERGY.TICKET
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

-- Pour vérifier qu'un ticket n'est pas sur le même site qu'un user
-- SELECT ua.user_id,
--        ua.username,
--        ua.site_id     AS user_site_id,
--        a.ticket_id,
--        a.site_id      AS ticket_site_id
-- FROM USER_ACCOUNT ua
-- JOIN TICKET a ON a.user_id = ua.user_id
-- WHERE ua.site_id <> a.site_id;

--select * from ticket@pau_link; 



------------------------------------------------------------------------------
-- FRAGMENTATION HORIZONTALE : NETWORK 
------------------------------------------------------------------------------
DELETE FROM NETWORK@pau_link;

INSERT INTO NETWORK@pau_link
SELECT * FROM CY_TECH_CERGY.NETWORK
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

-- select * from NETWORK;


------------------------------------------------------------------------------
-- FRAGMENTATION HORIZONTALE : IP_ADDRESS 
------------------------------------------------------------------------------
DELETE FROM IP_ADDRESS@pau_link;

INSERT INTO IP_ADDRESS@pau_link
SELECT * FROM CY_TECH_CERGY.IP_ADDRESS
WHERE network_id = 2;


------------------------------------------------------------------------------
-- SUPPRESSION DES DONNÉES de Cergy qui ont été ajouté dans Pau,
------------------------------------------------------------------------------
-- On supprime toutes les données de chez Cergy où l'utilisateur est à Pau
DELETE FROM CY_TECH_CERGY.IP_ADDRESS
WHERE network_id = 2;

DELETE FROM CY_TECH_CERGY.NETWORK
WHERE network_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

DELETE FROM CY_TECH_CERGY.TICKET
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

DELETE FROM CY_TECH_CERGY.ASSET
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

DELETE FROM CY_TECH_CERGY.USER_ACCOUNT
WHERE site_id = (SELECT site_id FROM CY_TECH_CERGY.SITE WHERE name = 'Pau');

COMMIT;
--- faire des tests (vérifier que SELECT * FROM USER_ACCOUNT WHERE site_id = 2 est bien nul car tout les élèves ont été déplacés à pau, etc.)

--- faire les vues adaptés (copié le meme code que celui de cergy) + les vues globales (exemple : voir tout les élèves des deux sites, pour les professeur académique)

-- Trouver 1 fragmentation verticale

