-- #####################################################################################
-- CREATE CLUSTER BEFORE TABLES CREATION
-- #####################################################################################
-- Drop the tablespace (if needed) along with its contents and datafiles.
DROP TABLESPACE pau_cluster INCLUDING CONTENTS AND DATAFILES;

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



--------------------------------------------------------------------
-- DROP TABLES
--------------------------------------------------------------------
DROP TABLE SITE CASCADE CONSTRAINTS;
DROP TABLE USER_ROLE CASCADE CONSTRAINTS;
DROP TABLE USER_ACCOUNT CASCADE CONSTRAINTS;
DROP TABLE ASSET_TYPE CASCADE CONSTRAINTS;
DROP TABLE ASSET CASCADE CONSTRAINTS;
DROP TABLE NETWORK CASCADE CONSTRAINTS;
DROP TABLE IP_ADDRESS CASCADE CONSTRAINTS;
DROP TABLE TICKET CASCADE CONSTRAINTS;



--------------------------------------------------------------------
-- Création des tables (ATTENTION : Veuillez être connecté dans la base de données de PAU)
-- Table SITE
--------------------------------------------------------------------
CREATE TABLE SITE (
    site_id    NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name       VARCHAR2(50) NOT NULL,
    location   VARCHAR2(100),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_site PRIMARY KEY (site_id)
);


----------------------------------------------------------------------------------------------------------------------------------------
-- USERS AND ROLES MANAGEMENT
----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------
-- Table USER_ROLE
--------------------------------------------------------------------
CREATE TABLE USER_ROLE (
    role_id     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    role_name   VARCHAR2(50) NOT NULL,
    description VARCHAR2(255),
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_role PRIMARY KEY (role_id)
);

--------------------------------------------------------------------
-- Table USER_ACCOUNT
--------------------------------------------------------------------
CREATE TABLE USER_ACCOUNT (
    user_id    NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    username   VARCHAR2(50) NOT NULL,
    password   VARCHAR2(255) NOT NULL,
    first_name VARCHAR2(50),
    last_name  VARCHAR2(50),
    email      VARCHAR2(100),
    phone      VARCHAR2(20),
    site_id    NUMBER NOT NULL,
    role_id    NUMBER,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_user_account PRIMARY KEY (user_id),
    CONSTRAINT uq_username UNIQUE (username),
    CONSTRAINT uq_email UNIQUE (email),
    CONSTRAINT fk_user_site FOREIGN KEY (site_id) REFERENCES SITE(site_id),
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES USER_ROLE(role_id)
);


----------------------------------------------------------------------------------------------------------------------------------------
-- INFORMATION ABOUT HARDWARE ASSETS
----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------
-- Table ASSET_TYPE
--------------------------------------------------------------------
CREATE TABLE ASSET_TYPE (
    asset_type_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    system_name   VARCHAR2(100),
    label         VARCHAR2(100) NOT NULL,
    model_name    VARCHAR2(100),
    is_active     NUMBER(1) DEFAULT 1,     -- 1 = actif, 0 = inactif
    created_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at    TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_asset_type PRIMARY KEY (asset_type_id)
);

--------------------------------------------------------------------
-- Table ASSET
--------------------------------------------------------------------
CREATE TABLE ASSET (
    asset_id         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    asset_type_id    NUMBER NOT NULL,          -- Référence vers ASSET_TYPE
    name             VARCHAR2(100),            -- Nom descriptif
    serial           VARCHAR2(100),            -- Numéro de série
    assigned_user_id NUMBER,                   -- Référence vers USER_ACCOUNT (si applicable)
    site_id          NUMBER NOT NULL,          -- Référence vers SITE (multi-site)
    purchase_date    DATE,                     -- Date d'achat ou d'acquisition
    status           VARCHAR2(20) DEFAULT 'active',  -- ex : active, maintenance, decommissioned
    created_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_asset PRIMARY KEY (asset_id),
    CONSTRAINT uq_asset_serial UNIQUE (serial),
    CONSTRAINT fk_asset_type FOREIGN KEY (asset_type_id) REFERENCES ASSET_TYPE(asset_type_id),
    CONSTRAINT fk_asset_site FOREIGN KEY (site_id) REFERENCES SITE(site_id),
    CONSTRAINT fk_asset_assigned_user FOREIGN KEY (assigned_user_id) REFERENCES USER_ACCOUNT(user_id),
    CONSTRAINT chk_asset_status CHECK (status IN ('active','maintenance','decommissioned'))
);

--------------------------------------------------------------------
-- Table NETWORK
--------------------------------------------------------------------
CREATE TABLE NETWORK (
    network_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    site_id         NUMBER NOT NULL,                   -- Référence vers SITE
    name            VARCHAR2(50) NOT NULL,             -- Nom du réseau (ex. "Réseau Cergy")
    network_address VARCHAR2(50) NOT NULL,             -- Adresse de réseau (ex. "192.168.1.0")
    netmask         VARCHAR2(50) NOT NULL,             -- Masque de sous-réseau (ex. "255.255.255.0")
    gateway         VARCHAR2(50),                      -- Passerelle optionnelle
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_network PRIMARY KEY (network_id),
    CONSTRAINT fk_network_site FOREIGN KEY (site_id) REFERENCES SITE(site_id)
)
CLUSTER network_cluster_pau(network_id);

--------------------------------------------------------------------
-- Table IP_ADDRESS
--------------------------------------------------------------------
CREATE TABLE IP_ADDRESS (
    ip_id       NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    network_id  NUMBER NOT NULL,                     -- Référence vers NETWORK
    asset_id    NUMBER,                              -- Optionnel : référence vers ASSET si assignée
    ip_address  VARCHAR2(50) NOT NULL,               -- Ex. "192.168.1.101"
    is_dynamic  NUMBER(1) DEFAULT 0,                 -- 0 = statique, 1 = dynamique
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_ip_address PRIMARY KEY (ip_id),
    CONSTRAINT fk_ip_network FOREIGN KEY (network_id) REFERENCES NETWORK(network_id),
    CONSTRAINT fk_ip_asset FOREIGN KEY (asset_id) REFERENCES ASSET(asset_id),
    CONSTRAINT uq_network_ip UNIQUE (network_id, ip_address)
)
CLUSTER network_cluster_pau(network_id);

--------------------------------------------------------------------
-- Table TICKET
--------------------------------------------------------------------
CREATE TABLE TICKET (
    ticket_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    user_id        NUMBER NOT NULL,       -- L'utilisateur qui crée le ticket
    site_id        NUMBER NOT NULL,       -- Site concerné
    subject        VARCHAR2(100) NOT NULL,
    description    CLOB,
    status         VARCHAR2(20) DEFAULT 'open',   -- ex : open, pending, closed
    priority       VARCHAR2(20) DEFAULT 'medium', -- ex : low, medium, high
    creation_date  DATE DEFAULT SYSDATE,
    updated_date   DATE DEFAULT SYSDATE,
    resolution_date DATE,                      -- Date de résolution/fermeture du ticket
    assigned_to    NUMBER,                    -- Technicien assigné (référence à USER_ACCOUNT)
    updated_by     NUMBER,                    -- Dernier utilisateur ayant mis à jour le ticket
    CONSTRAINT pk_ticket PRIMARY KEY (ticket_id),
    CONSTRAINT fk_ticket_user FOREIGN KEY (user_id) REFERENCES USER_ACCOUNT(user_id),
    CONSTRAINT fk_ticket_site FOREIGN KEY (site_id) REFERENCES SITE(site_id),
    CONSTRAINT fk_ticket_assigned_to FOREIGN KEY (assigned_to) REFERENCES USER_ACCOUNT(user_id),
    CONSTRAINT chk_ticket_status CHECK (status IN ('open','pending','closed')),
    CONSTRAINT chk_ticket_priority CHECK (priority IN ('low','medium','high'))
);
