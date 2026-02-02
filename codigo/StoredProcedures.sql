USE SistemaHotelero
GO
-- Modelo CRUD ----------------------------
CREATE OR ALTER PROCEDURE Insert_Usuario
    @NombreUsuario VARCHAR(32),
    @ContrasenaPlano NVARCHAR(256),
    @TipoUsuario VARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Usuario WHERE NombreUsuario = @NombreUsuario)
    BEGIN
        THROW 50010, 'El nombre de usuario ya esta en uso.', 1;
    END

    IF @TipoUsuario NOT IN ('EmpresaRecreativa','EmpresaHotelera','Cliente')
    BEGIN
        THROW 50011, 'Tipo de usuario invalido.', 1;
    END

    --Cifrado de la contrasena (sacado y adaptado de internet) USADO EN Update_Usuario TAMBIEN
    --CONVERT(TipoDato,Expresion)
    --HASHBYTES('algoritmo',expresion) -> Cifra combinando la contra con un texto random (generado por el algoritmo elegido)
    --'SHA2_256' es un algoritmo de cifrado seguro, aunque no el mas seguro disponible
    DECLARE @ContrasenaHash VARCHAR(64);
    SET @ContrasenaHash = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(256), @ContrasenaPlano)), 2);

    INSERT INTO Usuario (NombreUsuario, Contrasena, TipoUsuario)
    VALUES (@NombreUsuario, @ContrasenaHash, @TipoUsuario);
END;
GO


CREATE OR ALTER PROCEDURE Update_Usuario
    @UsuarioID INT,
    @NombreUsuario VARCHAR(32),
    @TipoUsuario VARCHAR(32),
    @ContrasenaPlano NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioID = @UsuarioID)
    BEGIN
        THROW 50012, 'El usuario no existe.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM Usuario 
        WHERE NombreUsuario = @NombreUsuario AND UsuarioID <> @UsuarioID
    )
    BEGIN
        THROW 50013, 'Ya existe otro usuario con ese nombre.', 1;
    END

    IF @TipoUsuario NOT IN ('EmpresaRecreativa','EmpresaHotelera','Cliente')
    BEGIN
        THROW 50014, 'Tipo de usuario invalido.', 1;
    END

    DECLARE @ContrasenaHash VARCHAR(64) = NULL;
    IF @ContrasenaPlano IS NOT NULL
    BEGIN
        SET @ContrasenaHash = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(256), @ContrasenaPlano)), 2);
    END

    UPDATE Usuario
    SET
        NombreUsuario = @NombreUsuario,
        TipoUsuario = @TipoUsuario,
        Contrasena = ISNULL(@ContrasenaHash, Contrasena)
    WHERE UsuarioID = @UsuarioID;
END;
GO


CREATE OR ALTER PROCEDURE Login_Usuario
    @NombreUsuario VARCHAR(32),
    @ContrasenaPlano NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ContrasenaHash VARCHAR(64);
    SET @ContrasenaHash = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONVERT(VARBINARY(256), @ContrasenaPlano)), 2);

    IF NOT EXISTS (
        SELECT 1 FROM Usuario
        WHERE NombreUsuario = @NombreUsuario AND Contrasena = @ContrasenaHash
    )
    BEGIN
        THROW 50030, 'Credenciales invalidas.', 1;
    END

    SELECT UsuarioID, NombreUsuario, TipoUsuario
    FROM Usuario
    WHERE NombreUsuario = @NombreUsuario AND Contrasena = @ContrasenaHash;
END;
GO


-- CREATE Y UPDATE CLIENTE

CREATE OR ALTER PROCEDURE Insert_Cliente
    @UsuarioID INT,
    @TipoIdentificacion VARCHAR(32),
    @Identificacion VARCHAR(64),
    @FechaNacimiento DATE,
    @PaisResidencia VARCHAR(64),
    @CorreoElectronico VARCHAR(164),
    @Nombre VARCHAR(64),
    @PrimerApellido VARCHAR(64),
    @SegundoApellido VARCHAR(64) = NULL,
    @Provincia VARCHAR(64),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

        IF EXISTS (SELECT 1 FROM Cliente WHERE Identificacion = @Identificacion)
        BEGIN
            THROW 50001, 'Ya existe un cliente con esa identificacion.', 1;
        END

        INSERT INTO Cliente (
            UsuarioID, TipoIdentificacion, Identificacion,
            FechaNacimiento, PaisResidencia, CorreoElectronico,
            Nombre, PrimerApellido, SegundoApellido,
            Provincia, Canton, Distrito
        )
        VALUES (
            @UsuarioID, @TipoIdentificacion, @Identificacion,
            @FechaNacimiento, @PaisResidencia, @CorreoElectronico,
            @Nombre, @PrimerApellido, @SegundoApellido,
            @Provincia, @Canton, @Distrito
        );

END;
GO


CREATE OR ALTER PROCEDURE Update_Cliente
    @ClienteID INT,
    @TipoIdentificacion VARCHAR(32),
    @Identificacion VARCHAR(64),
    @FechaNacimiento DATE,
    @PaisResidencia VARCHAR(64),
    @CorreoElectronico VARCHAR(164),
    @Nombre VARCHAR(64),
    @PrimerApellido VARCHAR(64),
    @SegundoApellido VARCHAR(64) = NULL,
    @Provincia VARCHAR(64),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE ClienteID = @ClienteID)
    BEGIN
        THROW 50002, 'Cliente no existe.', 1;
    END

    IF EXISTS (
        SELECT 1 
        FROM Cliente 
        WHERE Identificacion = @Identificacion AND ClienteID <> @ClienteID
    )
    BEGIN
        THROW 50003, 'Otra persona usa esa identificacion.', 1;
    END

    UPDATE Cliente
    SET
        TipoIdentificacion = @TipoIdentificacion,
        Identificacion = @Identificacion,
        FechaNacimiento = @FechaNacimiento,
        PaisResidencia = @PaisResidencia,
        CorreoElectronico = @CorreoElectronico,
        Nombre = @Nombre,
        PrimerApellido = @PrimerApellido,
        SegundoApellido = @SegundoApellido,
        Provincia = @Provincia,
        Canton = @Canton,
        Distrito = @Distrito
    WHERE ClienteID = @ClienteID;
END;
GO


CREATE OR ALTER PROCEDURE Select_Cliente
    @ClienteID INT = NULL,
    @Identificacion VARCHAR(64) = NULL,
    @CorreoElectronico VARCHAR(164) = NULL
AS
BEGIN
    SET NOCOUNT ON;

        SELECT ClienteID,TipoIdentificacion,Identificacion,FechaNacimiento,PaisResidencia,CorreoElectronico,
            Nombre,PrimerApellido,SegundoApellido,NombreCliente,Provincia,Canton,Distrito
    FROM vw_Clientes
    WHERE 
    --Si no se envia ningun cliente, muestra todos
        (@ClienteID IS NULL OR ClienteID = @ClienteID)
        AND (@Identificacion IS NULL OR Identificacion = @Identificacion)
        AND (@CorreoElectronico IS NULL OR CorreoElectronico = @CorreoElectronico)
    ORDER BY NombreCliente;
END;
GO



CREATE OR ALTER PROCEDURE Delete_Cliente (@ClienteID INT)
AS
BEGIN
    SET NOCOUNT ON;

        -- Verificar existencia
        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE ClienteID = @ClienteID)
        BEGIN
            THROW 50020, 'El cliente no existe.', 1;
        END

        -- Verificar si tiene reservas
        IF EXISTS (SELECT 1 FROM Reserva WHERE ClienteID = @ClienteID)
        BEGIN
            THROW 50021, 'No se puede eliminar el cliente porque tiene reservas asociadas.', 1;
        END
 
        -- Eliminar si existe y no tiene reservas
        DELETE FROM Cliente
        WHERE ClienteID = @ClienteID;

END;
GO



CREATE OR ALTER PROCEDURE Create_EmpresaHotelera
    @UsuarioID INT,
    @CedulaJuridica VARCHAR(64),
    @Nombre VARCHAR(100),
    @Tipo INT,
    @CorreoElectronico VARCHAR(256),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64),
    @Barrio VARCHAR(64),
    @OtrasSenas VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

        IF EXISTS (SELECT 1 FROM EmpresasHoteleras WHERE CedulaJuridica = @CedulaJuridica)
            THROW 51001, 'Ya existe una empresa con esa cedula juridica.', 1;

        IF EXISTS (SELECT 1 FROM EmpresasHoteleras WHERE CorreoElectronico = @CorreoElectronico)
            THROW 51002, 'Ya existe una empresa con ese correo.', 1;

        INSERT INTO EmpresasHoteleras
        (UsuarioID, CedulaJuridica, Nombre, Tipo, CorreoElectronico, Canton, Distrito, Barrio, OtrasSenas)
        VALUES
        (@UsuarioID, @CedulaJuridica, @Nombre, @Tipo, @CorreoElectronico, @Canton, @Distrito, @Barrio, @OtrasSenas);

END;
GO


CREATE OR ALTER PROCEDURE Select_EmpresaHotelera
    @EmpresaID INT = NULL,
    @Nombre VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CedulaJuridica,Nombre,Tipo,TipoHotel,CorreoElectronico,Canton,Distrito,Barrio,OtrasSenas
    FROM vw_EmpresasHoteleras
    WHERE (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
      AND (@Nombre IS NULL OR Nombre LIKE '%' + @Nombre + '%')
    ORDER BY Nombre;
END;
go


CREATE OR ALTER PROCEDURE Update_EmpresaHotelera
    @EmpresaID INT,
    @Nombre VARCHAR(100),
    @Tipo INT,
    @CorreoElectronico VARCHAR(256),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64),
    @Barrio VARCHAR(64),
    @OtrasSenas VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM EmpresasHoteleras WHERE EmpresaID = @EmpresaID)
            THROW 51101, 'La empresa no existe.', 1;

        UPDATE EmpresasHoteleras
        SET 
            Nombre = @Nombre,
            Tipo = @Tipo,
            CorreoElectronico = @CorreoElectronico,
            Canton = @Canton,
            Distrito = @Distrito,
            Barrio = @Barrio,
            OtrasSenas = @OtrasSenas
        WHERE EmpresaID = @EmpresaID;

END;
GO



-- CRUD HABITACION
CREATE OR ALTER PROCEDURE Create_Habitacion
    @EmpresaID INT,
    @NumeroHabitacion INT,
    @TipoHabitacionID INT,
    @Precio DECIMAL(10,2),
    @Nombre VARCHAR(128),
    @Descripcion VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

        IF EXISTS (
            SELECT 1 
            FROM Habitaciones 
            WHERE EmpresaID = @EmpresaID AND NumeroHabitacion = @NumeroHabitacion
        )
            THROW 52001, 'Ya existe esa habitacion en la empresa.', 1;

        INSERT INTO Habitaciones
        (EmpresaID, NumeroHabitacion, TipoHabitacionID, Precio, Nombre, Descripcion)
        VALUES
        (@EmpresaID, @NumeroHabitacion, @TipoHabitacionID, @Precio, @Nombre, @Descripcion);
END;
GO



CREATE OR ALTER PROCEDURE Select_Habitacion
    @EmpresaID INT = NULL,
    @Estado VARCHAR(32) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Empresa,NumeroHabitacion,TipoHabitacion,Precio,Estado,NombreHabitacion,Descripcion
    FROM vw_Habitaciones
    WHERE (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
      AND (@Estado IS NULL OR Estado = @Estado)
    ORDER BY Empresa, NumeroHabitacion;
END;
GO



CREATE OR ALTER PROCEDURE Update_Habitacion
    @EmpresaID INT,
    @NumeroHabitacion INT,
    @TipoHabitacionID INT,
    @Precio DECIMAL(10,2),
    @Estado VARCHAR(32),
    @Nombre VARCHAR(128),
    @Descripcion VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (
            SELECT 1 
            FROM Habitaciones 
            WHERE EmpresaID = @EmpresaID AND NumeroHabitacion = @NumeroHabitacion
        )
            THROW 52101, 'La habitacion no existe.', 1;

        UPDATE Habitaciones
        SET 
            TipoHabitacionID = @TipoHabitacionID,
            Precio = @Precio,
            Estado = @Estado,
            Nombre = @Nombre,
            Descripcion = @Descripcion
        WHERE EmpresaID = @EmpresaID 
          AND NumeroHabitacion = @NumeroHabitacion;

END;
GO


CREATE OR ALTER PROCEDURE Delete_Habitacion
    @EmpresaID INT,
    @NumeroHabitacion INT
AS
BEGIN
    SET NOCOUNT ON;

        -- En caso de no encontrar habitacion...
        IF NOT EXISTS (
            SELECT 1 
            FROM Habitaciones 
            WHERE EmpresaID = @EmpresaID AND NumeroHabitacion = @NumeroHabitacion
        )
            THROW 52201, 'La habitacion no existe.', 1;

        -- En caso de tener reservas asociadas...
        IF EXISTS (
            SELECT 1 
            FROM Reserva 
            WHERE EmpresaID = @EmpresaID AND NumeroHabitacion = @NumeroHabitacion
        )
            THROW 52202, 'No se puede eliminar la habitacion porque tiene reservas asociadas.', 1;

        UPDATE Habitaciones
        SET Estado = 'Inactivo'
        WHERE EmpresaID = @EmpresaID 
          AND NumeroHabitacion = @NumeroHabitacion;

END;
GO


-- sp crud Reserva

CREATE OR ALTER PROCEDURE Create_Reserva
    @ClienteID INT,
    @EmpresaID INT,
    @NumeroHabitacion INT,
    @FechaEntrada DATE,
    @CantPersonas INT,
    @PoseeVehiculo BIT,
    @NumeroDeNoches INT
AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE ClienteID = @ClienteID)
            THROW 53001, 'El cliente no existe.', 1;

        IF NOT EXISTS (
            SELECT 1 
            FROM Habitaciones 
            WHERE EmpresaID = @EmpresaID 
              AND NumeroHabitacion = @NumeroHabitacion
              AND Estado = 'Activo'
        )
            THROW 53002, 'La habitacion no existe o esta inactiva.', 1;

        INSERT INTO Reserva
        (ClienteID, EmpresaID, NumeroHabitacion, FechaEntrada, CantPersonas, PoseeVehiculo, NumeroDeNoches)
        VALUES
        (@ClienteID, @EmpresaID, @NumeroHabitacion, @FechaEntrada, @CantPersonas, @PoseeVehiculo, @NumeroDeNoches);

END;
GO


CREATE OR ALTER PROCEDURE Select_Reserva
    @ReservaID INT = NULL,
    @ClienteID INT = NULL,
    @EmpresaID INT = NULL,
    @Estado VARCHAR(16) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ReservaID,Cliente,Empresa,NumeroHabitacion,Habitacion,FechaEntrada,HoraEntrada,CantPersonas,
            PoseeVehiculo,NumeroDeNoches,EstadoReserva
    FROM vw_Reservas
    WHERE (@ReservaID IS NULL OR ReservaID = @ReservaID)
      AND (@ClienteID IS NULL OR ClienteID = @ClienteID)
      AND (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
      AND (@Estado IS NULL OR EstadoReserva = @Estado)
    ORDER BY FechaEntrada DESC;
END;
GO


CREATE OR ALTER PROCEDURE Update_Reserva
    @ReservaID INT,
    @FechaEntrada DATE,
    @CantPersonas INT,
    @PoseeVehiculo BIT,
    @NumeroDeNoches INT,
    @EstadoReserva VARCHAR(16)

AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM Reserva WHERE ReservaID = @ReservaID)
            THROW 53101, 'La reserva no existe.', 1;

        UPDATE Reserva
        SET 
            FechaEntrada = @FechaEntrada,
            CantPersonas = @CantPersonas,
            PoseeVehiculo = @PoseeVehiculo,
            NumeroDeNoches = @NumeroDeNoches,
            EstadoReserva = @EstadoReserva
        WHERE ReservaID = @ReservaID;

END;
GO

-- Las reservas no se eliminan, pero su estado se puede cambiar a cerrado en Update_Reserva

-- Empresa recreativa
CREATE OR ALTER PROCEDURE Create_EmpresaRecreativa
    @UsuarioID INT,
    @CedulaJuridica VARCHAR(64),
    @Nombre VARCHAR(100),
    @CorreoElectronico VARCHAR(256),
    @Telefono BIGINT,
    @NombreContacto VARCHAR(64),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64),
    @OtrasSenas VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

        INSERT INTO EmpresasRecreativas
        (UsuarioID, CedulaJuridica, Nombre, CorreoElectronico, Telefono, NombreContacto, Canton, Distrito, OtrasSenas)
        VALUES
        (@UsuarioID, @CedulaJuridica, @Nombre, @CorreoElectronico, @Telefono, @NombreContacto, @Canton, @Distrito, @OtrasSenas);

END;
GO


CREATE OR ALTER PROCEDURE Update_EmpresaRecreativa
    @EmpresaID INT,
    @CorreoElectronico VARCHAR(256),
    @Telefono BIGINT,
    @NombreContacto VARCHAR(64),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64),
    @OtrasSenas VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM EmpresasRecreativas WHERE EmpresaID = @EmpresaID)
            THROW 60002, 'La empresa recreativa no existe.', 1;

        UPDATE EmpresasRecreativas
        SET 
            CorreoElectronico = @CorreoElectronico,
            Telefono = @Telefono,
            NombreContacto = @NombreContacto,
            Canton = @Canton,
            Distrito = @Distrito,
            OtrasSenas = @OtrasSenas
        WHERE EmpresaID = @EmpresaID;

END;
GO


CREATE OR ALTER PROCEDURE Delete_EmpresaRecreativa
    @EmpresaID INT
AS
BEGIN
    SET NOCOUNT ON;

        IF EXISTS (SELECT 1 FROM Actividad_Recreativa WHERE EmpresaID = @EmpresaID)
            THROW 60003, 'No se puede eliminar la empresa: tiene actividades asociadas.', 1;

        DELETE FROM EmpresasRecreativas
        WHERE EmpresaID = @EmpresaID;

END;
GO

CREATE OR ALTER PROCEDURE Select_EmpresaRecreativa
    @EmpresaID INT = NULL,
    @Nombre VARCHAR(100) = NULL,
    @Canton VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EmpresaID,Nombre,NombreUsuario,CedulaJuridica,
            CorreoElectronico,Telefono,NombreContacto,Canton,Distrito,OtrasSenas
    FROM VW_EmpresasRecreativas
    WHERE
        (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
        AND (@Nombre IS NULL OR Nombre LIKE '%' + @Nombre + '%')
        AND (@Canton IS NULL OR Canton = @Canton)
    ORDER BY Nombre;
END;
GO


-- Servicios catalogo

CREATE OR ALTER PROCEDURE Create_Servicio
    @Nombre VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Servicios WHERE Nombre = @Nombre)
    BEGIN
        THROW 62001, 'El servicio ya existe.', 1;
    END

    INSERT INTO Servicios (Nombre)
    VALUES (@Nombre);
END;
GO


CREATE OR ALTER PROCEDURE Update_Servicio
    @ServicioID INT,
    @Nombre VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Servicios WHERE ServicioID = @ServicioID)
    BEGIN
        THROW 62002, 'Servicio no encontrado.', 1;
    END

    IF EXISTS (SELECT 1 FROM Servicios WHERE Nombre = @Nombre AND ServicioID <> @ServicioID)
    BEGIN
        THROW 62003, 'Ya existe otro servicio con ese nombre.', 1;
    END

    UPDATE Servicios
    SET Nombre = @Nombre
    WHERE ServicioID = @ServicioID;
END;
GO


CREATE OR ALTER PROCEDURE Delete_Servicio
    @ServicioID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM ServiciosHotel WHERE ServicioID = @ServicioID)
        OR EXISTS (SELECT 1 FROM ServiciosRecreativa WHERE ServicioID = @ServicioID)
    BEGIN
        THROW 62004, 'No es posible eliminar el servicio porque tiene relaciones activas.', 1;
    END

    DELETE FROM Servicios WHERE ServicioID = @ServicioID;
END;
GO


-- Tipos de habitaciones

CREATE OR ALTER PROCEDURE Create_TipoHabitacion
    @Nombre VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM TiposHabitaciones WHERE Nombre = @Nombre)
    BEGIN
        THROW 63001, 'El tipo de habitacion ya existe.', 1;
    END

    INSERT INTO TiposHabitaciones (Nombre)
    VALUES (@Nombre);
END;
GO


CREATE OR ALTER PROCEDURE Update_TipoHabitacion
    @TipoHabitacionID INT,
    @Nombre VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM TiposHabitaciones WHERE TipoHabitacionID = @TipoHabitacionID)
    BEGIN
        THROW 63002, 'Tipo de habitacion no encontrado.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM TiposHabitaciones 
        WHERE Nombre = @Nombre AND TipoHabitacionID <> @TipoHabitacionID
    )
    BEGIN
        THROW 63003, 'Ya existe otro tipo con ese nombre.', 1;
    END

    UPDATE TiposHabitaciones
    SET Nombre = @Nombre
    WHERE TipoHabitacionID = @TipoHabitacionID;
END;
GO


CREATE OR ALTER PROCEDURE Delete_TipoHabitacion
    @TipoHabitacionID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Habitaciones WHERE TipoHabitacionID = @TipoHabitacionID)
    BEGIN
        THROW 63004, 'No se puede eliminar, existen habitaciones usando este tipo.', 1;
    END

    DELETE FROM TiposHabitaciones WHERE TipoHabitacionID = @TipoHabitacionID;
END;
GO


-- Servicios asociados a hoteles

CREATE OR ALTER PROCEDURE Insert_ServicioHotel
    @EmpresaID INT,
    @ServicioID INT,
    @Precio DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EmpresasHoteleras WHERE EmpresaID = @EmpresaID)
        OR NOT EXISTS (SELECT 1 FROM Servicios WHERE ServicioID = @ServicioID)
    BEGIN
        THROW 64001, 'Empresa o servicio inexistente.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM ServiciosHotel
        WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID
    )
    BEGIN
        UPDATE ServiciosHotel
        SET Precio = @Precio
        WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID;
    END
    ELSE
    BEGIN
        INSERT INTO ServiciosHotel (EmpresaID, ServicioID, Precio)
        VALUES (@EmpresaID, @ServicioID, @Precio);
    END
END;
GO


CREATE OR ALTER PROCEDURE Remove_ServicioHotel
    @EmpresaID INT,
    @ServicioID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ServiciosHotel
    WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID;
END;
GO


-- Servicios asociados a empresas recreativas

CREATE OR ALTER PROCEDURE Insert_ServicioRecreativa
    @EmpresaID INT,
    @ServicioID INT,
    @Precio DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EmpresasRecreativas WHERE EmpresaID = @EmpresaID)
        OR NOT EXISTS (SELECT 1 FROM Servicios WHERE ServicioID = @ServicioID)
    BEGIN
        THROW 64101, 'Empresa recreativa o servicio inexistente.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM ServiciosRecreativa
        WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID
    )
    BEGIN
        UPDATE ServiciosRecreativa
        SET Precio = @Precio
        WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID;
    END
    ELSE
    BEGIN
        INSERT INTO ServiciosRecreativa (EmpresaID, ServicioID, Precio)
        VALUES (@EmpresaID, @ServicioID, @Precio);
    END
END;
GO


CREATE OR ALTER PROCEDURE Remove_ServicioRecreativa
    @EmpresaID INT,
    @ServicioID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM ServiciosRecreativa
    WHERE EmpresaID = @EmpresaID AND ServicioID = @ServicioID;
END;
GO


-- Actividades ofrecidas por empresas recreativas

CREATE OR ALTER PROCEDURE Insert_ActividadRecreativa
    @EmpresaID INT,
    @ActividadID INT,
    @Precio DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EmpresasRecreativas WHERE EmpresaID = @EmpresaID)
        OR NOT EXISTS (SELECT 1 FROM TipoActividad WHERE ActividadID = @ActividadID)
    BEGIN
        THROW 64201, 'Empresa recreativa o actividad inexistente.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM Actividad_Recreativa
        WHERE EmpresaID = @EmpresaID AND ActividadID = @ActividadID
    )
    BEGIN
        UPDATE Actividad_Recreativa
        SET Precio = @Precio
        WHERE EmpresaID = @EmpresaID AND ActividadID = @ActividadID;
    END
    ELSE
    BEGIN
        INSERT INTO Actividad_Recreativa (EmpresaID, ActividadID, Precio)
        VALUES (@EmpresaID, @ActividadID, @Precio);
    END
END;
GO


CREATE OR ALTER PROCEDURE Remove_ActividadRecreativa
    @EmpresaID INT,
    @ActividadID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Actividad_Recreativa
    WHERE EmpresaID = @EmpresaID AND ActividadID = @ActividadID;
END;
GO


-- Redes sociales por empresa hotelera

CREATE OR ALTER PROCEDURE Insert_RedSocialEmpresa
    @EmpresaID INT,
    @RedSocialID INT,
    @Red_URL VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EmpresasHoteleras WHERE EmpresaID = @EmpresaID)
        OR NOT EXISTS (SELECT 1 FROM RedesSociales WHERE RedSocialID = @RedSocialID)
    BEGIN
        THROW 65001, 'Empresa o red social inexistente.', 1;
    END

    IF EXISTS (
        SELECT 1 FROM RedesSocialesEmpresa 
        WHERE EmpresaID = @EmpresaID AND RedSocialID = @RedSocialID
    )
    BEGIN
        UPDATE RedesSocialesEmpresa
        SET Red_URL = @Red_URL
        WHERE EmpresaID = @EmpresaID AND RedSocialID = @RedSocialID;
    END
    ELSE
    BEGIN
        INSERT INTO RedesSocialesEmpresa (EmpresaID, RedSocialID, Red_URL)
        VALUES (@EmpresaID, @RedSocialID, @Red_URL);
    END
END;
GO


CREATE OR ALTER PROCEDURE Delete_RedSocialEmpresa
    @EmpresaID INT,
    @RedSocialID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM RedesSocialesEmpresa
    WHERE EmpresaID = @EmpresaID AND RedSocialID = @RedSocialID;
END;
GO


--Select de factura 
CREATE OR ALTER PROCEDURE Select_Factura
    @NumeroDeFactura INT = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @ReservaID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FacturaID,
        NumeroDeFactura,
        FechaFacturacion,
        FormatoDePago,
        CargosAdicionales,
            ReservaID,
            EstadoReserva,
            CantPersonas,
            PoseeVehiculo,
            NumeroHabitacion,
            NombreHabitacion,
            PrecioHabitacion,

            ClienteID,
            NombreCliente,
            Identificacion,
            CorreoElectronico,

            EmpresaID,
            NombreHotel
    FROM VW_Factura_Detalle
    WHERE
        (@NumeroDeFactura IS NULL OR NumeroDeFactura = @NumeroDeFactura)
        AND (@FechaDesde IS NULL OR FechaFacturacion >= @FechaDesde)
            AND (@FechaHasta IS NULL OR FechaFacturacion < DATEADD(DAY, 1, @FechaHasta))
            AND (@ReservaID IS NULL OR ReservaID = @ReservaID)
    ORDER BY FechaFacturacion DESC;
END;
GO

CREATE OR ALTER PROCEDURE Update_Factura
    @FacturaID INT,
    @FormatoDePago VARCHAR(32),
    @CargosAdicionales INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Factura WHERE FacturaID = @FacturaID)
    BEGIN
        THROW 61001, 'La factura no existe.', 1;
    END

    UPDATE Factura
    SET
        FormatoDePago = @FormatoDePago,
        CargosAdicionales = @CargosAdicionales
    WHERE FacturaID = @FacturaID;
END;
GO

