------------------------------------------------------------------------------
-- Cluster pour regrouper NETWORK et IP_ADDRESS par network_id
------------------------------------------------------------------------------
CREATE CLUSTER ip_network_cluster (network_id NUMBER)
    SIZE 1024                -- Ajustez la taille en fonction de la taille moyenne des enregistrements
    TABLESPACE cergy_indexes;

-- Création de l'index associé au cluster
CREATE INDEX idx_ip_network_cluster
    ON CLUSTER ip_network_cluster
    TABLESPACE cergy_indexes;


------------------------------------------------------------------------------
-- Cluster pour regrouper les tables liées aux tickets par user_id
------------------------------------------------------------------------------
CREATE CLUSTER user_ticket_cluster (user_id NUMBER)
    SIZE 1024                -- Ajustez la taille en fonction de la taille moyenne des enregistrements
    TABLESPACE cergy_indexes;

-- Création de l'index associé au cluster
CREATE INDEX idx_user_ticket_cluster
    ON CLUSTER user_ticket_cluster
    TABLESPACE cergy_indexes;


------------------------------------------------------------------------------
-- Cluster pour regrouper les tables liées aux assets par user_id
------------------------------------------------------------------------------
CREATE CLUSTER user_asset_cluster (user_id NUMBER)
    SIZE 1024                -- Ajustez la taille en fonction de la taille moyenne des enregistrements
    TABLESPACE cergy_indexes;

-- Création de l'index associé au cluster
CREATE INDEX idx_user_asset_cluster
    ON CLUSTER user_asset_cluster
    TABLESPACE cergy_indexes;
