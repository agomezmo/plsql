--------------------------------------------------------
-- Archivo creado  - viernes-septiembre-23-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body FO_SSI_CFDI_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "FO"."FO_SSI_CFDI_PKG" 
AS
	FUNCTION fo_valor_catalogo(
			P_PROCESO IN VARCHAR2,
			P_CLAVE   IN VARCHAR2)
		RETURN VARCHAR2
	AS
		valor fo_procesos_esp.valor_clave%type;
	BEGIN
		/*-- TAREA: Se necesita implantación para FUNCTION
		FO_SSI_PKG.FO_CATALOGO_VALOR*/
		SELECT
				valor_clave
			INTO
				valor
			FROM
				fo_procesos_esp
			WHERE
				 UPPER(CVE_PROCESO)  = UPPER(P_PROCESO)
			AND UPPER(CVE_CLAVE)    = UPPER(P_CLAVE);
		RETURN valor;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		/*-- Se ejecuta cuando ocurre una excepcion de tipo NO_DATA_FOUND*/
		valor := 'VALOR NO ENCONTRADO EN EL CATALOGO';
		RETURN valor;
	WHEN OTHERS THEN
		/*-- Se ejecuta cuando ocurre una excepcion de un tipo no tratado en los
		-- bloques anteriores*/
		valor := 'ERROR EN LA FUNCION fo_valor_catalogo';
	END fo_valor_catalogo;
	
	PROCEDURE ESCRIBIR_ARCHIVO_DAT
		(P_FECHA_OPERACION IN VARCHAR2,
		P_FECHA_EJERCICIO IN VARCHAR2)
	AS
		/****************************************************************************
		**
		PROPOSITO GENERAL DEL PROCEDIMIENTO : Escribir el archivo de datos que se 
		enviará al CFG para su posterior envío al SAT	
		FECHA DE CREACION : 14/09/2016
		AUTOR : ALEJANDRO GOMEZ MONDRAGON (sinersys)
		VARIABLE DE ENTRADA :
			P_FEC_OPERACION : Fecha de operación que realiza la consulta
			P_EJERCICIO	: Ejercicio que realiza
		VARIABLES DE SALIDA :
	
		HISTORIAL DE CAMBIOS : Versión 1.0
		****************************************************************************/
	--	Declaración de la variable que se utilizara para escribir
		V_ARCHIVO UTL_FILE.FILE_TYPE;
	-- Variable que se utiizara para obtener la fecha del servidor	
		V_FEC_OPERACION_INI DATE;
	-- Variable que contiene el nombre del archivo que se genera	
		V_NOMBRE_ARCHIVO    VARCHAR2(3000);
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (16)
		CLAVE_RETENCION     fo_procesos_esp.valor_clave%type;	
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (MXN)	
		MONEDA              fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (RETENCION)		
		TIPO_DOCUMENTO      fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (INTERESES)			
		CODIGO_MULTIPLE     fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (SI)				
		SISTEMA_FINANCIERO  fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (NACIONAL)				
		NACIONALIDAD        fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (1)				
		RENGLON             fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (01)				
		IMPUESTO            fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (PAGO DEFINITIVO)				
		TIPO_PAGO           fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (0)				
		PERDIDA             fo_procesos_esp.valor_clave%type;
		
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (0)
		PREFIJO_ARCHIVO 		fo_procesos_esp.valor_clave%TYPE;
		EXTENSION_ARCHIVO 	fo_procesos_esp.valor_clave%type;
	-- Variable que contiene el valor del catalogo en la tabla FO_PROCESOS_ESP (0)
		RUTA_SERVIDOR 			fo_procesos_esp.valor_clave%type;
		
		TIPO_ESCRITURA 		fo_procesos_esp.valor_clave%type;		
		
	-- Constantes que contienen los servicios que no se tomaran en cuenta
		COD_SERVICIO_4200 CONSTANT VARCHAR2(4) := '4200';
		COD_SERVICIO_4201 CONSTANT VARCHAR2(4) := '4201';
		COD_SERVICIO_4202 CONSTANT VARCHAR2(4) := '4202';
		
		/*----------------*/
		/*---  Cursores*/
		/*----------------*/
		/*--*/
		/*-- Cursor que obtiene las constancias digitales*/
		/*--*/
		
		CURSOR CSR_CFDI
		IS
			SELECT
					TO_CHAR(CR.FEC_OPERACION) AS FEC_OPERACION,
					CR.IMPUESTO_RETENIDO_TOTAL,
					TO_CHAR(CR.FEC_OPERACION, 'MM')   AS MES_INICIAL,
					TO_CHAR(CR.FEC_OPERACION, 'MM')   AS MES_FINAL,
					TO_CHAR(CR.FEC_OPERACION, 'YYYY') AS EJERCICIO,
					CR.RFC,
					CR.CURP,
					CR.NOMBRE,
					CR.CVE_PAGO,
					CR.INTERES_NOMINAL,
					CR.IMPORTE_NETO_SERVICIO,
					CR.IMPUESTO_RETENIDO,
					CR.APORTACION_TOTAL,
					CTAS.COD_CLIENTE,
					CTAS.COD_CUENTA,
					'MME 920427 EM3'        AS DR_RFC,
					'METLIFE MEXICO, S. A.' AS DR_RAZON_SOCIAL,
					'ROJAS BENITEZ CARMEN' RL_NOMBRE,
					'ROBC610716DR0'      AS RL_RFC,
					'ROBC610716MDFJNR09' AS RL_CURP
				FROM
					FO_CUENTAS CTAS,
					FO_CONSTANCIA_RET CR
				WHERE
					CTAS.COD_CUENTA                   = CR.COD_CUENTA
				AND COD_SERVICIO NOT              IN (COD_SERVICIO_4200,COD_SERVICIO_4201,COD_SERVICIO_4202)
				AND TO_CHAR(FEC_OPERACION, 'MM')   = P_FECHA_OPERACION
				AND TO_CHAR(FEC_OPERACION, 'YYYY') = P_FECHA_EJERCICIO;
	BEGIN
	--	Obtiene los valores que se encuentran declarados en la tabla FO_PROCESOS_ESP
		CLAVE_RETENCION 			:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI','CLAVE RETENCION');
		MONEDA         			:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI','MONEDA');
		TIPO_DOCUMENTO 			:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI','TIPO DOCUMENTO');
		CODIGO_MULTIPLE 			:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI','CODIGO_MULTIPLE');
		SISTEMA_FINANCIERO 		:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI','SISTEMA FINANCIERO');
		NACIONALIDAD 				:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI','NACIONALIDAD');
		RENGLON   					:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI', 'RENGLON');
		IMPUESTO  					:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI', 'IMPUESTO');
		TIPO_PAGO 					:= FO_SSI_CFDI_PKG.FO_VALOR_CATALOGO('CONSTANCIAS CFDI', 'TIPO PAGO');
		PERDIDA 						:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'PERDIDA');
		PREFIJO_ARCHIVO			:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'PREFIJO ARCHIVO');
		EXTENSION_ARCHIVO			:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'EXTENSION ARCHIVO');
		RUTA_SERVIDOR				:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'RUTA SERVIDOR');
		TIPO_ESCRITURA				:= FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'TIPO ESCRITURA');

		-- /*-- /*-- Asigna la fecha del servidor del día actual*/*/
		V_FEC_OPERACION_INI := SYSDATE;
		/*-- Genera el nombre del archivo de acuerdo a la constante + la fecha con
		-- extensión .dat*/
		V_NOMBRE_ARCHIVO := PREFIJO_ARCHIVO||TO_CHAR(V_FEC_OPERACION_INI,'YYYYMMDD')||EXTENSION_ARCHIVO;
		/*-- Abre el archivo para su escritura (en caso de existir lo elimina)*/
		V_ARCHIVO := UTL_FILE.FOPEN(RUTA_SERVIDOR,V_NOMBRE_ARCHIVO, TIPO_ESCRITURA);
		/*-- Comienza la escritura en el archivo utl_file.put_line imprime y se coloca
		-- en una nueva linea*/
		/*-- utl_file.put imprime y permanece en la misma linea*/
		IF UTL_FILE.IS_OPEN(V_ARCHIVO) THEN
			FOR registro IN csr_CFDI
			LOOP
				/*-- Encabezado del documento .DAT*/
				UTL_FILE.PUT (V_ARCHIVO, 'TipoRegistroCONIF=Encabezado');
				UTL_FILE.PUT (V_ARCHIVO, '|Total=');
				UTL_FILE.PUT (V_ARCHIVO, registro.IMPUESTO_RETENIDO_TOTAL);
				UTL_FILE.PUT (V_ARCHIVO, '|CveRetenc=');
				UTL_FILE.PUT (V_ARCHIVO, CLAVE_RETENCION);
				UTL_FILE.PUT (V_ARCHIVO, '|MesIni=');
				UTL_FILE.PUT (V_ARCHIVO, registro.MES_INICIAL);
				UTL_FILE.PUT (V_ARCHIVO, '|MesFin=');
				UTL_FILE.PUT (V_ARCHIVO, registro.MES_FINAL);
				UTL_FILE.PUT (V_ARCHIVO, '|Ejerc=');
				UTL_FILE.PUT (V_ARCHIVO, registro.EJERCICIO);
				UTL_FILE.PUT (V_ARCHIVO, '|Moneda=');
				UTL_FILE.PUT (V_ARCHIVO, MONEDA);
				UTL_FILE.PUT (V_ARCHIVO, '|montoTotGrav=');
				UTL_FILE.PUT (V_ARCHIVO, registro.IMPORTE_NETO_SERVICIO);
				UTL_FILE.PUT (V_ARCHIVO, '|montoTotExent=');
				UTL_FILE.PUT (V_ARCHIVO, registro.APORTACION_TOTAL);
				UTL_FILE.PUT (V_ARCHIVO, '|montoTotOperacion=');
				UTL_FILE.PUT (V_ARCHIVO, registro.IMPORTE_NETO_SERVICIO);
				UTL_FILE.PUT (V_ARCHIVO, '|FolioReferencia=');
				UTL_FILE.PUT (V_ARCHIVO, 'SIS' || registro.COD_CLIENTE ||
				registro.FEC_OPERACION);
				UTL_FILE.PUT (V_ARCHIVO, '|TipoDocumento=');
				UTL_FILE.PUT (V_ARCHIVO, TIPO_DOCUMENTO);
				UTL_FILE.PUT (V_ARCHIVO, '|Estatus=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT (V_ARCHIVO, '|UUID=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT_LINE (V_ARCHIVO, '|');
				/*-- Intereses del documento .DAT*/
				UTL_FILE.PUT (V_ARCHIVO, 'TipoRegistroCONIF=Intereses');
				UTL_FILE.PUT (V_ARCHIVO, '|CodigoMultiple=');
				UTL_FILE.PUT (V_ARCHIVO, CODIGO_MULTIPLE);
				UTL_FILE.PUT (V_ARCHIVO, '|SistFinanciero=');
				UTL_FILE.PUT (V_ARCHIVO, SISTEMA_FINANCIERO);
				UTL_FILE.PUT (V_ARCHIVO, '|RetiroAORESRetInt=');
				UTL_FILE.PUT (V_ARCHIVO, SISTEMA_FINANCIERO);
				UTL_FILE.PUT (V_ARCHIVO, '|OperFinancDerivad=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT (V_ARCHIVO, '|MontIntNominal=');
				UTL_FILE.PUT (V_ARCHIVO, registro.INTERES_NOMINAL);
				UTL_FILE.PUT (V_ARCHIVO, '|MontIntReal=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT (V_ARCHIVO, '|Perdida=');
				UTL_FILE.PUT_LINE (V_ARCHIVO, '|');
				/*-- Receptor del documento .DAT*/
				UTL_FILE.PUT (V_ARCHIVO, 'TipoRegistroCONIF=Receptor');
				UTL_FILE.PUT (V_ARCHIVO, '|Nacionalidad=');
				UTL_FILE.PUT (V_ARCHIVO, NACIONALIDAD);
				UTL_FILE.PUT (V_ARCHIVO, '|RFC=');
				UTL_FILE.PUT (V_ARCHIVO, registro.RFC);
				UTL_FILE.PUT (V_ARCHIVO, '|NumRegIdTrib=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT (V_ARCHIVO, '|nombre=');
				UTL_FILE.PUT (V_ARCHIVO, registro.NOMBRE);
				UTL_FILE.PUT (V_ARCHIVO, '|CURP=');
				UTL_FILE.PUT (V_ARCHIVO, registro.CURP);
				UTL_FILE.PUT (V_ARCHIVO, '|IdExterno=');
				UTL_FILE.PUT (V_ARCHIVO, registro.COD_CUENTA);
				UTL_FILE.PUT_LINE (V_ARCHIVO, '|');
				/*-- Cuerpo del documento .DAT*/
				UTL_FILE.PUT (V_ARCHIVO, 'TipoRegistroCONIF=Cuerpo');
				UTL_FILE.PUT (V_ARCHIVO, '|Renglon=');
				UTL_FILE.PUT (V_ARCHIVO, RENGLON);
				UTL_FILE.PUT (V_ARCHIVO, '|BaseRet=');
				UTL_FILE.PUT (V_ARCHIVO, '');
				UTL_FILE.PUT (V_ARCHIVO, '|Impuesto=');
				UTL_FILE.PUT (V_ARCHIVO, IMPUESTO);
				UTL_FILE.PUT (V_ARCHIVO, '|montoRet=');
				UTL_FILE.PUT (V_ARCHIVO, registro.IMPUESTO_RETENIDO);
				UTL_FILE.PUT (V_ARCHIVO, '|TipoPagoRet=');
				UTL_FILE.PUT (V_ARCHIVO, TIPO_PAGO);
				UTL_FILE.PUT_LINE (V_ARCHIVO, '|');
				/*-- Fin de Documento del documento .DAT*/
				UTL_FILE.PUT_LINE (V_ARCHIVO, 'TipoRegistroCONIF=FinDocumento');
			END LOOP;
			UTL_FILE.FCLOSE(V_ARCHIVO);
			DBMS_OUTPUT.PUT_LINE('Operación escribir archivo completada');
		ELSE
			UTL_FILE.FCLOSE(V_ARCHIVO);
			DBMS_OUTPUT.PUT_LINE('El archivo ya fue generado anteriormente');
		END IF;
	EXCEPTION
	WHEN UTL_FILE.INVALID_PATH THEN 
       DBMS_OUTPUT.PUT_LINE ('La ruta del archivo no existe en el servidor');
	WHEN UTL_FILE.WRITE_ERROR THEN 
      DBMS_OUTPUT.PUT_LINE ('Error de escritura en el archivo');		 
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
		DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	END ESCRIBIR_ARCHIVO_DAT;	
	
	
	
	/******************************************************************************
	Descripcion: Procedimiento de envio de archivo de informacion contable SSI a
	buzon SFG para GDI
	Vl_Seguimiento: -1 valor inicial,
	0 sin problemas en la ejecucion,
	cualquier otro valor, corresponde a un error en la ejecucion de unix
	Fecha: 02/Sep/2016
	Autor: Carlos Uribe (sinersys)
	******************************************************************************
	*/
	/*Historial de Cambios*/
	/*--Version 1.0 02/Sep/2016 Version inicial*/
	PROCEDURE Fo_envioCD(
			p_archivo IN VARCHAR2,
			p_error OUT NUMBER)
	AS
		v_comando      VARCHAR2(1000):= '';
		Vl_Seguimiento VARCHAR2(100) :='-1'; /*-- -1 valor inicial, 0 sin problemas en
		-- la ejecucion, cualquier otro valor, corresponde a un error en la ejecucion
		-- de unix*/
	BEGIN
		/*--sudo -u  <USUARIO BUZON>  /opt/connect/cdunix/ndm/bin/procs/gdips/envcd.sh
		-- <ARCHIVO .DAT>  <RUTA ORIGEN>  <BUZON SFG>*/
		dbms_output.put_line('Modificando permisos de archivo GDI...');
		v_comando:='chmod 666 '||FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'RUTA SERVIDOR')||'/'||
		p_archivo;
		dbms_output.put_line(v_comando);
		Vl_Seguimiento:=Dynapipe2.Execute_System(v_comando);
		dbms_output.put_line('Resultado Dynapipe (chmod): '||Vl_Seguimiento);
		IF(Vl_Seguimiento<>0) THEN
			dbms_output.put_line('Error en el cambio de permisos para archivo GDI: '||
			v_comando);
		ELSE
			dbms_output.put_line(
			'Modificacion de permisos satisfactoria, se realiza envio ConnectDirect...');
		END IF;
		v_comando:='sudo -u '|| FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'USUARIO BUZON')||' '||
		FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'conDirect_sh')||' '||p_archivo||' '||
		FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI', 'RUTA SERVIDOR')||' '||
		FO_SSI_CFDI_PKG.fo_valor_catalogo('CONSTANCIAS CFDI','BUZON SFG');
		dbms_output.put_line(v_comando);
		Vl_Seguimiento:=Dynapipe2.Execute_System(v_comando);
		dbms_output.put_line('Resultado Dynapipe (connectDirect): '||Vl_Seguimiento);
		IF(Vl_Seguimiento<>0) THEN
			dbms_output.put_line('Error en la ejecucion de dynapipe: '||v_comando);
		ELSE
			dbms_output.put_line('Ejecucion ConnectDirect satisfactoria' );
		END IF;
		p_error:=Vl_Seguimiento;
	END Fo_envioCD;
	
/****************************************************************************
**
PROPOSITO GENERAL DEL PROCEDIMIENTO : FO_GUARDAR_ERROR
Escribir en una tabla la fecha, el error y línea que genera el error y el usuario
aunque exista ROLLBACK en la transacció´n
FECHA DE CREACION : 20/09/2016
AUTOR : ALEJANDRO GOMEZ MONDRAGON (sinersys)
VARIABLE DE ENTRADA :
	P_FEC_OPERACION : Fecha de operación que realiza la consulta
	P_EJERCICIO	: Ejercicio que realiza
VARIABLES DE SALIDA :

HISTORIAL DE CAMBIOS : Versión 1.0
****************************************************************************/	
	
	PROCEDURE FO_GUARDAR_ERROR(p_error in varchar2) is
		PRAGMA AUTONOMOUS_TRANSACTION;
	
	BEGIN
		INSERT INTO errores(fecha, ERROR, usuario)
			  VALUES (SYSDATE, p_error, USER);
		COMMIT;
	END;	
	
END fo_ssi_cfdi_pkg;

/
