USE SistemaHotelero;
GO


CREATE SEQUENCE seqNumeroFactura AS BIGINT
  START WITH 1001
  INCREMENT BY 1
GO

CREATE OR ALTER TRIGGER trg_Reserva_CierreGeneraFactura
ON Reserva
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Factura (ReservaID, NumeroDeFactura, FormatoDePago, CargosAdicionales)
    SELECT i.ReservaID,
           NEXT VALUE FOR seqNumeroFactura, --Genera un numero de factura unico 
           'Efectivo',0     --Valores por defecto, pueden ser actualizados luego
    FROM inserted i
    INNER JOIN deleted d ON d.ReservaID = i.ReservaID
    WHERE i.EstadoReserva = 'CERRADO'
      AND d.EstadoReserva <> 'CERRADO'
      AND NOT EXISTS (
            SELECT 1 FROM Factura f WHERE f.ReservaID = i.ReservaID  --Se evitan dos facturas para la misma reserva
        );
END;
GO

