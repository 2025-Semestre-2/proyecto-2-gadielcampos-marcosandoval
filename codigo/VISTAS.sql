USE SistemaHotelero
GO

--Vista Reporte_Facturacion
CREATE OR ALTER VIEW VW_Reporte_Facturacion
AS
SELECT 
    e.EmpresaID,
    e.Nombre AS Hotel,
    e.Canton,
    th.TipoHabitacionID,
    th.Nombre AS TipoHabitacion,
    h.NumeroHabitacion,
    h.Precio,
    f.FechaFacturacion,
    f.NumeroDeFactura,
    f.FormatoDePago,
    f.CargosAdicionales,
    r.NumeroDeNoches
FROM Factura f
JOIN Reserva r ON f.ReservaID = r.ReservaID
JOIN Habitaciones h ON r.EmpresaID = h.EmpresaID 
                   AND r.NumeroHabitacion = h.NumeroHabitacion
JOIN TiposHabitaciones th ON h.TipoHabitacionID = th.TipoHabitacionID
JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID;
GO


--Vista Reporte Reservas Usadas
CREATE OR ALTER VIEW VW_Reporte_ReservasUsadas
AS
SELECT 
    e.Nombre AS Hotel,
    th.TipoHabitacionID,
    th.Nombre AS TipoHabitacion,
    h.NumeroHabitacion,
    r.ReservaID,
    r.FechaEntrada,
    r.NumeroDeNoches,
    r.EstadoReserva
FROM Reserva r
JOIN Habitaciones h ON r.EmpresaID = h.EmpresaID 
                   AND r.NumeroHabitacion = h.NumeroHabitacion
JOIN TiposHabitaciones th ON h.TipoHabitacionID = th.TipoHabitacionID
JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID;
GO

--Vista reporte rengo de edad por hotel
CREATE OR ALTER VIEW VW_Reporte_RangoEdadHotel
AS
SELECT 
    e.Nombre AS Hotel,
    DATEDIFF(YEAR, c.FechaNacimiento, GETDATE()) AS Edad
FROM Reserva r
JOIN Cliente c ON r.ClienteID = c.ClienteID
JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID;
GO


--Vista Reporte Demanda de cada hotel
CREATE OR ALTER VIEW VW_Reporte_DemandaHotel
AS
SELECT 
    e.EmpresaID,
    e.Nombre AS Hotel,
    e.Canton,
    r.ReservaID,
    r.FechaEntrada
FROM Reserva r
JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID;
GO


-- Vista cliente
CREATE OR ALTER VIEW vw_Clientes
AS
SELECT 
    c.ClienteID,
    c.TipoIdentificacion,
    c.Identificacion,
    c.FechaNacimiento,
    c.PaisResidencia,
    c.CorreoElectronico,
    c.Nombre,
    c.PrimerApellido,
    c.SegundoApellido,
    CONCAT(c.PrimerApellido,' ',c.SegundoApellido,' ',c.Nombre) AS NombreCliente,
    c.Provincia,
    c.Canton,
    c.Distrito
FROM Cliente c;
GO


-- Vista hotelera
CREATE OR ALTER VIEW vw_EmpresasHoteleras
AS
SELECT 
    e.EmpresaID,
    e.UsuarioID,
    e.CedulaJuridica,
    e.Nombre,
    e.Tipo,
    th.Nombre AS TipoHotel,
    e.CorreoElectronico,
    e.Canton,
    e.Distrito,
    e.Barrio,
    e.OtrasSenas
FROM EmpresasHoteleras e
INNER JOIN TiposHoteles th ON e.Tipo = th.TipoHotelID;
GO

--Vista habitacion
CREATE OR ALTER VIEW vw_Habitaciones
AS
SELECT 
    h.EmpresaID,
    e.Nombre AS Empresa,
    h.NumeroHabitacion,
    h.TipoHabitacionID,
    th.Nombre AS TipoHabitacion,
    h.Precio,
    h.Estado,
    h.Nombre AS NombreHabitacion,
    h.Descripcion
FROM Habitaciones h
INNER JOIN EmpresasHoteleras e ON h.EmpresaID = e.EmpresaID
INNER JOIN TiposHabitaciones th ON h.TipoHabitacionID = th.TipoHabitacionID;
GO


--Vista reserva
CREATE OR ALTER VIEW vw_Reservas
AS
SELECT 
    r.ReservaID,
    r.ClienteID,
    c.Nombre + ' ' + c.PrimerApellido AS Cliente,
    r.EmpresaID,
    e.Nombre AS Empresa,
    r.NumeroHabitacion,
    h.Nombre AS Habitacion,
    r.FechaEntrada,
    r.HoraEntrada,
    r.CantPersonas,
    r.PoseeVehiculo,
    r.NumeroDeNoches,
    r.EstadoReserva
FROM Reserva r
INNER JOIN Cliente c ON r.ClienteID = c.ClienteID
INNER JOIN EmpresasHoteleras e ON r.EmpresaID = e.EmpresaID
INNER JOIN Habitaciones h 
    ON r.EmpresaID = h.EmpresaID AND r.NumeroHabitacion = h.NumeroHabitacion;
GO

-- Vista Recreativa
CREATE OR ALTER VIEW VW_EmpresasRecreativas
AS
SELECT 
    er.EmpresaID,
    er.Nombre,
    er.CedulaJuridica,
    er.CorreoElectronico,
    er.Telefono,
    er.NombreContacto,
    er.Canton,
    er.Distrito,
    er.OtrasSenas,
    u.NombreUsuario
FROM EmpresasRecreativas er
JOIN Usuario u ON er.UsuarioID = u.UsuarioID;
GO



--Vista factura
CREATE OR ALTER VIEW VW_Factura_Detalle
AS
SELECT
    f.FacturaID,
    f.NumeroDeFactura,
    f.FechaFacturacion,
    f.FormatoDePago,
    f.CargosAdicionales,

    r.ReservaID,
    r.FechaEntrada,
    r.NumeroDeNoches,
    r.CantPersonas,
    r.PoseeVehiculo,
    r.EstadoReserva,

    h.NumeroHabitacion,
    h.Nombre AS NombreHabitacion,
    h.Precio AS PrecioHabitacion,

    c.ClienteID,
    CONCAT(c.PrimerApellido,' ',c.SegundoApellido,' ',c.Nombre) AS NombreCliente,
    c.Identificacion,
    c.CorreoElectronico,

    eh.EmpresaID,
    eh.Nombre AS NombreHotel
FROM Factura f
INNER JOIN Reserva r   ON f.ReservaID = r.ReservaID
INNER JOIN Cliente c   ON r.ClienteID = c.ClienteID
INNER JOIN EmpresasHoteleras eh ON r.EmpresaID = eh.EmpresaID
INNER JOIN Habitaciones h 
    ON r.EmpresaID = h.EmpresaID AND r.NumeroHabitacion = h.NumeroHabitacion;
GO

