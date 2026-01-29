USE master;
GO

-- 1. Forzar cierre de conexiones y borrar si existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SistemaHotelero')
BEGIN
    ALTER DATABASE SistemaHotelero SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SistemaHotelero;
END
GO

CREATE DATABASE SistemaHotelero
GO

/*
    Tabla tipos de hoteles (hotel,hostal,casa,departamente,etc)
*/
USE SistemaHotelero
GO

CREATE TABLE Usuario (
    UsuarioID INT IDENTITY,
    NombreUsuario VARCHAR(32) NOT NULL,
    Contrasena VARCHAR(32) NOT NULL,
    TipoUsuario VARCHAR(16) NOT NULL,

    --Restricciones
    CONSTRAINT PK_UsuarioID PRIMARY KEY (UsuarioID),
    CONSTRAINT CHK_ContrasenaUsuario CHECK (LEN(Contrasena) >= 8 AND Contrasena NOT LIKE '%[^A-Za-z0-9]%'),
    Constraint CHK_TipoUsuario CHECK 
    (TipoUsuario = 'EmpresaRecreativa' OR TipoUsuario = 'EmpresaHotelera' OR TipoUsuario = 'Cliente')
);


CREATE TABLE TiposHoteles (
    TipoHotelID INT IDENTITY,
    Nombre VARCHAR (128) NOT NULL UNIQUE,
    -- Restriciones
    CONSTRAINT PK_TipoHotel PRIMARY KEY (TipoHotelID)
);

/*
    Tabla de tipos de redes sociales (X,FB,IG,etc)
*/
CREATE TABLE RedesSociales (
    RedSocialID INT NOT NULL IDENTITY,
    Nombre VARCHAR(64) UNIQUE,

    --Restricciones
    CONSTRAINT PK_RedSocial PRIMARY KEY (RedSocialID) 
);

/*
    Tabla de tipos de servicios (Wifi,piscina,parqueo,restaurante,etc)
*/

CREATE TABLE Servicios (
    ServicioID INT NOT NULL IDENTITY,
    Nombre VARCHAR(64) UNIQUE,

    --Restricciones
    CONSTRAINT PK_Servicio PRIMARY KEY (ServicioID) 
);



CREATE TABLE EmpresasHoteleras (
    UsuarioID INT NOT NULL,
    EmpresaID INT IDENTITY NOT NULL,
    CedulaJuridica VARCHAR(64) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,
    Tipo INT NOT NULL,
    CorreoElectronico VARCHAR(256) UNIQUE NOT NULL,
    -- Dirección (Atributo Compuesto Expandido)
    Canton VARCHAR(64) NOT NULL,
    Distrito VARCHAR(64) NOT NULL,
    Barrio VARCHAR(64) NOT NULL,
    OtrasSenas VARCHAR(MAX) NOT NULL,
    -- Restriciones
    CONSTRAINT PK_EmpresaHotelera PRIMARY KEY (EmpresaID),
    CONSTRAINT FK_Tipo_Empresa FOREIGN KEY (Tipo) REFERENCES TiposHoteles(TipoHotelID),
    CONSTRAINT FK_UsuarioHotelero FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID),

    CONSTRAINT CHK_JuridicaHotelera CHECK (CedulaJuridica LIKE '3-1[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]' and LEN(CedulaJuridica) = 12),
    CONSTRAINT CHK_Correo_Hotelera CHECK (CorreoElectronico LIKE '%@%.%')
);
--AQUI FALTAN LOS ATRIBUTOS MULTIVALORADOS Y TIPO,
--UNA OPCION ES HACER OTRAS TABLAS PERO YA VEREMOS


--TABLAS DE ATRIBUTOS MULTIVALORADOS

/*
    AQUI VA LA TABLA DE URLS
*/
CREATE TABLE DireccionesElectronicasEmpresa (
    URL_ID INT NOT NULL IDENTITY,
    EmpresaID INT NOT NULL,
    URL_Empresa VARCHAR(128) NOT NULL,

    --Restricciones
    CONSTRAINT PK_URL PRIMARY KEY (URL_ID),
    CONSTRAINT FK_URL_Empresa FOREIGN KEY (EmpresaID) REFERENCES EmpresasHoteleras(EmpresaID),
    CONSTRAINT UQ_URL_EMPRESA UNIQUE (URL_EMPRESA)
);


/*
    TABLA DEl puente de tipos de REDES SOCIALES y dicha empresa
*/
CREATE TABLE RedesSocialesEmpresa (
    EmpresaID INT NOT NULL,
    RedSocialID INT NOT NULL,
    Red_URL VARCHAR(256) NOT NULL,

    --Restricciones
    CONSTRAINT PK_Empresa_Redes PRIMARY KEY (EmpresaID,RedSocialID),
    CONSTRAINT FK_RedSocial_Empresa FOREIGN KEY (EmpresaID) REFERENCES EmpresasHoteleras(EmpresaID),
    CONSTRAINT FK_RedSocialID FOREIGN KEY (RedSocialID) REFERENCES RedesSociales(RedSocialID)
);



/*
    TABLA DEL PUENTE ENTRE TIPOS DE SERVICIOS Y DICHA EMPRESA
*/

CREATE TABLE ServiciosHotel (
    EmpresaID INT NOT NULL,
    ServicioID INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Empresa_ServiciosHoteleros PRIMARY KEY (EmpresaID,ServicioID),
    CONSTRAINT FK_Servicios_Empresa FOREIGN KEY (EmpresaID) REFERENCES EmpresasHoteleras(EmpresaID),
    CONSTRAINT FK_Servicio_Hotel FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID)
);


/*
    AQUI VA LA TABLA DE TELEFONOS
*/
CREATE TABLE TelefonoEmpresa (
    TelefonoID INT NOT NULL IDENTITY,
    EmpresaID INT NOT NULL,
    TelefonoNum INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Telefono PRIMARY KEY (TelefonoID),
    CONSTRAINT FK_Telefono_Empresa FOREIGN KEY (EmpresaID) REFERENCES EmpresasHoteleras(EmpresaID),
    CONSTRAINT UQ_Telefono_Num UNIQUE (TelefonoNum),

    --Formato: +560 [2000 0000 - 9999 9999]
    CONSTRAINT CHK_TelefonoHotelera CHECK (TelefonoNum BETWEEN 56020000000 and 56099999999)
);



--Comienza entidad Habitacion **

CREATE TABLE TiposHabitaciones(
    TipoHabitacionID INT IDENTITY,
    Nombre VARCHAR (128) NOT NULL UNIQUE,
    -- Restriciones
    CONSTRAINT PK_TipoHabitacion PRIMARY KEY (TipoHabitacionID)
);


CREATE TABLE TiposCamas(
    TipoCamaID INT IDENTITY,
    Nombre VARCHAR (128) NOT NULL UNIQUE,
    -- Restriciones
    CONSTRAINT PK_TipoCama PRIMARY KEY (TipoCamaID)
);

CREATE TABLE TiposComodidades (
    TipoComodidadID INT IDENTITY,
    Nombre VARCHAR (128) NOT NULL UNIQUE,
    -- Restriciones
    CONSTRAINT PK_TipoComodidad PRIMARY KEY (TipoComodidadID)
);



CREATE TABLE Habitaciones(
    EmpresaID INT NOT NULL,
    NumeroHabitacion INT NOT NULL,
    TipoHabitacionID INT NOT NULL,

    Precio DECIMAL(10, 2) NOT NULL,
    Estado VARCHAR(32) DEFAULT 'Activo' NOT NULL,
    Nombre VARCHAR(128) NOT NULL,
    Descripcion VARCHAR(256) NOT NULL,

    -- Restriciones
    CONSTRAINT PK_Habitacion PRIMARY KEY (EmpresaID,NumeroHabitacion),
    CONSTRAINT FK_TipoID FOREIGN KEY (TipoHabitacionID) REFERENCES TiposHabitaciones(TipoHabitacionID),
    CONSTRAINT FK_Habitacion_Empresa FOREIGN KEY (EmpresaID) REFERENCES EmpresasHoteleras(EmpresaID),

    CONSTRAINT CHK_PrecioHabitacion CHECK (Precio > 0),
    CONSTRAINT CHK_EstadoHabitacion CHECK (Estado = 'Activo' OR ESTADO = 'Inactivo')
);


/*
    TABLA DE CONEXION HABITACIONES - TIPOS DE CAMAS (Relacion M:N)?? 
*/

CREATE TABLE CamasHabitaciones (
    EmpresaID INT NOT NULL,
    NumeroHabitacion INT NOT NULL,
    CamaID INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Camas_Habitaciones PRIMARY KEY (EmpresaID,NumeroHabitacion,CamaID),
    CONSTRAINT FK_Camas_Habitacion FOREIGN KEY (EmpresaID,NumeroHabitacion) REFERENCES Habitaciones(EmpresaID,NumeroHabitacion),
    CONSTRAINT FK_CamaID FOREIGN KEY (CamaID) REFERENCES TiposCamas(TipoCamaID)
);



/*
    TABLA DE CONEXION HABITACIONES - TIPOS DE COMODIDADES (Relacion M:N)?? 
    **REVISAR
*/  
CREATE TABLE Habitacion_Comodidades (
    EmpresaID INT NOT NULL,
    NumeroHabitacion INT NOT NULL,
    ComodidadID INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Habitacion_Comodidades PRIMARY KEY (EmpresaID,NumeroHabitacion, ComodidadID),
    CONSTRAINT FK_Comodidades_Habitacion FOREIGN KEY (EmpresaID,NumeroHabitacion) REFERENCES Habitaciones(EmpresaID,NumeroHabitacion),
    CONSTRAINT FK_ComodidadID FOREIGN KEY (ComodidadID) REFERENCES TiposComodidades(TipoComodidadID)
);


/*
    AQUI VA LA TABLA DE FOTOS
*/
CREATE TABLE FotosHabitacion (
    FotoID INT NOT NULL IDENTITY,
    EmpresaID INT NOT NULL,
    NumeroHabitacion INT NOT NULL,
    Foto VARCHAR(16) NOT NULL,

    --Restricciones
    CONSTRAINT PK_Foto PRIMARY KEY (FotoID),
    CONSTRAINT FK_Fotos_Habitacion FOREIGN KEY (EmpresaID,NumeroHabitacion) REFERENCES Habitaciones(EmpresaID,NumeroHabitacion),

    --Formato: Se valida extension y que al menos tenga un caracter aparte de los 4 de extension
    CONSTRAINT CHK_Foto CHECK (LEN(Foto) > 4 AND (Foto LIKE '%.jpg' OR Foto LIKE '%.jpeg' OR Foto LIKE '%.png'))
);


--Comienza entidad cliente

CREATE TABLE Cliente (
    UsuarioID INT NOT NULL,
    ClienteID INT IDENTITY NOT NULL,
    TipoIdentificacion VARCHAR(32) NOT NULL,
    Identificacion VARCHAR(64) NOT NULL,

    FechaNacimiento DATE, -- formato: YYYY-MM-DD
    PaisResidencia VARCHAR(64),
    CorreoElectronico VARCHAR(164) UNIQUE,

    --Nombre completo
    Nombre VARCHAR(64) NOT NULL,
    PrimerApellido VARCHAR(64) NOT NULL,
    SegundoApellido VARCHAR(64),

    -- Dirección
    Provincia VARCHAR(64) NOT NULL,
    Canton VARCHAR(64) NOT NULL,
    Distrito VARCHAR(64) NOT NULL,

    -- Restriciones
    CONSTRAINT PK_Cliente PRIMARY KEY (ClienteID),
    CONSTRAINT UQ_Cliente_ID UNIQUE (Identificacion),

    --Fecha entre 1990 y la fecha de hoy (Evitar fechas futuras)
    CONSTRAINT CHK_NacimientoClient CHECK (FechaNacimiento BETWEEN '1900-01-01' AND GETDATE()),

    CONSTRAINT FK_UsuarioCliente FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID),

    CONSTRAINT CHK_TipoIdentificacion
        CHECK (TipoIdentificacion IN ('CEDULA', 'DIMEX', 'PASAPORTE','LicenciaDeConducir')),

    CONSTRAINT CHK_IdentificacionCliente CHECK (
    CASE 
        -- Cédula física (9 dígitos)
        WHEN TipoIdentificacion = 'CEDULA'
             AND Identificacion NOT LIKE '%[^0-9]%' 
             AND LEN(Identificacion) = 9 THEN 1
        
        -- Pasaporte (alfanumérico 6–15)
        WHEN TipoIdentificacion = 'PASAPORTE'
             AND Identificacion NOT LIKE '%[^A-Za-z0-9]%' 
             AND LEN(Identificacion) BETWEEN 6 AND 15 THEN 1
        
        -- DIMEX (11–12 dígitos)
        WHEN TipoIdentificacion = 'DIMEX'
             AND Identificacion NOT LIKE '%[^0-9]%' 
             AND LEN(Identificacion) BETWEEN 11 AND 12 THEN 1
        
        -- Licencia de conducir (9 alfanuméricos)
        WHEN TipoIdentificacion = 'LicenciaDeConducir'
             AND Identificacion NOT LIKE '%[^A-Za-z0-9]%' 
             AND LEN(Identificacion) = 9 THEN 1

        ELSE 0
        END = 1
     )        
);

CREATE TABLE Cliente_Telefonos (
    ClienteID INT NOT NULL,
    Telefono VARCHAR(32) NOT NULL,
    -- Restriciones
    CONSTRAINT PK_Cliente_Telefonos PRIMARY KEY (ClienteID, Telefono),
    CONSTRAINT FK_Telefonos_Cliente FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),

    
    --Formato: +[Caracteres Numericos] y de un largo entre 7 y 15 digitos
    CONSTRAINT CHK_TelefonoCliente CHECK (Telefono LIKE '+[0-9]%' AND LEN(Telefono) BETWEEN 7 and 15)
);



--Comienza entidad Reserva

CREATE TABLE Reserva (

    ReservaID INT IDENTITY,
    ClienteID INT NOT NULL,
    EmpresaID INT NOT NULL,
    NumeroHabitacion INT NOT NULL,

    --Aqui se podria usar DATETIME, pero lo separe porque asi esta en el diagrama
    FechaEntrada DATE NOT NULL, -- formato: YYYY-MM-DD 
    HoraEntrada TIME DEFAULT '14:00:00' NOT NULL,  -- formato: HH:MM:SS
    CantPersonas INT DEFAULT 1 NOT NULL,
    PoseeVehiculo BIT DEFAULT 0 NOT NULL,
    NumeroDeNoches INT NOT NULL,
    EstadoReserva VARCHAR(16) NOT NULL DEFAULT 'ACTIVO'


    -- Restriciones
    CONSTRAINT PK_Reserva PRIMARY KEY (ReservaID),
    CONSTRAINT FK_Reserva_Cliente FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
    CONSTRAINT FK_Reserva_Habitacion FOREIGN KEY (EmpresaID,NumeroHabitacion) REFERENCES Habitaciones(EmpresaID,NumeroHabitacion),

    CONSTRAINT CHK_CantPersonasReserva CHECK (CantPersonas >= 1),
    CONSTRAINT CHK_CantNochesReserva CHECK (NumeroDeNoches >= 1),
    CONSTRAINT CHL_PoseeVehiculo CHECK (PoseeVehiculo = 1 OR PoseeVehiculo = 0),
    --GETDATE() da la fecha y hora del sistema, el convert toma solo el atributo DATE
    CONSTRAINT CHK_FechaReserva CHECK (FechaEntrada > CONVERT(DATE,GETDATE())),
    CONSTRAINT CHK_EstadoReserva CHECK(EstadoReserva = 'ACTIVO' OR EstadoReserva = 'CERRADO')
);



-- AQUI VA LA FACTURA
CREATE TABLE Factura (
    FacturaID INT IDENTITY,
    ReservaID INT NOT NULL,
    NumeroDeFactura INT NOT NULL,

    FormatoDePago VARCHAR(32) NOT NULL,
    FechaFacturacion DATETIME DEFAULT GETDATE() NOT NULL,


    CargosAdicionales INT DEFAULT 0 NOT NULL,

    --Restricciones
    CONSTRAINT PK_Factura PRIMARY KEY (FacturaID),
    CONSTRAINT UQ_NumeroDeFactura UNIQUE (NumeroDeFactura),

    CONSTRAINT FK_Facturacion_Reserva FOREIGN KEY (ReservaID) REFERENCES Reserva(ReservaID),
    CONSTRAINT CHK_FormaPago CHECK (FormatoDePago = 'Efectivo' OR FormatoDePago = 'SinpeMovil' OR FormatoDePago = 'Tarjeta'),
    CONSTRAINT CHK_CargosAdicionales CHECK (CargosAdicionales >= 0)
);


/*
    -- AQUI VA LA RECREATIVA
*/

CREATE TABLE TipoActividad (
    ActividadID INT NOT NULL IDENTITY,
    Nombre VARCHAR(64) NOT NULL UNIQUE,
    Descripcion VARCHAR(128) NOT NULL,

    --Restricciones
    CONSTRAINT PK_Actividad PRIMARY KEY (ActividadID) 
);

CREATE TABLE EmpresasRecreativas (
    UsuarioID INT NOT NULL,
    EmpresaID INT IDENTITY NOT NULL,
    CedulaJuridica VARCHAR(64) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,

    --Contacto
    CorreoElectronico VARCHAR(256) NOT NULL UNIQUE,
    Telefono INT UNIQUE NOT NULL,
    NombreContacto VARCHAR(64) NOT NULL,

    -- Dirección (Atributo Compuesto Expandido)
    Canton VARCHAR(64) NOT NULL,
    Distrito VARCHAR(64) NOT NULL,
    OtrasSenas VARCHAR(MAX) NOT NULL,

    -- Restriciones
    CONSTRAINT PK_EmpresaRecreativa PRIMARY KEY (EmpresaID),
    CONSTRAINT CHK_Correo_Recreativa CHECK (CorreoElectronico LIKE '%@%.%'),
    CONSTRAINT CHK_JuridicaRecreativa CHECK (CedulaJuridica LIKE '3-1[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]' and LEN(CedulaJuridica) = 12),
    CONSTRAINT CHK_TelefonoRecreativa CHECK (Telefono BETWEEN 56020000000 and 56099999999),
    CONSTRAINT FK_UsuarioRecreativa FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID),
);


/*
    Tabla de conexion entre Servicios - Empresa Recreativa
*/
CREATE TABLE ServiciosRecreativa (  --Usar la misma tabla que usa la empresa hotelera??? 
    EmpresaID INT NOT NULL,
    ServicioID INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Empresa_ServiciosRecrativos PRIMARY KEY (EmpresaID,ServicioID),
    CONSTRAINT FK_Servicios_Recreativa FOREIGN KEY (EmpresaID) REFERENCES EmpresasRecreativas(EmpresaID),
    CONSTRAINT FK_Servicio_Recreativa FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID)
);


/*
    Tabla conexion Actividades - Empresa Recreativa
*/
CREATE TABLE Actividad_Recreativa (
    EmpresaID INT NOT NULL,
    ActividadID INT NOT NULL,

    --Restricciones
    CONSTRAINT PK_Recreativa_Actividades_ID PRIMARY KEY (EmpresaID,ActividadID),
    CONSTRAINT FK_Actividad_Recreativa FOREIGN KEY (EmpresaID) REFERENCES EmpresasRecreativas(EmpresaID),
    CONSTRAINT FK_ActividadID FOREIGN KEY (ActividadID) REFERENCES TipoActividad(ActividadID)
);





