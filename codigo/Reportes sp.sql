USE SistemaHotelero
--Stored procedures para reportes
GO

CREATE OR ALTER PROCEDURE Reporte_Facturacion
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoHabitacionID INT = NULL,
    @EmpresaID INT = NULL,
    @NumeroHabitacion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Hotel,
        TipoHabitacion,
        NumeroHabitacion,
        FechaFacturacion,
        NumeroDeFactura,
        FormatoDePago,
        (NumeroDeNoches * Precio + CargosAdicionales) AS TotalFacturado
    FROM VW_Reporte_Facturacion
    WHERE
        (@FechaInicio IS NULL OR FechaFacturacion >= @FechaInicio)
        AND (@FechaFin IS NULL OR FechaFacturacion <= @FechaFin)
        AND (@TipoHabitacionID IS NULL OR TipoHabitacionID = @TipoHabitacionID)
        AND (@EmpresaID IS NULL OR EmpresaID = @EmpresaID)
        AND (@NumeroHabitacion IS NULL OR NumeroHabitacion = @NumeroHabitacion)
    ORDER BY FechaFacturacion DESC;
END;
GO



CREATE OR ALTER PROCEDURE Reporte_ReservasUsadas_TipoHabitacion_Fecha
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoHabitacion VARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM VW_Reporte_ReservasUsadas
    WHERE
        EstadoReserva = 'CERRADO'
        AND (@FechaInicio IS NULL OR FechaEntrada >= @FechaInicio)
        AND (@FechaFin IS NULL OR FechaEntrada <= @FechaFin)
        AND (@TipoHabitacion IS NULL OR TipoHabitacion = @TipoHabitacion)
    ORDER BY Hotel, TipoHabitacion, FechaEntrada;
END;
GO



CREATE OR ALTER PROCEDURE Reporte_RangoEdadReal_PorHotel
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Hotel,
        MIN(Edad) AS EdadMinima,
        MAX(Edad) AS EdadMaxima
    FROM VW_Reporte_RangoEdadHotel
    GROUP BY Hotel
    ORDER BY Hotel;
END;
GO


CREATE OR ALTER PROCEDURE Reporte_Hoteles_MayorDemanda_Fecha_Canton
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Canton VARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Hotel,
        Canton,
        COUNT(ReservaID) AS TotalReservas
    FROM VW_Reporte_DemandaHotel
    WHERE
        (@FechaInicio IS NULL OR FechaEntrada >= @FechaInicio)
        AND (@FechaFin IS NULL OR FechaEntrada <= @FechaFin)
        AND (@Canton IS NULL OR Canton = @Canton)
    GROUP BY Hotel, Canton
    ORDER BY TotalReservas DESC;
END;
GO



