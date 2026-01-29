USE SistemaHotelero
--Stored procedures para reportes
GO

CREATE OR ALTER PROCEDURE Reporte_Facturacion
--Visualizar lo facturado
--Si no recibe nada, toma el valor NULL (valor por defecto)
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoHabitacionID INT = NULL,
    @EmpresaID INT = NULL,
    @NumeroHabitacion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Nombre AS Hotel,
        th.Nombre AS TipoHabitacion,
        h.NumeroHabitacion,
        f.FechaFacturacion,
        f.NumeroDeFactura,
        f.FormatoDePago,
        (r.NumeroDeNoches * h.Precio + f.CargosAdicionales) AS TotalFacturado

    FROM Factura f
    JOIN Reserva r ON f.ReservaID = r.ReservaID
    JOIN Habitaciones h ON r.EmpresaID = h.EmpresaID AND r.NumeroHabitacion = h.NumeroHabitacion
    JOIN TiposHabitaciones th ON h.TipoHabitacionID = th.TipoHabitacionID
    JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID

    WHERE --Si no recibe nada (es null) entonces se muestran todas las filas (de acuerdo a los demas filtros)
        (@FechaInicio IS NULL OR f.FechaFacturacion >= @FechaInicio)
        AND (@FechaFin IS NULL OR f.FechaFacturacion <= @FechaFin)
        AND (@TipoHabitacionID IS NULL OR th.TipoHabitacionID = @TipoHabitacionID)
        AND (@EmpresaID IS NULL OR e.EmpresaID = @EmpresaID)
        AND (@NumeroHabitacion IS NULL OR h.NumeroHabitacion = @NumeroHabitacion)
    ORDER BY f.FechaFacturacion DESC;
END;
GO


CREATE OR ALTER PROCEDURE Reporte_ReservasUsadas_TipoHabitacion_Fecha
--Visualizar Reservas por fecha o tipo de habitacion 
--MODIFICAR PARA RECIBIR MULTIPLES TIPOS DE HABITACION
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoHabitacion VARCHAR(128)   
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Nombre AS Hotel,
        th.Nombre AS TipoHabitacion,
        h.NumeroHabitacion,
        r.ReservaID,
        r.FechaEntrada,
        r.NumeroDeNoches,
        r.EstadoReserva

    FROM Reserva r
    JOIN Habitaciones h ON r.EmpresaID = h.EmpresaID AND r.NumeroHabitacion = h.NumeroHabitacion
    JOIN TiposHabitaciones th ON h.TipoHabitacionID = th.TipoHabitacionID
    JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID

    WHERE r.EstadoReserva = 'CERRADO' 
          AND (@FechaInicio IS NULL OR r.FechaEntrada >= @FechaInicio)
          AND (@FechaFin IS NULL OR r.FechaEntrada <= @FechaFin)
          AND (@TipoHabitacion IS NULL OR  th.Nombre = @TipoHabitacion)

    ORDER BY e.Nombre, th.Nombre, r.FechaEntrada;
END;
GO


CREATE OR ALTER PROCEDURE Reporte_RangoEdadReal_PorHotel
-- Sp de rangos_edad, no recibe parametros, y regresa el nombre del hotel y 
-- la edad minima y maxima historica de personas que han realizado una reserva
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Nombre AS Hotel,
        MIN(DATEDIFF(YEAR, c.FechaNacimiento, GETDATE())) AS EdadMinima,
        MAX(DATEDIFF(YEAR, c.FechaNacimiento, GETDATE())) AS EdadMaxima

    FROM Reserva r
    JOIN Cliente c ON r.ClienteID = c.ClienteID
    JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID
    GROUP BY e.Nombre
    ORDER BY e.Nombre;

END;
GO

CREATE OR ALTER PROCEDURE Reporte_Hoteles_MayorDemanda_Fecha_Canton
-- sp brinda hoteles con mayor demanda (mayor cantidad de reservas) filtrando por fecha y canton

    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Canton VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Nombre AS Hotel,
        e.Canton,
        COUNT(r.ReservaID) AS TotalReservas

    FROM Reserva r
    JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID

    -- Si recibe un null, envia un historico o para cantones, para todas las ubicaciones
WHERE (@FechaInicio IS NULL OR r.FechaEntrada >= @FechaInicio)
      AND (@FechaFin IS NULL OR r.FechaEntrada <= @FechaFin)
      AND (@Canton IS NULL OR e.Canton = @Canton)
      

    GROUP BY e.Nombre, e.Canton
    ORDER BY TotalReservas DESC;
END;
GO

