drop table clientes cascade constraints;
drop table canales cascade constraints;
drop table sucursales cascade constraints;
drop table vendedores cascade constraints;
drop table cobranzas cascade constraints;
drop table servicios cascade constraints;
drop table facturas cascade constraints;


CREATE TABLE canales (
    id_canal     VARCHAR2(3 CHAR) NOT NULL,
    canal_venta  VARCHAR2(300 CHAR) NOT NULL
);

ALTER TABLE canales ADD CONSTRAINT canales_pk PRIMARY KEY ( id_canal );

CREATE TABLE clientes (
    id_cliente   VARCHAR2(5 CHAR) NOT NULL,
    nombre_cl    VARCHAR2(300 CHAR) NOT NULL,
    segmento_cl  VARCHAR2(100 CHAR) NOT NULL,
    contacto_cl  VARCHAR2(50 CHAR) NOT NULL,
    ciudad_cl    VARCHAR2(100 CHAR) NOT NULL,
    pais_cl      VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE clientes ADD CONSTRAINT clientes_pk PRIMARY KEY ( id_cliente );

CREATE TABLE sucursales (
    id_sucursal  VARCHAR2(3 CHAR) NOT NULL,
    sucursal     VARCHAR2(300 CHAR) NOT NULL
);

ALTER TABLE sucursales ADD CONSTRAINT sucursales_pk PRIMARY KEY ( id_sucursal );

CREATE TABLE vendedores (
    id_vendedor  VARCHAR2(3 CHAR) NOT NULL,
    vendedor   VARCHAR2(300 CHAR) NOT NULL
);

ALTER TABLE vendedores ADD CONSTRAINT vendedores_pk PRIMARY KEY ( id_vendedor );

CREATE TABLE facturas (
    id_factura              VARCHAR2(5 CHAR) NOT NULL,
    fecha_factura           DATE NOT NULL,
    vr_antes_iva            NUMBER(8, 2) NOT NULL,
    iva                     NUMBER(4, 2) NOT NULL,
    total_factura           NUMBER(8, 2) NOT NULL,
    fk_clientes             VARCHAR2(5 CHAR) NOT NULL,
    fk_canales              VARCHAR2(3 CHAR) NOT NULL,
    fk_vendedores           VARCHAR2(3 CHAR) NOT NULL
);

ALTER TABLE facturas ADD CONSTRAINT facturas_pk PRIMARY KEY ( id_factura );

ALTER TABLE facturas
    ADD CONSTRAINT facturas_canales_fk FOREIGN KEY ( fk_canales )
        REFERENCES canales ( id_canal );

ALTER TABLE facturas
    ADD CONSTRAINT facturas_clientes_fk FOREIGN KEY ( fk_clientes )
        REFERENCES clientes ( id_cliente );

ALTER TABLE facturas
    ADD CONSTRAINT facturas_vendedores_fk FOREIGN KEY ( fk_vendedores )
        REFERENCES vendedores ( id_vendedor );

CREATE TABLE cobranzas (
    id_cobranza          VARCHAR2(5 CHAR) NOT NULL,
    fecha_cobro          DATE NOT NULL,
    valor_cobrado        NUMBER(8, 2) NOT NULL,
    fk_clientes          VARCHAR2(5 CHAR) NOT NULL,
    fk_facturas          VARCHAR2(5 CHAR) NOT NULL
);
ALTER TABLE cobranzas ADD CONSTRAINT cobranzas_pk PRIMARY KEY ( id_cobranza );
ALTER TABLE cobranzas
    ADD CONSTRAINT cobranzas_clientes_fk FOREIGN KEY ( fk_clientes )
        REFERENCES clientes ( id_cliente );
ALTER TABLE cobranzas
    ADD CONSTRAINT cobranzas_facturas_fk FOREIGN KEY ( fk_facturas)
        REFERENCES facturas ( id_factura );

CREATE TABLE servicios (
    id_servicio             VARCHAR2(5 CHAR) NOT NULL,
    fecha_inicio_serv       DATE NOT NULL,
    fecha_fin_serv          DATE NOT NULL,
    servicio                VARCHAR2(300 CHAR) NOT NULL,
    costo_servicio          NUMBER(6, 2) NOT NULL,
    fk_sucursales           VARCHAR2(3 CHAR) NOT NULL,
    fk_clientes             VARCHAR2(5 CHAR) NOT NULL
);

ALTER TABLE servicios ADD CONSTRAINT servicios_pk PRIMARY KEY ( id_servicio );

ALTER TABLE servicios
    ADD CONSTRAINT servicios_clientes_fk FOREIGN KEY ( fk_clientes )
        REFERENCES clientes ( id_cliente );

ALTER TABLE servicios
    ADD CONSTRAINT servicios_sucursales_fk FOREIGN KEY ( fk_sucursales )
        REFERENCES sucursales ( id_sucursal );

