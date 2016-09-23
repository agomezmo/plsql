--------------------------------------------------------
-- Archivo creado  - viernes-septiembre-23-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package FO_SSI_CFDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "FO"."FO_SSI_CFDI_PKG" 
AS
	/* TODO enter package declarations (types, exceptions, methods etc) here */
	/* TODO enter package declarations (types, exceptions, methods etc) here */
	FUNCTION FO_VALOR_CATALOGO(
			P_PROCESO IN VARCHAR2,
			P_CLAVE   IN VARCHAR2)
		RETURN VARCHAR2;
		
	PROCEDURE ESCRIBIR_ARCHIVO_DAT(
			P_FECHA_OPERACION IN VARCHAR2,
			P_FECHA_EJERCICIO IN VARCHAR2);
			
	PROCEDURE Fo_envioCD(
			p_archivo IN VARCHAR2,
			p_error OUT NUMBER);
			
	PROCEDURE FO_GUARDAR_ERROR(
			p_error IN VARCHAR2);	
			
END fo_ssi_cfdi_pkg;

/
