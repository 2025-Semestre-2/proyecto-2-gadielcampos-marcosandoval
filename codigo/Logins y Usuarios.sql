USE master;
GO

-- Crear logins a nivel de servidor si no existen
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'EmpresaHoteleraLogin')
BEGIN
	CREATE LOGIN EmpresaHoteleraLogin WITH PASSWORD = 'HOTELPASSWORD';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'EmpresaRecreativaLogin')
BEGIN
	CREATE LOGIN EmpresaRecreativaLogin WITH PASSWORD = 'RECREPASSWORD';
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'ClienteLogin')
BEGIN
	CREATE LOGIN ClienteLogin WITH PASSWORD = 'CLIENTPASSWORD';
END;
GO

USE SistemaHotelero;
GO

-- Roles por tipo de usuario (se crean una vez)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_EmpresaHotelera' AND type = 'R')
BEGIN
	CREATE ROLE Rol_EmpresaHotelera;
END;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_EmpresaRecreativa' AND type = 'R')
BEGIN
	CREATE ROLE Rol_EmpresaRecreativa;
END;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Cliente' AND type = 'R')
BEGIN
	CREATE ROLE Rol_Cliente;
END;
GO



--Permisos basados en stored procedures

-- Rol para empresas hoteleras (CRUD hotel, habitaciones, tipo de habitacion, servicios hotel y catálogos compartidos)
GRANT EXECUTE ON dbo.Create_EmpresaHotelera TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Update_EmpresaHotelera TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Create_Habitacion TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Update_Habitacion TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Delete_Habitacion TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Insert_ServicioHotel TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Remove_ServicioHotel TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Insert_RedSocialEmpresa TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Delete_RedSocialEmpresa TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Create_TipoHabitacion TO Rol_EmpresaHotelera;

-- Rol para empresas recreativas (CRUD recreativo, actividades y servicios recreativos)
GRANT EXECUTE ON dbo.Create_EmpresaRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Update_EmpresaRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Delete_EmpresaRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Insert_ServicioRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Remove_ServicioRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Insert_ActividadRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Remove_ActividadRecreativa TO Rol_EmpresaRecreativa;

-- Permisos compartidos (catálogos generales, reportes y consultas)
GRANT EXECUTE ON dbo.Create_Servicio TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Create_Servicio TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Update_Servicio TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Update_Servicio TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Delete_Servicio TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Delete_Servicio TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_EmpresaHotelera TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_EmpresaHotelera TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_Habitacion TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_Habitacion TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_EmpresaRecreativa TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_EmpresaRecreativa TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_Reserva TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_Reserva TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_Factura TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_Factura TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Select_Cliente TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Select_Cliente TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Reporte_Facturacion TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Reporte_Facturacion TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Reporte_ReservasUsadas_TipoHabitacion_Fecha TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Reporte_ReservasUsadas_TipoHabitacion_Fecha TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Reporte_RangoEdadReal_PorHotel TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Reporte_RangoEdadReal_PorHotel TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Reporte_Hoteles_MayorDemanda_Fecha_Canton TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Reporte_Hoteles_MayorDemanda_Fecha_Canton TO Rol_EmpresaRecreativa;
GRANT EXECUTE ON dbo.Login_Usuario TO Rol_EmpresaHotelera;
GRANT EXECUTE ON dbo.Login_Usuario TO Rol_EmpresaRecreativa;

GRANT EXECUTE ON dbo.Insert_Usuario TO Rol_Cliente;
GRANT EXECUTE ON dbo.Update_Usuario TO Rol_Cliente;
GRANT EXECUTE ON dbo.Insert_Cliente TO Rol_Cliente;
GRANT EXECUTE ON dbo.Update_Cliente TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_Cliente TO Rol_Cliente;
GRANT EXECUTE ON dbo.Delete_Cliente TO Rol_Cliente;
GRANT EXECUTE ON dbo.Create_Reserva TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_Reserva TO Rol_Cliente;
GRANT EXECUTE ON dbo.Update_Reserva TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_EmpresaHotelera TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_Habitacion TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_EmpresaRecreativa TO Rol_Cliente;
GRANT EXECUTE ON dbo.Select_Factura TO Rol_Cliente;
GRANT EXECUTE ON dbo.Reporte_Facturacion TO Rol_Cliente;
GRANT EXECUTE ON dbo.Reporte_ReservasUsadas_TipoHabitacion_Fecha TO Rol_Cliente;
GRANT EXECUTE ON dbo.Reporte_RangoEdadReal_PorHotel TO Rol_Cliente;
GRANT EXECUTE ON dbo.Reporte_Hoteles_MayorDemanda_Fecha_Canton TO Rol_Cliente;
GRANT EXECUTE ON dbo.Login_Usuario TO Rol_Cliente;
GO

-- Usuarios de base de datos asociados a los logins y roles

--Crear usuarios si no existen
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'EmpresaHoteleraUser')
BEGIN
	CREATE USER EmpresaHoteleraUser FOR LOGIN EmpresaHoteleraLogin;
END;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'EmpresaRecreativaUser')
BEGIN
	CREATE USER EmpresaRecreativaUser FOR LOGIN EmpresaRecreativaLogin;
END;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ClienteUser')
BEGIN
	CREATE USER ClienteUser FOR LOGIN ClienteLogin;
END;


--Asignar roles a los usuarios si no estan asignados
IF NOT EXISTS (
	SELECT 1
	FROM sys.database_role_members drm
	INNER JOIN sys.database_principals dp ON dp.principal_id = drm.member_principal_id
	INNER JOIN sys.database_principals rp ON rp.principal_id = drm.role_principal_id
	WHERE dp.name = 'EmpresaHoteleraUser' AND rp.name = 'Rol_EmpresaHotelera'
)
BEGIN
	ALTER ROLE Rol_EmpresaHotelera ADD MEMBER EmpresaHoteleraUser;
END;

IF NOT EXISTS (
	SELECT 1
	FROM sys.database_role_members drm
	INNER JOIN sys.database_principals dp ON dp.principal_id = drm.member_principal_id
	INNER JOIN sys.database_principals rp ON rp.principal_id = drm.role_principal_id
	WHERE dp.name = 'EmpresaRecreativaUser' AND rp.name = 'Rol_EmpresaRecreativa'
)
BEGIN
	ALTER ROLE Rol_EmpresaRecreativa ADD MEMBER EmpresaRecreativaUser;
END;

IF NOT EXISTS (
	SELECT 1
	FROM sys.database_role_members drm
	INNER JOIN sys.database_principals dp ON dp.principal_id = drm.member_principal_id
	INNER JOIN sys.database_principals rp ON rp.principal_id = drm.role_principal_id
	WHERE dp.name = 'ClienteUser' AND rp.name = 'Rol_Cliente'
)
BEGIN
	ALTER ROLE Rol_Cliente ADD MEMBER ClienteUser;
END;
GO



