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
