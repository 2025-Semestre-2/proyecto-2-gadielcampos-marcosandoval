USE SistemaHotelero
--Indices Cliente

CREATE NONCLUSTERED INDEX IX_Cliente_Identificacion ON Cliente(Identificacion);

CREATE NONCLUSTERED INDEX IX_Cliente_Correo ON Cliente(CorreoElectronico);

CREATE NONCLUSTERED INDEX IX_Cliente_Nombre ON Cliente(PrimerApellido, Nombre);


--Indices Empresas hoteleras

CREATE NONCLUSTERED INDEX IX_EmpresasHoteleras_Nombre ON EmpresasHoteleras(Nombre);

CREATE NONCLUSTERED INDEX IX_EmpresasHoteleras_Canton ON EmpresasHoteleras(Canton);

CREATE NONCLUSTERED INDEX IX_EmpresasHoteleras_Tipo ON EmpresasHoteleras(Tipo);

--Indices Habitaciones

CREATE NONCLUSTERED INDEX IX_Habitaciones_Empresa_Numero ON Habitaciones(EmpresaID, NumeroHabitacion);

CREATE NONCLUSTERED INDEX IX_Habitaciones_Tipo ON Habitaciones(TipoHabitacionID);

CREATE NONCLUSTERED INDEX IX_Habitaciones_Estado ON Habitaciones(Estado);

--Indices Reserva
CREATE NONCLUSTERED INDEX IX_Reserva_Cliente ON Reserva(ClienteID);

CREATE NONCLUSTERED INDEX IX_Reserva_Empresa ON Reserva(EmpresaID);

CREATE NONCLUSTERED INDEX IX_Reserva_Fecha ON Reserva(FechaEntrada);

CREATE NONCLUSTERED INDEX IX_Reserva_Estado ON Reserva(EstadoReserva);


--Indices factura
CREATE NONCLUSTERED INDEX IX_Factura_Numero ON Factura(NumeroDeFactura);

CREATE NONCLUSTERED INDEX IX_Factura_Fecha ON Factura(FechaFacturacion);

CREATE NONCLUSTERED INDEX IX_Factura_Reserva ON Factura(ReservaID);


--Indices para consultas relacionadas a Reportes
CREATE NONCLUSTERED INDEX IX_Reserva_Empresa_NumHabitacion ON Reserva(EmpresaID, NumeroHabitacion);

CREATE NONCLUSTERED INDEX IX_Factura_Reserva_Fecha ON Factura(ReservaID, FechaFacturacion);

CREATE NONCLUSTERED INDEX IX_EmpresasRecreativas_Canton ON EmpresasRecreativas(Canton);

--Indices adicionales para reporteria
CREATE NONCLUSTERED INDEX IX_Factura_FechaReserva ON Factura(FechaFacturacion, ReservaID) INCLUDE (NumeroDeFactura, FormatoDePago, CargosAdicionales);

CREATE NONCLUSTERED INDEX IX_Reserva_Empresa_Fecha ON Reserva(EmpresaID, FechaEntrada) INCLUDE (NumeroHabitacion, CantPersonas, EstadoReserva);

CREATE NONCLUSTERED INDEX IX_Cliente_FechaNacimiento ON Cliente(FechaNacimiento);

