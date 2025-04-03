-- Drop the tablespace (if needed) along with its contents and datafiles.
DROP TABLESPACE pau_clusters INCLUDING CONTENTS AND DATAFILES;

-- Create the tablespace for clusters
CREATE TABLESPACE pau_cluster
    DATAFILE 'pau_cluster.dbf' SIZE 100M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;


--------------------------------------------------------------------------------------------
-- Create the cluster for network_id in the existing tablespace pau_cluster
--------------------------------------------------------------------------------------------
CREATE CLUSTER network_cluster_pau (network_id NUMBER)
    TABLESPACE pau_cluster
    SIZE 512;

CREATE INDEX idx_cluster_network_id_pau ON CLUSTER network_cluster_pau;