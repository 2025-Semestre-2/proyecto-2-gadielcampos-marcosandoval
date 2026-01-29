USE SistemaHotelero
-- Modelo CRUD ----------------------------



-- CREATE Y UPDATE CLIENTE

CREATE OR ALTER PROCEDURE Insert_Cliente
    @UsuarioID INT,
    @TipoIdentificacion VARCHAR(32),
    @Identificacion VARCHAR(64),
    @Contrasena VARCHAR(32),
    @FechaNacimiento DATE,
    @PaisResidencia VARCHAR(64),
    @CorreoElectronico VARCHAR(164),
    @Nombre VARCHAR(64),
    @PrimerApellido VARCHAR(64),
    @SegundoApellido VARCHAR(64),
    @Provincia VARCHAR(64),
    @Canton VARCHAR(64),
    @Distrito VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

        -- Validación
        IF EXISTS (SELECT 1 FROM Cliente WHERE Identificacion = @Identificacion)
        BEGIN
            THROW 50001, 'Ya existe un cliente con esa identificación.', 1;
        END

        INSERT INTO Cliente (
            UsuarioID, TipoIdentificacion, Identificacion, Contrasena,
            FechaNacimiento, PaisResidencia, CorreoElectronico,
            Nombre, PrimerApellido, SegundoApellido,
            Provincia, Canton, Distrito
        )
        VALUES (
            @UsuarioID, @TipoIdentificacion, @Identificacion, @Contrasena,
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
    @Contrasena VARCHAR(32),
    @FechaNacimiento DATE,
    @PaisResidencia VARCHAR(64),
    @CorreoElectronico VARCHAR(164),
    @Nombre VARCHAR(64),
    @PrimerApellido VARCHAR(64),
    @SegundoApellido VARCHAR(64),
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

    UPDATE Cliente
    SET
        TipoIdentificacion = @TipoIdentificacion,
        Identificacion = @Identificacion,
        Contrasena = @Contrasena,
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

    SELECT *
    FROM vw_Clientes
    WHERE 
    --Si no se envia ningun cliente, muestra todos
        (@ClienteID IS NULL OR ClienteID = @ClienteID)
        AND (@Identificacion IS NULL OR Identificacion = @Identificacion)
        AND (@CorreoElectronico IS NULL OR CorreoElectronico = @CorreoElectronico)
    ORDER BY PrimerApellido, Nombre;
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
            THROW 51001, 'Ya existe una empresa con esa cédula jurídica.', 1;

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

    SELECT *
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
            THROW 52001, 'Ya existe esa habitación en la empresa.', 1;

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

    SELECT *
    FROM vw_Habitaciones
    WHERE (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
      AND (@Estado IS NULL OR Estado = @Estado)
    ORDER BY Empresa, NumeroHabitacion;
END;
GO


CREATE OR ALTER PROCEDURE Select_Habitacion
    @EmpresaID INT = NULL,
    @Estado VARCHAR(32) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
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
            THROW 52101, 'La habitación no existe.', 1;

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
            THROW 52201, 'La habitación no existe.', 1;

        -- En caso de tener reservas asociadas...
        IF EXISTS (
            SELECT 1 
            FROM Reserva 
            WHERE EmpresaID = @EmpresaID AND NumeroHabitacion = @NumeroHabitacion
        )
            THROW 52202, 'No se puede eliminar la habitación porque tiene reservas asociadas.', 1;

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
            THROW 53002, 'La habitación no existe o está inactiva.', 1;

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

    SELECT *
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
    @Telefono INT,
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
    @Telefono INT,
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

    SELECT *
    FROM VW_EmpresasRecreativas
    WHERE
        (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
        AND (@Nombre IS NULL OR Nombre LIKE '%' + @Nombre + '%')
        AND (@Canton IS NULL OR Canton = @Canton)
    ORDER BY Nombre;
END;
GO
