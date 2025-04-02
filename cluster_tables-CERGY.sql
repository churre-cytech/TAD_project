-- COMMAND TO CHECK EXISTANT CLUSTERS
SELECT * 
FROM USER_CLUSTERS;

-- ######################################################################
-- ## DROP EXISTING TABLESPACE (if needed) with its contents and datafiles
-- ######################################################################
DROP TABLESPACE cergy_clusters INCLUDING CONTENTS AND DATAFILES;

-- ######################################################################
-- ## CREATE A NEW TABLESPACE 'cergy_clusters'
-- ## This tablespace will store the cluster data.
-- ######################################################################
CREATE TABLESPACE cergy_clusters
    DATAFILE 'cergy_clusters.dbf' SIZE 100M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

-- ######################################################################
-- ## CREATE THE CLUSTER 'user_asset_cluster'
-- ## The cluster is based on the column "site_id", which is common to the
-- ## USER_ACCOUNT and ASSET tables.
-- ######################################################################
DROP CLUSTER user_asset_cluster_cergy;

CREATE CLUSTER user_asset_cluster_cergy (site_id NUMBER)
    TABLESPACE cergy_clusters
    SIZE 16384;

-- ######################################################################
-- ## CREATE AN INDEX ON THE CLUSTER KEY
-- ## This index is required on the cluster key (site_id) for the cluster to work.
-- ######################################################################
CREATE INDEX idx_cluster_site_id ON CLUSTER user_asset_cluster_cergy;

