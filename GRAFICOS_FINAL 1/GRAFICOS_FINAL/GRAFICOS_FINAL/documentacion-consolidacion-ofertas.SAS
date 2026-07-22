/* ════════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PROGRAMA: CONSOLIDACION_OFERTAS_MULTIFUENTE_COMPLETO_DOCUMENTADO_v1373.SAS                                   */
/* DESCRIPCIÓN: Módulo integral de consolidación de ofertas inmobiliarias de múltiples fuentes                    */
/*              (FR, GI, CC, Properati, M2, OIC, HABI) con validaciones complejas, enriquecimiento predial       */
/*              SIIC, detección de duplicados y preparación para FOCA - 1373 LÍNEAS TOTALES                       */
/* FECHA: 16 de diciembre de 2025                                                                                  */
/* NOTA: CÓDIGO PRESERVA TODAS LAS LÍNEAS COMENTADAS CON INFORMACIÓN CRÍTICA PARA EQUIPO DE TECNOLOGÍA          */
/* RESPONSABLE: Equipo de Estadística - OFERTAS FUENTES SECUNDARIAS                                              */
/* ════════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 1: CONFIGURACIÓN DE LIBRERÍAS Y RUTAS DE ACCESO                                                         */
/* Propósito: Establecer conexiones a las bases de datos compartidas en el fileserver                            */
/* NOTA CRÍTICA: Rutas normalizadas con variable GLOBALPATH para facilitar mantenimiento                         */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/* Librería con la información de OFERTAS - Ruta principal del fileserver */
%LET GLOBALPATH = \\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS;
LIBNAME INFO "&GLOBALPATH.\BASES_COMUN";
/* Ruta alternativa comentada para uso en red local Z: */
/*LIBNAME INFO "Z:\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";*/

/* Librería con la información de los BASES BIENES - Datos catastales SDP */
LIBNAME BIENES "&GLOBALPATH.\input\Bases_Bienes\";

/* Librería con información común - Datos compartidos entre procesos */
LIBNAME COMUN "\\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";
/* Ruta alternativa comentada para uso en red local Z: */
/*LIBNAME COMUN "Z:\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";*/

/* Librería ODBCLIB para conexiones directas a bases de datos - Información de Bienes */
LIBNAME ODBCLIB "&GLOBALPATH.\input\Bases_Bienes";

/* Librería con la información de OFERTAS consolidadas - Output final */
LIBNAME OFT "\\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS\Bases_ofertas";

/* Librería alternativa comentada - Para accesos especiales de usuarios */
/*LIBNAME fjlara "\\10.34.116.150\fjlara";*/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 2: INCLUSIÓN DE PROGRAMAS Y MACROS PARA CADA FUENTE                                                    */
/* Propósito: Cargar los macros que procesan individualmente cada fuente de datos                               */
/* DESCRIPCIÓN DE MACROS:                                                                                         */
/*   - MACROS_ADICIONALES: Funciones utilitarias y verificaciones generales                                     */
/*   - Galeria_Inmobiliaria_MACRO: Procesamiento de datos de GI (fuente 2)                                      */
/*   - Finca_Raiz_MACRO: Procesamiento de datos de FR (fuente 3)                                                */
/*   - 220404_PROGRAMA_USO_TRADUCTOR: Traductor de códigos y clasificaciones estándar                           */
/*   - Cien_Cuadras_MACRO: Procesamiento de datos de CC (fuente 5)                                              */
/*   - Properati_MACRO: Procesamiento de datos de Properati (fuente 6) - Disponible pero opcional              */
/*   - Metro_cuadrado_MACRO: Procesamiento de datos de M2 (fuente 4) - Disponible pero opcional               */
/*   - OIC_MACRO: Procesamiento de datos de OIC (fuente 1 - Mayor jerarquía) - Disponible pero opcional        */
/*   - HABI_MACRO: Procesamiento de datos de HABI (fuente 7) - Disponible pero opcional                        */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%INCLUDE "&GLOBALPATH.\source\MACROS_ADICIONALES.sas";
%INCLUDE "&GLOBALPATH.\source\Galeria_Inmobiliaria_MACRO.sas";

%INCLUDE "&GLOBALPATH.\source\Finca_Raiz_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\220404_PROGRAMA_USO_TRADUCTOR.sas";

%INCLUDE "&GLOBALPATH.\source\Cien_Cuadras_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\Properati_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\Metro_cuadrado_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\OIC_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\HABI_MACRO.sas";

/* Inicio de cronómetro para medir tiempo total de ejecución */
%let _timer_start = %sysfunc(datetime());

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 3: LECTURA MASIVA POR FUENTE Y VIGENCIA (FINCA RAÍZ)                                                  */
/* Propósito: Leer archivos mensuales de Finca Raíz desde 2017 a 2025 (vigencia actual)                        */
/* NOTA TÉCNICA:                                                                                                  */
/*   - Vigencias: 17, 18, 19, 20, 21, 22, 23, 24, 25                                                           */
/*   - Meses: 01-12 (años completos) para 17-24; 01-06 para 2025 (año en curso)                                */
/*   - Macro LECTURA_MASIVA_FR: Lee archivos desde fileserver                                                   */
/*   - Macro PROCESA_MASIVO_FR: Normaliza y limpia datos iniciales                                              */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%LECTURA_MASIVA_FR(17, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(18, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(19, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(20, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(21, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(22, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(23, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(24, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(25, VALS  =01 02 03 04 05 06);

/* PROCESAMIENTO: Normalización y limpieza inicial de datos de Finca Raíz */
%PROCESA_MASIVO_FR(17, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(18, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(22, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(23, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(24, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(25, VALS=01 02 03 04 05 06);

/* Salvaguarda de base consolidada de Finca Raíz en librería permanente OFT */
DATA OFT.BASE_CONSOLIDADA_FR;  SET BASE_CONSOLIDADA_FR;RUN;
/* DESCRIPCIÓN: Módulo integral de consolidación de ofertas inmobiliarias de múltiples fuentes                    */
/*              (FR, GI, CC, Properati, M2, OIC, HABI) con validaciones complejas, enriquecimiento predial       */
/*              SIIC, detección de duplicados y preparación para FOCA - 1373 LÍNEAS TOTALES                       */
/* FECHA: 16 de diciembre de 2025                                                                                  */
/* NOTA: CÓDIGO PRESERVA TODAS LAS LÍNEAS COMENTADAS CON INFORMACIÓN CRÍTICA PARA EQUIPO DE TECNOLOGÍA          */
/* ════════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 1: CONFIGURACIÓN DE LIBRERÍAS Y RUTAS DE ACCESO                                                         */
/* Propósito: Establecer conexiones a las bases de datos compartidas en el fileserver                            */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/* Librería con la información de OFERTAS. */
%LET GLOBALPATH = \\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS;
LIBNAME INFO "&GLOBALPATH.\BASES_COMUN";
/*LIBNAME INFO "Z:\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";*/

/* Librería con la información de los BASES BIENES. */
LIBNAME BIENES "&GLOBALPATH.\input\Bases_Bienes\";

/* Librería con la información de Comun. */
LIBNAME COMUN "\\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";
/*LIBNAME COMUN "Z:\OFERTAS_FUENTES_SECUNDARIAS\BASES_COMUN";*/

/* Librería con la información de ODBCLIB. */
LIBNAME ODBCLIB "&GLOBALPATH.\input\Bases_Bienes";

/* Librería con la información de OFERTAS. */
LIBNAME OFT "\\10.35.116.242\Fileserver\estadistica\OFERTAS_FUENTES_SECUNDARIAS\Bases_ofertas";

/* Inclusión de los programas realizados para cada fuente. */
/*LIBNAME fjlara "\\10.34.116.150\fjlara";*/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 2: INCLUSIÓN DE PROGRAMAS Y MACROS PARA CADA FUENTE                                                    */
/* Propósito: Cargar los macros que procesan individualmente cada fuente de datos                               */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%INCLUDE "&GLOBALPATH.\source\MACROS_ADICIONALES.sas";
%INCLUDE "&GLOBALPATH.\source\Galeria_Inmobiliaria_MACRO.sas";

%INCLUDE "&GLOBALPATH.\source\Finca_Raiz_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\220404_PROGRAMA_USO_TRADUCTOR.sas";

%INCLUDE "&GLOBALPATH.\source\Cien_Cuadras_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\Properati_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\Metro_cuadrado_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\OIC_MACRO.sas";
%INCLUDE "&GLOBALPATH.\source\HABI_MACRO.sas";

%let _timer_start = %sysfunc(datetime());

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 3: LECTURA MASIVA POR FUENTE Y VIGENCIA (FINCA RAÍZ)                                                  */
/* Propósito: Leer archivos mensuales de Finca Raíz desde 2017 a 2025 (vigencia actual)                        */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%LECTURA_MASIVA_FR(17, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(18, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(19, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(20, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(21, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(22, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(23, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(24, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_FR(25, VALS  =01 02 03 04 05 06);

/* PROCESAMIENTO: Normalización y limpieza inicial de datos de Finca Raíz */
%PROCESA_MASIVO_FR(17, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(18, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(22, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(23, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(24, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_FR(25, VALS=01 02 03 04 05 06);

DATA OFT.BASE_CONSOLIDADA_FR;  SET BASE_CONSOLIDADA_FR;RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 4: LECTURA Y PROCESAMIENTO DE GALERÍA INMOBILIARIA                                                    */
/* Propósito: Integración de datos de Galería Inmobiliaria desde 2017 a 2025                                   */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%LECTURA_MASIVA_GI(17, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(18, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(19, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(20, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(21, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(22, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(23, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_GI(24, VALS  =01 02 03 04 05 06 07 08 09 10);

%LECTURA_MASIVA_GI(24, VALS  =09 10 11 12);
%LECTURA_MASIVA_GI(25, VALS  =01 02 03 04 05 06);

%PROCESA_MASIVO_GI(17, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(18, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(22, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_GI(23, VALS=01 02 03 04 05 06 07 08 09 10 11 12);

%PROCESA_MASIVO_GI(24, VALS=09 10 11 12);
%PROCESA_MASIVO_GI(25, VALS=01 02 03 04 05 06);

DATA OFT.BASE_CONSOLIDADA_GI ; SET BASE_CONSOLIDADA_GI;RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 5: LECTURA Y PROCESAMIENTO DE CIEN CUADRAS                                                            */
/* Propósito: Integración de datos de Cien Cuadras desde 2017 a 2025                                           */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

%LECTURA_MASIVA_CC(17, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(18, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(19, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(20, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(21, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(22, VALS  =01 02 03 04 );
%LECTURA_MASIVA_CC(23, VALS  =01 03 04);

%LECTURA_MASIVA_CC(24, VALS  =03 04);
%LECTURA_MASIVA_CC(25, VALS  =01 02);

%PROCESA_MASIVO_CC(17, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(18, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(19, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(20, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(21, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(22, VALS  =01 02 03 04 );
%PROCESA_MASIVO_CC(23, VALS  =01 03 04);

%PROCESA_MASIVO_CC(24, VALS  =03 04);
%PROCESA_MASIVO_CC(25, VALS  =01 02);

DATA OFT.BASE_CONSOLIDADA_CC ; SET BASE_CONSOLIDADA_CC;RUN;
DATA OFT.BASE_CONSOLIDADA_CC ; SET BASE_CONSOLIDADA_CC;RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 5.1: OTRAS FUENTES (PROPERATI, METRO CUADRADO, OIC) - COMENTADAS PERO DISPONIBLES                    */
/* Propósito: Infraestructura para fuentes alternas cuando se requiera integrar datos históricos               */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*
%LECTURA_MASIVA_PR(18, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_PR(19, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_PR(20, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_PR(21, VALS  =01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_PR(22, VALS=01 02 03 04 05);

%PROCESA_MASIVO_PR(18, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_PR(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_PR(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_PR(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_PR(22, VALS=01 02 03 04 05);

%LECTURA_MASIVA_M2(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_M2(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%LECTURA_MASIVA_M2(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_M2(19, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_M2(20, VALS=01 02 03 04 05 06 07 08 09 10 11 12);
%PROCESA_MASIVO_M2(21, VALS=01 02 03 04 05 06 07 08 09 10 11 12);

%CON_OIC(17,1);
%CON_OIC(18,1);
%CON_OIC(19,1);
%CON_OIC(19,7);
%CON_OIC(20,1);
%CON_OIC(21,1);
*/

/* HABI: Fuente activa para casos específicos */
%LECTURA_MASIVA_HB(24, VALS  =03);
%PROCESA_MASIVO_HB(24, VALS  =03);

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 6: CONSOLIDACIÓN INICIAL DE LAS TRES FUENTES PRINCIPALES (FR, GI, CC)                                */
/* Propósito: Unir los datasets procesados de las tres fuentes en una sola base con normalización inicial      */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*proc sql;*/
/*create table xyz as*/
/*select memname,nobs from dictionary.tables where upcase(libname)='WORK';*/
/*quit;*/

/*
DATA OFT.BASE_CONSOLIDADA_FR;  SET BASE_CONSOLIDADA_FR;RUN;
DATA OFT.BASE_CONSOLIDADA_PR;  SET OFT.BASE_CONSOLIDADA_PR;RUN;
DATA OFT.BASE_CONSOLIDADA_CC ; SET BASE_CONSOLIDADA_CC;RUN;
*/

proc sql;
   create table OFT.BASE_CONSOLIDADA_FR as
   select *
   from BASE_CONSOLIDADA_FR;
quit;

DATA OFT.BASE_CONSOLIDADA_FR;  SET BASE_CONSOLIDADA_FR;RUN;

DATA OFT.BASE_CONSOLIDADA_GI ; SET BASE_CONSOLIDADA_GI;RUN;

/*
DATA BASE_CONSOLIDADA_M2;  SET OFT.BASE_CONSOLIDADA_M2;RUN;
DATA BASE_CONSOLIDADA_OIC; SET OFT.BASE_CONSOLIDADA_OIC;RUN;
*/

%let _timer_start = %sysfunc(datetime());

/* SECCIÓN 6.1: Unión de las bases de ofertas de FR, GI, CC con normalización inicial */
DATA BASE_OFT_CONSOLIDADA;
SET 
OFT.BASE_CONSOLIDADA_FR (DROP=PK_AdvertId);
/*OFT.BASE_CONSOLIDADA_PR (DROP=IDENTIFICADOR_OR);*/
/*OFT.BASE_CONSOLIDADA_M2 (DROP=IDENTIFICADOR_OR);*/
/*OFT.BASE_CONSOLIDADA_CC (DROP=CODIGO);*/
/*OFT.BASE_CONSOLIDADA_GI (DROP=CODIGO_INMUEBLE);*/
/*OFT.BASE_CONSOLIDADA_OIC (DROP=CODIGO_OFERTA);*/

LONG_BARMANPRE = LENGTH(BARMANPRE);
MES = MONTH(FECHA);
PRECIO_M2_OFT = PRECIO/AREA_CONSTRUIDA;
IF TIPO_INMUEBLE IN ("LOTE", "FINCA") AND AREA_TERRENO IN (0, .) THEN AREA_TERRENO = AREA_CONSTRUIDA;
IF TIPO_INMUEBLE NOT IN ("CASA_USO_MIXTO", "CASA", "APARTAMENTO", "CASA_CAMPESTRE", "CASA_LOTE") THEN ESTRATO = .;
IF TIPO_INMUEBLE = "CONSULTORIO" THEN TIPO_INMUEBLE = "OFICINA";
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 7: NORMALIZACIÓN DE ÁREAS POR TIPO DE INMUEBLE                                                         */
/* Propósito: Aplicar reglas lógicas básicas (lotes sin área construida, etc.)                                 */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
IF TIPO_INMUEBLE = "LOTE" THEN AREA_CONSTRUIDA = 0;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 8: CREACIÓN DE INDICADORES DE CALIDAD BÁSICA                                                          */
/* Propósito: Identificar registros con problemas en campos críticos                                           */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
IF ANTIGUEDAD_INMUEBLE < 0 THEN ANTIGUEDAD_INMUEBLE = .;
IF LONG_BARMANPRE < 10 THEN SIN_BARMANPRE = 1; ELSE SIN_BARMANPRE = 0;
IF PRECIO < 20000 OR PRECIO = . THEN SIN_PRECIO = 1; ELSE SIN_PRECIO = 0;
IF ((AREA_CONSTRUIDA = 0) OR (AREA_CONSTRUIDA = .)) THEN SIN_AREA_CONSTRUIDA = 1; ELSE SIN_AREA_CONSTRUIDA = 0;
IF TIPO_INMUEBLE IN (" ", "", "OTRO") THEN SIN_TIPO_INMUEBLE = 1; ELSE SIN_TIPO_INMUEBLE = 0;
IF TIPO_OFERTA NOT IN ("VENTA", "ARRIENDO") THEN SIN_TIPO_OFERTA = 1; ELSE SIN_TIPO_OFERTA = 0;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 9: CÁLCULO DE VIGENCIA                                                                                 */
/* Propósito: Determinar la vigencia fiscal basada en fecha de publicación                                     */
/* NOTA CRÍTICA: El siguiente bloque se debe ejecutar SIEMPRE al inicio del año (VER FECHAS DE LAS OFERTAS)   */
/*              y UNA SOLA VEZ (SIEMPRE Y CUANDO SE TENGA INFORMACIÓN). Si se tiene información del año        */
/*              siguiente no se descomenta. Dado que la vigencia se calcula extrayendo el AÑO + 1              */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

PROC SQL;
CREATE TABLE BASE_OFT_CONSOLIDADA AS SELECT *, 
YEAR + 1 AS VIGENCIA,
MAX(YEAR) AS MAX_YEAR
FROM BASE_OFT_CONSOLIDADA;
QUIT;

DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
IF YEAR = MAX_YEAR THEN VIGENCIA = YEAR;
RUN;

/* EL SIGUIENTE BLOQUE SE DEBE EJECUTAR SIEMPRE AL INICIO DEL AÑO (VER FECHAS DE LAS OFERTAS) 
   Y UNA SOLA VEZ (SIEMPRE Y CUANDO SE TENGA INFORMACIÓN). Si se tiene información del año siguiente no se descomenta */
/* DADO QUE LA VIGENCIA SE CALCULA EXTRAYENDO EL AÑO DE LAS OFERTAS + 1 ; VIGENCIA = YEAR(FECHA) + 1 */

/*DATA BASE_OFT_CONSOLIDADA ;*/
/*SET BASE_OFT_CONSOLIDADA;*/
/*IF VIGENCIA = YEAR THEN VIGENCIA = YEAR + 1;*/
/*RUN;*/

/* FIN */

DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
DROP MAX_YEAR;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 10: CONSOLIDACIÓN DE BASES DE ESTRATO A NIVEL DE MANZANA (AÑOS 2017-2025)                            */
/* Propósito: Integrar información estratificada desde el SDP a nivel de división catastral                   */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*CONSOLIDANDO LAS BASES DE ESTRATO A NIVEL DE MANZANA*/

DATA ESTRATO_SDP_2025;
SET BIENES.ESTRATO_SDP_2025;
VIGENCIA = 2025;
KEEP CODIGO_MANZANA ESTRATO VIGENCIA;
RUN;

DATA ESTRATO_SDP_2024;
SET BIENES.ESTRATO_SDP_MARZO2024;
VIGENCIA = 2024;
KEEP CODIGO_MANZANA ESTRATO VIGENCIA;
RUN;

DATA ESTRATO_SDP_2023;
SET BIENES.ESTRATO_SDP2023;
VIGENCIA = 2023;
KEEP CODIGO_MANZANA ESTRATO VIGENCIA;
RUN;

DATA ESTRATO_SDP_MARZO2022;
SET BIENES.ESTRATO_SDP_MARZO2022;
VIGENCIA = 2022;
KEEP CODIGO_MANZANA ESTRATO VIGENCIA;
RUN;

DATA BASE_ESTRATO;
SET ESTRATO_SDP_2025
ESTRATO_SDP_2024
ESTRATO_SDP_2023
ESTRATO_SDP_MARZO2022
BIENES.BASE_ESTRATO_2017
BIENES.BASE_ESTRATO_2018
BIENES.BASE_ESTRATO_2019
BIENES.BASE_ESTRATO_2020
BIENES.BASE_ESTRATO_2021;
IF LENGTH(COMPRESS(CODIGO_MANZANA)) = 8;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   delete ESTRATO_SDP_2025 ESTRATO_SDP_2024 ESTRATO_SDP_2023 ESTRATO_SDP_MARZO2022;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 11: CONSOLIDACIÓN DE ESTRATO A NIVEL DE LOTE (CON LOTEO)                                             */
/* Propósito: Integrar estrato específico para predios con loteo catastral                                    */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*CONSOLIDANDO LAS BASES DE ESTRATO A NIVEL DE LOTE*/

DATA ESTRATO_SDP_MARZO2022_CONLOTEO;
SET BIENES.ESTRATO_SDP_MARZO2022_CONLOTEO;
VIGENCIA = 2022;
KEEP BARMANPRE ESTRATO VIGENCIA;
RUN;

DATA LOTES_ESTRATO_SDP_2023;
SET BIENES.LOT_ESTRATO_SDP_2023;
VIGENCIA = 2023;
KEEP BARMANPRE ESTRATO VIGENCIA;
RUN;

DATA LOTES_ESTRATO_SDP_2024;
SET BIENES.LOTE_ESTRATO_SDP_MARZO2024;
VIGENCIA = 2024;
KEEP BARMANPRE ESTRATO VIGENCIA;
RUN;

DATA LOTES_ESTRATO_SDP_2025;
SET BIENES.LOT_ESTRATO_SDP_2025;
VIGENCIA = 2025;
KEEP BARMANPRE ESTRATO VIGENCIA;
RUN;

DATA BASE_ESTRATO_LOTE;
SET LOTES_ESTRATO_SDP_2023
ESTRATO_SDP_MARZO2022_CONLOTEO
LOTES_ESTRATO_SDP_2024
LOTES_ESTRATO_SDP_2025;
IF LENGTH(COMPRESS(BARMANPRE)) = 10;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   delete ESTRATO_SDP_MARZO2022_CONLOTEO LOTES_ESTRATO_SDP_2023 LOTES_ESTRATO_SDP_2024 LOTES_ESTRATO_SDP_2025;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 12: CONSOLIDACIÓN DE PREDIOS ATÍPICOS (ESTRATO ESPECIAL)                                              */
/* Propósito: Agregar información de predios con estrato asignado fuera de rangos normales                    */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*CONSOLIDANDO BASE ESTRATO ATIPICO*/

DATA PREDIO_ATIPICO_MARZO2022;
SET BIENES.PREDIO_ATIPICO_MARZO2022;
VIGENCIA=2022;
KEEP CHIP BARMANPRE VIGENCIA ESTRATO;
RUN;

DATA PREDIOS_ATIPICOS_SDP2023;
SET BIENES.PREDIOS_ATIPICOS_SDP2023;
VIGENCIA=2023;
KEEP CHIP BARMANPRE VIGENCIA ESTRATO;
RUN;

DATA PREDIOS_ATIPICOS_SDP2024;
SET BIENES.PREDIO_ATIPICO_SDP_MARZO2024;
VIGENCIA=2024;
KEEP CHIP BARMANPRE VIGENCIA ESTRATO;
RUN;

DATA PREDIOS_ATIPICOS_SDP2025;
SET BIENES.PREDIOS_ATIPICOS_SDP_2025;
VIGENCIA=2025;
KEEP CHIP BARMANPRE VIGENCIA ESTRATO;
RUN;

DATA BASE_ESTRATO_ATIPICO;
SET PREDIOS_ATIPICOS_SDP2025
PREDIOS_ATIPICOS_SDP2024
PREDIOS_ATIPICOS_SDP2023
PREDIO_ATIPICO_MARZO2022;
IF LENGTH(COMPRESS(BARMANPRE)) = 10;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   delete PREDIOS_ATIPICOS_SDP2025 PREDIOS_ATIPICOS_SDP2024 PREDIOS_ATIPICOS_SDP2023 PREDIO_ATIPICO_MARZO2022;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 13: CONSOLIDACIÓN DE BIENES DE INTERÉS CULTURAL (BIC)                                                 */
/* Propósito: Marcar inmuebles protegidos por su valor histórico-cultural                                      */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*CONSOLIDANDO INMUEBLES DE INTERES CULTURAL*/

PROC SQL;
CREATE TABLE INMUEBLE_INTERES_CULTURAL_2025
AS SELECT CODIGO_LOTE, 2025 AS VIGENCIA, 1 AS BIC
FROM BIENES.INMUEBLE_INTERES_CULTURAL_2025;
QUIT;

PROC SQL;
CREATE TABLE INMUEBLE_INTERES_CULTURAL_2024
AS SELECT CODIGO_LOTE, 2024 AS VIGENCIA, 1 AS BIC
FROM BIENES.INMUEBLE_IC_MARZO2024;
QUIT;

DATA INMUEBLE_INTERES_CULTURAL_2023;
SET BIENES.INMUEBLE_INTERES_CULTURAL_2023;
VIGENCIA=2023;
BIC=1;
KEEP CODIGO_LOTE VIGENCIA BIC;
RUN;

DATA INMUEBLE_INTERES_CULTURAL_2022;
SET BIENES.INMUEBLE_INTERES_CULTURAL;
VIGENCIA=2022;
BIC=1;
KEEP CODIGO_LOTE VIGENCIA BIC;
RUN;

DATA INMUEBLE_INTERES_CULTURAL;
SET INMUEBLE_INTERES_CULTURAL_2025
INMUEBLE_INTERES_CULTURAL_2024
INMUEBLE_INTERES_CULTURAL_2023
INMUEBLE_INTERES_CULTURAL_2022;
IF LENGTH(COMPRESS(CODIGO_LOTE)) = 10;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   delete INMUEBLE_INTERES_CULTURAL_2025 INMUEBLE_INTERES_CULTURAL_2024 INMUEBLE_INTERES_CULTURAL_2023 INMUEBLE_INTERES_CULTURAL_2022;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 14: ORDENAMIENTO Y DEDUPLICACIÓN DE BASES DE ESTRATO                                                  */
/* Propósito: Preparar bases para join con ofertas, eliminando duplicados por año                              */
/* NOTA: INFORMACIÓN DE LOTES Y BIENES DE INTERÉS CULTURAL                                                    */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

PROC SORT DATA=BASE_ESTRATO NODUPKEY;BY CODIGO_MANZANA VIGENCIA;RUN;
PROC SORT DATA=BASE_ESTRATO_LOTE OUT=ESTRATO_SDP_CONLOTEO NODUPKEY; BY BARMANPRE VIGENCIA;RUN;
PROC SORT DATA=BASE_ESTRATO_ATIPICO OUT=PREDIO_ATIPICO NODUPKEY; BY BARMANPRE VIGENCIA;RUN;
PROC SORT DATA=INMUEBLE_INTERES_CULTURAL OUT=INMUEBLE_INTERES_CULTURAL NODUPKEY; BY CODIGO_LOTE VIGENCIA;RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 15: ENRIQUECIMIENTO INICIAL CON ESTRATO Y BIENES ESPECIALES                                          */
/* Propósito: Agregar información de estrato y BIC a base consolidada de ofertas                              */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

PROC SQL; 
CREATE TABLE BASE_OFT_CONSOLIDADA
AS SELECT 
A.*,
B.ESTRATO AS ESTRATO_ATIPICO,
D.ESTRATO AS ESTRATO_SDP,
E.ESTRATO AS ESTRATO_SDP_MZN,
C.BIC
/*CASE WHEN LENGTH(COMPRESS(C.CODIGO_LOTE)) > 2 THEN 1 ELSE 0 END AS BIC*/
FROM (SELECT * FROM BASE_OFT_CONSOLIDADA) AS A
LEFT JOIN (SELECT * FROM PREDIO_ATIPICO) AS B
ON A.BARMANPRE = B.BARMANPRE AND A.VIGENCIA = B.VIGENCIA
LEFT JOIN (SELECT * FROM INMUEBLE_INTERES_CULTURAL) AS C
ON A.BARMANPRE = C.CODIGO_LOTE AND A.VIGENCIA = C.VIGENCIA
LEFT JOIN (SELECT * FROM ESTRATO_SDP_CONLOTEO) AS D
ON A.BARMANPRE = D.BARMANPRE AND A.VIGENCIA = D.VIGENCIA
LEFT JOIN (SELECT * FROM BASE_ESTRATO) AS E
ON SUBSTR(A.BARMANPRE,1,8) = E.CODIGO_MANZANA AND A.VIGENCIA = E.VIGENCIA
;
QUIT;

/* SECCIÓN 15.1: Aplicación de jerarquía para estrato final */
DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
ESTRATO_FIN = ESTRATO_ATIPICO;
/*IF ESTRATO_FIN IN ( .,0) THEN ESTRATO_FIN = ESTRATO_ATIPICO;*/
IF ESTRATO_FIN IN (., 0) THEN ESTRATO_FIN = ESTRATO_SDP;
IF ESTRATO_FIN IN ( .,0) THEN ESTRATO_FIN = ESTRATO_SDP_MZN;
IF ESTRATO_FIN IN (., 0) THEN ESTRATO_FIN = ESTRATO;
IF ESTRATO_FIN NOT IN (0, 1, 2, 3, 4, 5, 6) THEN ESTRATO_FIN = .;
IF ESTRATO NOT IN (0, 1, 2, 3, 4, 5, 6) THEN ESTRATO = .;
IF BIC = 1 THEN ESTRATO_FIN = 10;
/*IF ESTRATO_1 IN ( .,0) THEN ESTRATO_1 = ESTRATO_SDP;*/
RUN;

DATA BASE_OFT_CONSOLIDADA;
SET BASE_OFT_CONSOLIDADA;
IF TIPO_INMUEBLE NOT IN ("CASA_USO_MIXTO", "CASA", "APARTAMENTO", "CASA_CAMPESTRE", "CASA_LOTE") THEN ESTRATO_FIN = .;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   delete BASE_ESTRATO BASE_ESTRATO_LOTE BASE_ESTRATO_ATIPICO INMUEBLE_INTERES_CULTURAL ESTRATO_SDP_CONLOTEO PREDIO_ATIPICO;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 16: PROCESAMIENTO DE INFORMACIÓN PREDIAL DESDE SIIC                                                   */
/* Propósito: Obtener clase de predio, ubicación, lotes e información ZHF por vigencia                       */
/* NOTA TÉCNICA: El siguiente bloque genera una base con la información de las clases de predios a nivel de   */
/*               BARMANPRE (10 dígitos). Históricamente se procesaban vigencias 17-23, ahora solo 24-25       */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*%PROCESS_PREDIO(17);
%PROCESS_PREDIO(18);
%PROCESS_PREDIO(19);
%PROCESS_PREDIO(20);
%PROCESS_PREDIO(21);
%PROCESS_PREDIO(22);
%PROCESS_PREDIO(23);*/
%PROCESS_PREDIO(24);
%PROCESS_PREDIO(25);

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   /*delete PREDIO_FINAL_17 PREDIO_FINAL_18 PREDIO_FINAL_19 PREDIO_FINAL_20 PREDIO_FINAL_21 PREDIO_FINAL_22 PREDIO_FINAL_23 PREDIO_FINAL_24;*/
   delete PREDIO_FINAL_24 PREDIO_FINAL_25;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* SECCIÓN 16.2: Información a nivel de lote proveniente de cartografía */

/*%PROCESS_LOTES(17);
%PROCESS_LOTES(18);
%PROCESS_LOTES(19);
%PROCESS_LOTES(20);
%PROCESS_LOTES(21);
%PROCESS_LOTES(22);
%PROCESS_LOTES(23);*/
%PROCESS_LOTES(24);
%PROCESS_LOTES(25);

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   /*delete LOTES_2017 LOTES_2018 LOTES_2019 LOTES_2020 LOTES_2021 LOTES_2022 LOTES_2023 LOTES_2024;*/
   delete LOTES_2024 LOTES_2025;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* SECCIÓN 16.3: Información de ZHF a nivel de lote (Zonas de Histórico Forestal) */

/*%PROCESS_ZHF(17);
%PROCESS_ZHF(18);
%PROCESS_ZHF(19);
%PROCESS_ZHF(20);
%PROCESS_ZHF(21);
%PROCESS_ZHF(22);
%PROCESS_ZHF(23);*/
%PROCESS_ZHF(24);
%PROCESS_ZHF(25);

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

proc datasets library=work;
   /*delete RESOLUCION_PREDIO_DIG_17 RESOLUCION_PREDIO_DIG_18 RESOLUCION_PREDIO_DIG_19 RESOLUCION_PREDIO_DIG_20 RESOLUCION_PREDIO_DIG_21 RESOLUCION_PREDIO_DIG_22
   RESOLUCION_PREDIO_DIG_23 RESOLUCION_PREDIO_DIG_24;*/
	delete RESOLUCION_PREDIO_DIG_24 RESOLUCION_PREDIO_DIG_25;
run;
quit;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 17: ENRIQUECIMIENTO CON INFORMACIÓN PREDIAL COMPLETA DESDE SIIC                                      */
/* Propósito: Realizar join con bases prediales (clase, ubicación, coordenadas, ZHF)                         */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

PROC SQL;
CREATE TABLE BASE_OFT_CONSOLIDADA_2 AS SELECT 
A.*, 
B.CLASE_PREDIO AS CLASE_PREDIO_SIIC,
C.CODIGO_BARRIO,
C.NOMBRE_BARRIO,
C.CODIGO_UPZ, 
C.NOMBRE_UPZ,
C.CODIGO_LOCALIDAD,
C.NOMBRE_LOCALIDAD, 
C.LONGITUD_SIIC,
C.LATITUD_SIIC,
D.ZHF
FROM BASE_OFT_CONSOLIDADA AS A
LEFT JOIN PREDIO_FINAL AS B 
ON A.BARMANPRE = B.BARMANPRE AND A.VIGENCIA = B.VIGENCIA
LEFT JOIN LOTES AS C
ON A.BARMANPRE = C.BARMANPRE AND A.VIGENCIA = C.VIGENCIA
LEFT JOIN RESOLUCION_PREDIO_DIG AS D 
ON A.BARMANPRE = D.BARMANPRE AND A.VIGENCIA = D.VIGENCIA;
QUIT;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 18: ASIGNACIÓN DE CLASE DE PREDIO (PARTIAL vs COMPLETO)                                              */
/* Propósito: Clasificar predios como P (sin construcción) o N (con construcción)                             */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_3;
SET BASE_OFT_CONSOLIDADA_2;
IF TIPO_INMUEBLE IN ('APARTAMENTO', 'LOCAL', 'OFICINA') OR CLASE_PREDIO_SIIC = "P" THEN CLASE_PREDIO_OFT = "P"; ELSE CLASE_PREDIO_OFT = "N";
IF TIPO_INMUEBLE = "LOTE" THEN CLASE_PREDIO_OFT = "N";
IF TIPO_INMUEBLE = "HABITACION" AND CLASE_PREDIO_OFT NOT IN ("P") THEN CLASE_PREDIO_OFT = "";
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_2 BASE_OFT_CONSOLIDADA;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 19: DETECCIÓN DE PRECIOS CONSECUTIVOS                                                                  */
/* Propósito: Identificar precios que son múltiplos o secuencias (baja calidad)                               */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

PROC SQL;
CREATE TABLE BASE_PRECIOS AS SELECT DISTINCT PRECIO 
FROM BASE_OFT_CONSOLIDADA_3 
WHERE PRECIO NOT IN (0, .) AND PRECIO > 1000 AND PRECIO NOT IN (SELECT DISTINCT PRECIO FROM BIENES.BASE_PRECIOS_CONSECUTIVOS_OFT);
QUIT;

/*
%MASSIVE_INDEX(BASE_PRECIOS);

PROC SORT DATA=BASE_FINAL NODUPKEY; BY PRECIO; RUN;*/

DATA BIENES.BASE_PRECIOS_CONSECUTIVOS_OFT;
SET BIENES.BASE_PRECIOS_CONSECUTIVOS_OFT;
/*BASE_FINAL;*/
RUN;

PROC SORT DATA=BIENES.BASE_PRECIOS_CONSECUTIVOS_OFT NODUPKEY; BY PRECIO;RUN;

PROC SQL;
CREATE TABLE BASE_OFT_CONSOLIDADA_4 AS SELECT A.*, B.INDICE
FROM BASE_OFT_CONSOLIDADA_3 AS A 
LEFT JOIN BIENES.BASE_PRECIOS_CONSECUTIVOS_OFT AS B 
ON A.PRECIO = B.PRECIO;
QUIT;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 20: CÁLCULO DE TRIMESTRE Y FLAGS DE COORDENADAS                                                       */
/* Propósito: Extraer trimestre de fecha y marcar registros sin coordenadas                                  */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_5;
SET BASE_OFT_CONSOLIDADA_4;
TRIMESTRE = QTR(FECHA);
IF LONGITUD IN (0, .) THEN LONGITUD_NULL = 1; ELSE LONGITUD_NULL = 0;
IF LATITUD IN (0, .) THEN LATITUD_NULL = 1; ELSE LATITUD_NULL = 0;
IF INDICE IN (0, 1) THEN PRECIO_CONSECUTIVO = 1; ELSE PRECIO_CONSECUTIVO = 0;
DROP INDICE;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_4 BASE_OFT_CONSOLIDADA_3 BASE_PRECIOS BASE_FINAL;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 21: ASIGNACIÓN DE JERARQUÍA POR FUENTE                                                                 */
/* Propósito: Establecer orden de prioridad (OIC > GI > FR > M2 > CC > Properati)                             */
/* NOTA: En la siguiente parte se verifican las ofertas duplicadas (ofertas que corresponden al mismo predio   */
/*       en un periodo de tiempo). Sección NPH y DENTRO DE FUENTES (DF)                                        */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_5;
SET BASE_OFT_CONSOLIDADA_5;
IF NOMBRE_FUENTE = 'OIC' THEN JERARQUIA = 1;
IF NOMBRE_FUENTE = 'GALERIA_INMOBILIARIA' THEN JERARQUIA = 2;
IF NOMBRE_FUENTE = 'FINCA_RAIZ' THEN JERARQUIA = 3;
IF NOMBRE_FUENTE = 'METRO_CUADRADO' THEN JERARQUIA = 4;
IF NOMBRE_FUENTE = 'CIEN_CUADRAS' THEN JERARQUIA = 5;
IF NOMBRE_FUENTE = 'PROPERATI' THEN JERARQUIA = 6;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 22: IDENTIFICACIÓN DE DUPLICADOS DENTRO DE FUENTES (DF) - CLASE N                                    */
/* Propósito: Detectar ofertas duplicadas del mismo predio en la misma fuente/trimestre                      */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA REPET_FUENTE_NPH; 
SET BASE_OFT_CONSOLIDADA_5;
IF CLASE_PREDIO_OFT = 'N';
LLAVE_AJUSTE_FUENTE = COMPRESS(BARMANPRE||"_"||NOMBRE_FUENTE||"_"||TIPO_OFERTA||"_"||TIPO_INMUEBLE||"_"||YEAR||"_"||TRIMESTRE);
RUN;

PROC SORT DATA= REPET_FUENTE_NPH; BY LLAVE_AJUSTE_FUENTE DESCENDING FECHA; RUN;

DATA REPET_FUENTE_NPH_2;
SET REPET_FUENTE_NPH;
BY LLAVE_AJUSTE_FUENTE;
IF FIRST.LLAVE_AJUSTE_FUENTE THEN DUPLICADO_DF = 1;  ELSE DUPLICADO_DF = 0;
RUN;

/* SECCIÓN 22.1: Re-asignación de ganador cuando registro seleccionado tiene precio incompleto */
/* En esta parte se hace la reasignación de la variable DUPLICADO_DF para aquellos casos en que el registro */
/* seleccionado no tiene precio o tiene un precio incosistente */

DATA REPET_FUENTE_NPH_2;
SET REPET_FUENTE_NPH_2;
CONSECUTIVO + 1;
  by LLAVE_AJUSTE_FUENTE;
  if first.LLAVE_AJUSTE_FUENTE then CONSECUTIVO = 1;
RUN;

PROC SQL;
CREATE TABLE REVISA_NPH AS SELECT LLAVE_AJUSTE_FUENTE, COUNT(*) AS N
FROM REPET_FUENTE_NPH_2
GROUP BY LLAVE_AJUSTE_FUENTE
HAVING N > 1
ORDER BY  N DESC;
QUIT;

PROC SQL;
CREATE TABLE REVISA_NPH_2 AS SELECT *
FROM REPET_FUENTE_NPH_2
WHERE LLAVE_AJUSTE_FUENTE IN (SELECT LLAVE_AJUSTE_FUENTE FROM REVISA_NPH) AND 
(SIN_PRECIO = 1 OR PRECIO_CONSECUTIVO = 1) AND DUPLICADO_DF = 1;
QUIT;

PROC SQL;
CREATE TABLE REVISA_NPH_3 AS SELECT *
FROM REPET_FUENTE_NPH_2
WHERE LLAVE_AJUSTE_FUENTE IN (SELECT LLAVE_AJUSTE_FUENTE FROM REVISA_NPH) AND 
(SIN_PRECIO = 0 AND PRECIO_CONSECUTIVO = 0);
QUIT;

PROC SQL;
CREATE TABLE INTEREXCHANGE_ROWS AS SELECT DISTINCT LLAVE_AJUSTE_FUENTE, COMPRESS(CAT(LLAVE_AJUSTE_FUENTE,"_",MIN(CONSECUTIVO))) AS LLAVE_CONSECUTIVO
FROM REPET_FUENTE_NPH_2 
WHERE SIN_PRECIO = 0 AND PRECIO_CONSECUTIVO = 0 AND 
LLAVE_AJUSTE_FUENTE IN (SELECT LLAVE_AJUSTE_FUENTE FROM REVISA_NPH) AND 
LLAVE_AJUSTE_FUENTE IN (SELECT LLAVE_AJUSTE_FUENTE FROM REVISA_NPH_2) AND 
LLAVE_AJUSTE_FUENTE IN (SELECT LLAVE_AJUSTE_FUENTE FROM REVISA_NPH_3)
GROUP BY LLAVE_AJUSTE_FUENTE;
QUIT;

PROC SQL;
CREATE TABLE REPET_FUENTE_NPH_3 AS SELECT *, 
CASE WHEN LLAVE_AJUSTE_FUENTE IN (SELECT DISTINCT LLAVE_AJUSTE_FUENTE FROM INTEREXCHANGE_ROWS)
THEN 0 ELSE DUPLICADO_DF END AS DUPLICADO_DF_COPY
FROM REPET_FUENTE_NPH_2;
/*WHERE LLAVE_AJUSTE_FUENTE IN (SELECT DISTINCT LLAVE_AJUSTE_FUENTE FROM INTEREXCHANGE_ROWS);*/
QUIT;

data REPET_FUENTE_NPH_3;
set REPET_FUENTE_NPH_3;
DROP DUPLICADO_DF;
RUN;

PROC SQL;
CREATE TABLE REPET_FUENTE_NPH_2 AS SELECT *, 
CASE WHEN COMPRESS(CAT(LLAVE_AJUSTE_FUENTE, "_", CONSECUTIVO)) IN (SELECT DISTINCT LLAVE_CONSECUTIVO FROM INTEREXCHANGE_ROWS) 
THEN 1 ELSE DUPLICADO_DF_COPY END AS DUPLICADO_DF
FROM REPET_FUENTE_NPH_3;
QUIT;

DATA REPET_FUENTE_NPH_2;
SET REPET_FUENTE_NPH_2;
DROP DUPLICADO_DF_COPY;
RUN;

/*PROC SORT DATA= REPET_FUENTE_NPH_2; BY BARMANPRE NOMBRE_FUENTE TIPO_OFERTA TIPO_INMUEBLE YEAR TRIMESTRE JERARQUIA DESCENDING FECHA; RUN;*/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 23: IDENTIFICACIÓN DE DUPLICADOS DENTRO DE FUENTES (DF) - CLASE P                                    */
/* Propósito: Detectar duplicados para predios sin construcción (apartamentos, oficinas, etc)                 */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/* Sección PH y DENTRO DE FUENTES (DF) */

/***************************************/
proc datasets library=work;
   delete DF DF2 DF3 PREDIO_FINAL LOTES RESOLUCION_PREDIO_DIG;
run;
quit;
/***************************************/

DATA INFO.REPET_FUENTE_PH; 
SET BASE_OFT_CONSOLIDADA_5;
IF CLASE_PREDIO_OFT = 'P';
LLAVE_AJUSTE_FUENTE = COMPRESS(BARMANPRE||"_"||TIPO_OFERTA||"_"||NOMBRE_FUENTE||"_"||TIPO_INMUEBLE||"_"||YEAR||"_"||TRIMESTRE||"_"||AREA_CONSTRUIDA||"_"||PRECIO);
RUN;

PROC SORT DATA= INFO.REPET_FUENTE_PH; BY LLAVE_AJUSTE_FUENTE JERARQUIA DESCENDING FECHA; RUN;

DATA REPET_FUENTE_PH_2; 
SET INFO.REPET_FUENTE_PH;
BY LLAVE_AJUSTE_FUENTE;
IF FIRST.LLAVE_AJUSTE_FUENTE THEN DUPLICADO_DF= 1;  ELSE DUPLICADO_DF=0;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 24: CONSOLIDACIÓN NPH Y PH CON MARCAS DE DUPLICADOS DENTRO DE FUENTES                                  */
/* Propósito: Unir ambas clases de predios con sus respectivos flags de duplicidad                             */
/* NOTA: ***  CONSOLIDA NPH Y PH CON MARCA DE REPETIDOS EN CADA FUENTE  ***                                   */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA REPET_FUENTE_NPH_2;
SET REPET_FUENTE_NPH_2;
RENAME LLAVE_AJUSTE_FUENTE = LLAVE_AJUSTE;
DROP CONSECUTIVO;
RUN;

DATA BASE_OFT_CONSOLIDADA_6; 
SET REPET_FUENTE_NPH_2 REPET_FUENTE_PH_2;
DROP LLAVE_AJUSTE_FUENTE;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete REPET_FUENTE_NPH REPET_FUENTE_PH REPET_FUENTE_NPH_2 REPET_FUENTE_PH_2 REPET_FUENTE_NPH_3 REVISA_NPH REVISA_NPH_2 REVISA_NPH_3 INTEREXCHANGE_ROWS;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 25: IDENTIFICACIÓN DE DUPLICADOS ENTRE FUENTES (EF) - CLASE N                                        */
/* Propósito: Detectar mismo predio en diferentes fuentes, aplicar jerarquía                                   */
/* NOTA: /*******************************************/
         /***  BARMANPRE REPETIDOS ENTRE FUENTES  ***/
         /*******************************************/
         /*ASIGNACION DE JERARQUIAS*/
         /*DATA BASE_OFT_CONSOLIDADA_6;*/
         /*SET BASE_OFT_CONSOLIDADA_6;*/
         /*IF NOMBRE_FUENTE = 'OIC' THEN JERARQUIA = 1;*/
         /*IF NOMBRE_FUENTE = 'GALERIA INMOBIL' THEN JERARQUIA = 2;*/
         /*IF NOMBRE_FUENTE = 'FINCA RAIZ' THEN JERARQUIA = 3;*/
         /*IF NOMBRE_FUENTE = 'METRO_CUADRADO' THEN JERARQUIA = 4;*/
         /*IF NOMBRE_FUENTE = 'CIEN CUADRAS' THEN JERARQUIA = 5;*/
         /*IF NOMBRE_FUENTE = 'PROPERATI' THEN JERARQUIA = 6;*/
         /*RUN;*/
         /***  DEPURACION NPH ENTRE FUENTE   ***/
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA REPETIDOS_NPH; 
SET BASE_OFT_CONSOLIDADA_6;
IF CLASE_PREDIO_OFT = 'N';
LLAVE_AJUSTE = COMPRESS(BARMANPRE||"_"||TIPO_OFERTA||"_"||TIPO_INMUEBLE||"_"||YEAR||"_"||TRIMESTRE);
RUN;

PROC SORT DATA= REPETIDOS_NPH; BY LLAVE_AJUSTE JERARQUIA DESCENDING FECHA; RUN;

DATA REPETIDOS_NPH_2; 
SET REPETIDOS_NPH;
BY LLAVE_AJUSTE;
IF FIRST.LLAVE_AJUSTE THEN DUPLICADO_EF = 1;  ELSE DUPLICADO_EF = 0;
RUN;

DATA REPETIDOS_NPH_2;
SET REPETIDOS_NPH_2;
CONSECUTIVO + 1;
  by LLAVE_AJUSTE;
  if first.LLAVE_AJUSTE then CONSECUTIVO = 1;
RUN;

PROC SQL;
CREATE TABLE REVISA_NPH AS SELECT LLAVE_AJUSTE, COUNT(*) AS N
FROM REPETIDOS_NPH_2
GROUP BY LLAVE_AJUSTE
HAVING N > 1
ORDER BY  N DESC;
QUIT;

PROC SQL;
CREATE TABLE REVISA_NPH_2 AS SELECT *
FROM REPETIDOS_NPH_2
WHERE LLAVE_AJUSTE IN (SELECT LLAVE_AJUSTE FROM REVISA_NPH) AND 
(SIN_PRECIO = 1 OR PRECIO_CONSECUTIVO = 1) AND DUPLICADO_EF = 1;
QUIT;

PROC SQL;
CREATE TABLE REVISA_NPH_3 AS SELECT *
FROM REPETIDOS_NPH_2
WHERE LLAVE_AJUSTE IN (SELECT LLAVE_AJUSTE FROM REVISA_NPH) AND 
(SIN_PRECIO = 0 AND PRECIO_CONSECUTIVO = 0) AND DUPLICADO_EF = 0;
QUIT;

PROC SQL;
CREATE TABLE INTEREXCHANGE_ROWS_EF AS SELECT DISTINCT LLAVE_AJUSTE, COMPRESS(CAT(LLAVE_AJUSTE,"_",MIN(CONSECUTIVO))) AS LLAVE_CONSECUTIVO
FROM REPETIDOS_NPH_2 
WHERE SIN_PRECIO = 0 AND PRECIO_CONSECUTIVO = 0 AND 
LLAVE_AJUSTE IN (SELECT LLAVE_AJUSTE FROM REVISA_NPH) AND 
LLAVE_AJUSTE IN (SELECT LLAVE_AJUSTE FROM REVISA_NPH_2) AND 
LLAVE_AJUSTE IN (SELECT LLAVE_AJUSTE FROM REVISA_NPH_3)
GROUP BY LLAVE_AJUSTE;
QUIT;

PROC SQL;
CREATE TABLE REPETIDOS_NPH_3 AS SELECT *, 
CASE WHEN LLAVE_AJUSTE IN (SELECT DISTINCT LLAVE_AJUSTE FROM INTEREXCHANGE_ROWS_EF)
THEN 0 ELSE DUPLICADO_EF END AS DUPLICADO_EF_COPY
FROM REPETIDOS_NPH_2;
QUIT;

data REPETIDOS_NPH_3;
set REPETIDOS_NPH_3;
DROP DUPLICADO_EF;
RUN;

PROC SQL;
CREATE TABLE REPETIDOS_NPH_2 AS SELECT *, 
CASE WHEN COMPRESS(CAT(LLAVE_AJUSTE, "_", CONSECUTIVO)) IN (SELECT DISTINCT LLAVE_CONSECUTIVO FROM INTEREXCHANGE_ROWS_EF) 
THEN 1 ELSE DUPLICADO_EF_COPY END AS DUPLICADO_EF
FROM REPETIDOS_NPH_3;
QUIT;

data REPETIDOS_NPH_2;
set REPETIDOS_NPH_2;
DROP DUPLICADO_EF_COPY CONSECUTIVO;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete REPETIDOS_NPH_3 INTEREXCHANGE_ROWS_EF REVISA_NPH_3 REVISA_NPH_2 REVISA_NPH REPETIDOS_NPH;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 26: IDENTIFICACIÓN DE DUPLICADOS ENTRE FUENTES (EF) - CLASE P                                        */
/* Propósito: Detectar duplicados entre fuentes para predios sin construcción                                */
/* NOTA: /***  DEPURACION PH ***/
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA REPETIDOS_PH; /* 2.240.257 */
SET BASE_OFT_CONSOLIDADA_6;
IF CLASE_PREDIO_OFT = 'P';
LLAVE_AJUSTE = COMPRESS(BARMANPRE||"_"||TIPO_OFERTA||"_"||TIPO_INMUEBLE||"_"||YEAR||"_"||TRIMESTRE||"_"||AREA_CONSTRUIDA||"_"||PRECIO);
RUN;

PROC SORT DATA= REPETIDOS_PH; BY LLAVE_AJUSTE JERARQUIA DESCENDING FECHA ; RUN;

DATA REPETIDOS_PH_2; /* 2.240.257 */
SET REPETIDOS_PH;
BY LLAVE_AJUSTE;
IF FIRST.LLAVE_AJUSTE THEN DUPLICADO_EF = 1;  ELSE DUPLICADO_EF = 0;
RUN;

DATA REPET_FUENTE_SIN_CP;
SET BASE_OFT_CONSOLIDADA_5;
IF CLASE_PREDIO_OFT NOT IN ('N', 'P');
DUPLICADO_DF = .;
DUPLICADO_EF = .;
RUN;

DATA BASE_OFT_CONSOLIDADA_7;
SET REPETIDOS_PH_2 REPETIDOS_NPH_2 REPET_FUENTE_SIN_CP;
RUN; 

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_5 BASE_OFT_CONSOLIDADA_6 REPETIDOS_PH_2 REPETIDOS_NPH_2 REPET_FUENTE_SIN_CP; 
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 27: CONSULTA Y ENRIQUECIMIENTO CON INFORMACIÓN PREDIAL SIIC DETALLADA                                  */
/* Propósito: Agregar información extendida de catastro a nivel de sector                                     */
/* NOTA CRÍTICA: Esta macro incluye información de la base catastral a nivel de predio para cruces a 18      */
/*               posiciones y predios con CLASE_PREDIO_SIIC = "N"                                             */
/*               Históricamente se procesaban vigencias 17-23, ahora solo 24-25                               */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*%CONSULTA_INFO_VIG(17);
%CONSULTA_INFO_VIG(18);
%CONSULTA_INFO_VIG(19);
%CONSULTA_INFO_VIG(20);
%CONSULTA_INFO_VIG(21);
%CONSULTA_INFO_VIG(22);
%CONSULTA_INFO_VIG(23);*/
%CONSULTA_INFO_VIG(24);
%CONSULTA_INFO_VIG(25);

PROC SQL;
CREATE TABLE BASE_OFT_CONSOLIDADA_8 AS SELECT A.*, B.AREA_CONSTRUIDA_SIIC, B.ESTRATO_SIIC, B.AREA_TERRENO_SIIC, B.PUNTAJE AS PUNTAJE_SIIC,
B.CODIGO_USOP AS CODIGO_USOP_SIIC, CODIGO_DESTINO_SIIC, DIRECCION_REAL AS DIRECCION_SIIC, NUMERO_PISO_SIIC,
B.VETUSTEZ AS VETUSTEZ_SIIC
FROM BASE_OFT_CONSOLIDADA_7 AS A 
LEFT JOIN INFO_SIIC AS B 
ON A.CODIGO_SECTOR = B.CODIGO_SECTOR AND A.VIGENCIA = B.VIGENCIA;
QUIT;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_7 ;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 28: ENRIQUECIMIENTO AUXILIAR CON DATOS DE DUPLICADOS (ÁREA Y ANTIGÜEDAD)                               */
/* Propósito: Completar campos faltantes usando información de ofertas duplicadas                              */
/* NOTA: El siguiente bloque busca pegar información de duplicados como información auxiliar.                 */
/*       Las variables consideradas son la edad y área construida.                                             */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA ROWS_WITH_NONULL_AREA_EF;
SET BASE_OFT_CONSOLIDADA_8;
IF ((SIN_AREA_CONSTRUIDA NOT IN (., 0)) AND (AREA_CONSTRUIDA > 0) AND (DUPLICADO_EF = 0));
RUN;

PROC SORT DATA=ROWS_WITH_NONULL_AREA_EF NODUPKEY; BY LLAVE_AJUSTE; RUN;

DATA ROWS_WITH_NONULL_EDAD_EF;
SET BASE_OFT_CONSOLIDADA_8;
IF ANTIGUEDAD_INMUEBLE NOT IN (.) AND ANTIGUEDAD_INMUEBLE < 30 AND DUPLICADO_EF = 0;
RUN;

PROC SORT DATA=ROWS_WITH_NONULL_AREA_EF NODUPKEY; BY LLAVE_AJUSTE; RUN;
PROC SORT DATA=ROWS_WITH_NONULL_EDAD_EF NODUPKEY; BY LLAVE_AJUSTE; RUN;

PROC SQL;
CREATE TABLE BASE_OFT_CONSOLIDADA_9 AS SELECT A.*,
CASE WHEN (A.DUPLICADO_EF = 1) AND (A.SIN_AREA_CONSTRUIDA = 1) THEN B.AREA_CONSTRUIDA
ELSE .  END AS AREA_CONS_OTRA_FUENTE, 
CASE WHEN (A.DUPLICADO_EF = 1) AND (A.SIN_AREA_CONSTRUIDA = 1) THEN B.NOMBRE_FUENTE
ELSE ""  END AS NOMBRE_FUENTE_AREA, 
CASE WHEN (A.DUPLICADO_EF = 1) AND (A.ANTIGUEDAD_INMUEBLE IN (.)) THEN C.ANTIGUEDAD_INMUEBLE
ELSE .  END AS ANTIGUEDAD_OTRA_FUENTE, 
CASE WHEN (A.DUPLICADO_EF = 1) AND (A.ANTIGUEDAD_INMUEBLE IN (.)) THEN C.NOMBRE_FUENTE
ELSE ""  END AS NOMBRE_FUENTE_EDAD
FROM BASE_OFT_CONSOLIDADA_8 AS A 
LEFT JOIN ROWS_WITH_NONULL_AREA_EF AS B 
ON A.LLAVE_AJUSTE = B.LLAVE_AJUSTE
LEFT JOIN ROWS_WITH_NONULL_EDAD_EF AS C
ON A.LLAVE_AJUSTE = C.LLAVE_AJUSTE;
QUIT;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_8 ROWS_WITH_NONULL_AREA_EF ROWS_WITH_NONULL_EDAD_EF;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 29: DERIVACIÓN DE CAMPOS FINALES (ÁREAS, ANTIGÜEDAD, CLASE DE PREDIO)                                 */
/* Propósito: Calcular campos derivados con jerarquía de fuentes                                              */
/* NOTA: ACÁ INICIA LA VALIDACIÓN DE ÁREAS Y PRECIOS                                                           */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_10;
SET BASE_OFT_CONSOLIDADA_9;
ANTIGUEDAD_INMUEBLE_SIIC = YEAR - VETUSTEZ_SIIC;
ANTIGUEDAD_INMUEBLE_FIN = ANTIGUEDAD_INMUEBLE_SIIC;
IF ANTIGUEDAD_INMUEBLE_FIN > 1800 THEN ANTIGUEDAD_INMUEBLE_FIN = .;
IF ANTIGUEDAD_INMUEBLE_FIN = . THEN ANTIGUEDAD_INMUEBLE_FIN = ANTIGUEDAD_INMUEBLE;
IF NUMERO_PISO_FIN IN (0, .) AND NUMERO_PISOS NOT IN (0, .) THEN NUMERO_PISO_FIN = NUMERO_PISOS;
AREA_CONSTRUIDA_FIN = AREA_CONSTRUIDA_SIIC;
IF AREA_CONSTRUIDA_FIN = . THEN AREA_CONSTRUIDA_FIN = AREA_CONSTRUIDA;
AREA_TERRENO_FIN = AREA_TERRENO_SIIC;
IF AREA_TERRENO_FIN = . THEN AREA_TERRENO_FIN = AREA_TERRENO;
CLASE_PREDIO_FIN = CLASE_PREDIO_SIIC;
IF CLASE_PREDIO_FIN IN ("", " ") THEN CLASE_PREDIO_FIN = CLASE_PREDIO_OFT;
IF COMPRESS(TIPO_INMUEBLE) = "LOTE" THEN CLASE_PREDIO_FIN = "N";
IF COMPRESS(TIPO_INMUEBLE) = "LOTE" THEN CLASE_PREDIO_OFT = "N";
LONGITUD_FIN = LONGITUD_SIIC;
IF LONGITUD_FIN = . AND LONGITUD NOT IN (0, .) THEN LONGITUD_FIN = LONGITUD;
LATITUD_FIN = LATITUD_SIIC;
IF LATITUD_FIN = . AND LATITUD NOT IN (0, .) THEN LATITUD_FIN = LATITUD;
IF TIPO_INMUEBLE IN ("LOTE", "FINCA") AND AREA_TERRENO_FIN IN (0, .) THEN AREA_TERRENO_FIN = AREA_CONSTRUIDA_FIN;
IF TIPO_INMUEBLE IN ("LOTE", "FINCA") THEN AREA_CONSTRUIDA_FIN = 0;
IF AREA_TERRENO = 0  AND CLASE_PREDIO_OFT = "P" THEN AREA_TERRENO = .;
IF AREA_TERRENO_FIN = 0  AND CLASE_PREDIO_FIN = "P" THEN AREA_TERRENO_FIN = .;
IF CODIGO_BARRIO = "000000" THEN CODIGO_BARRIO = "";
IF NOMBRE_BARRIO = "0" THEN NOMBRE_BARRIO = "";
IF NOMBRE_UPZ = "0" THEN NOMBRE_UPZ = "";
DIRECCION_FIN = DIRECCION_SIIC;
IF LENGTH(COMPRESS(DIRECCION_FIN)) < 2 AND LENGTH(COMPRESS(DIRECCION)) THEN DIRECCION_FIN = DIRECCION;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_9 ;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 30: VALIDACIÓN COMPLEJA DE ÁREAS, PRECIOS Y ANTIGÜEDAD                                                */
/* Propósito: Crear marcas de validación para datos atípicos por tipo inmueble y clase                      */
/* NOTA: ***  VALIDADORES AREA Y PRECIO  ***  */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_11;
SET BASE_OFT_CONSOLIDADA_10;

/* BLOQUE 30.1: VALIDACIONES AREA CONSTRUIDA */
/*FORMAT out_con $CHAR1.;*/

MARCA_AREA_C = 0;
IF ((AREA_CONSTRUIDA_FIN IN (.) AND TIPO_INMUEBLE IN ("APARTAMENTO", "CASA", "CASA_USO_MIXTO", "CASA_CAMPESTRE", "CASA_LOTE", "OFICINA", "LOCAL", "BODEGA", "EDIFICIO", "PARQUEADERO-LAVA_AUTOS", "INMUEBLE_COMERCIAL", "DEPOSITO", "HABITACION", "GARAJE", "CABANA")) |
(TIPO_INMUEBLE='APARTAMENTO' AND CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 15 | AREA_CONSTRUIDA_FIN > 1000)) |
(TIPO_INMUEBLE='CASA' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 36 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='CASA' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 27 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='CASA_USO_MIXTO' AND (AREA_CONSTRUIDA_FIN <= 100 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='CASA_CAMPESTRE' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 200 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='CASA_CAMPESTRE' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 200 | AREA_CONSTRUIDA_FIN > 1000)) |
(TIPO_INMUEBLE='CASA_LOTE' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 36 | AREA_CONSTRUIDA_FIN > 500)) |
(TIPO_INMUEBLE='OFICINA' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 5 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='OFICINA' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 5 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='LOCAL' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 1.2 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='LOCAL' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 1.2 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='BODEGA' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 100 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='BODEGA' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 500 | AREA_CONSTRUIDA_FIN > 100000)) |
(TIPO_INMUEBLE='EDIFICIO' & (AREA_CONSTRUIDA_FIN <= 500 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='PARQUEADERO-LAVA_AUTOS' & (AREA_CONSTRUIDA_FIN <= 500 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='INMUEBLE_COMERCIAL' & (AREA_CONSTRUIDA_FIN <= 500 | AREA_CONSTRUIDA_FIN > 20000)) |
(TIPO_INMUEBLE='DEPOSITO' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 72 | AREA_CONSTRUIDA_FIN > 1000)) |
(TIPO_INMUEBLE='DEPOSITO' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 100 | AREA_CONSTRUIDA_FIN > 2000)) |
(TIPO_INMUEBLE='HABITACION' & AREA_CONSTRUIDA_FIN > 5) |
(TIPO_INMUEBLE='GARAJE' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 8 | AREA_CONSTRUIDA_FIN > 50)) |
(TIPO_INMUEBLE='CABANA' & CLASE_PREDIO_OFT = "P" AND (AREA_CONSTRUIDA_FIN <= 200 | AREA_CONSTRUIDA_FIN > 1000)) |
(TIPO_INMUEBLE='CABANA' & CLASE_PREDIO_OFT = "N" AND (AREA_CONSTRUIDA_FIN <= 200 | AREA_CONSTRUIDA_FIN > 2000))) 
THEN MARCA_AREA_C = 1;
IF ((TIPO_INMUEBLE IN ('APARTAMENTO', 'GARAJE') AND CLASE_PREDIO_OFT = "N") | 
(TIPO_INMUEBLE = "CASA_LOTE" AND CLASE_PREDIO_OFT = "P") |
(TIPO_INMUEBLE IN ("LOTE", "FINCA", "OTROS"))) THEN MARCA_AREA_C = .;
/*AREA_CONSTRUIDA_FIN_2 = AREA_CONSTRUIDA_FIN;*/
/*IF out_con=1 THEN AREA_CONSTRUIDA_FIN_2=.;*/

/* BLOQUE 30.2: VALIDACIONES ESTRATO */

/*ESTRATO_2 = ESTRATO;*/
/*IF TIPO_INMUEBLE='LOCAL'|TIPO_INMUEBLE='OFICINA'|TIPO_INMUEBLE='BODEGA'|TIPO_INMUEBLE='EDIFICIO'|TIPO_INMUEBLE='FINCA'|TIPO_INMUEBLE='LOTE' THEN ESTRATO_2=.;*/
/*IF ESTRATO_2=. & (TIPO_INMUEBLE='APARTAMENTO' | TIPO_INMUEBLE='CASA') THEN ESTRATO_2=0;*/

/* BLOQUE 30.3: VALIDACIONES AREA TERRENO */
/*FORMAT out_terr $CHAR1.;*/

MARCA_AREA_T = 0;
IF CLASE_PREDIO_OFT='N' & ((AREA_TERRENO_FIN IN (.) & TIPO_INMUEBLE IN ("CASA", "CASA_USO_MIXTO", "CASA_CAMPESTRE", "CASA_LOTE", "OFICINA", "LOCAL", "BODEGA", "LOTE", "FINCA", 'PARQUEADERO-LAVA_AUTOS', 'INMUEBLE_COMERCIAL', 'EDIFICIO', 'DEPOSITO', 'CABANA')) |
(TIPO_INMUEBLE='CASA' & (AREA_TERRENO_FIN <= 27 | AREA_TERRENO_FIN > 2000)) |
(TIPO_INMUEBLE='CASA_USO_MIXTO' & (AREA_TERRENO_FIN <= 100 | AREA_TERRENO_FIN > 2000)) |
(TIPO_INMUEBLE='CASA_CAMPESTRE' & (AREA_TERRENO_FIN <= 200 | AREA_TERRENO_FIN > 10000)) |
(TIPO_INMUEBLE='CASA_LOTE' & (AREA_TERRENO_FIN <= 100 | AREA_TERRENO_FIN > 2000)) |
(TIPO_INMUEBLE='OFICINA' & (AREA_TERRENO_FIN <= 100 | AREA_TERRENO_FIN > 20000)) |
(TIPO_INMUEBLE='LOCAL' & (AREA_TERRENO_FIN <= 27 | AREA_TERRENO_FIN > 20000)) |
(TIPO_INMUEBLE='BODEGA' & (AREA_TERRENO_FIN <= 72 | AREA_TERRENO_FIN > 20000)) |
(TIPO_INMUEBLE='LOTE' & (AREA_TERRENO_FIN <= 27 | AREA_TERRENO_FIN > 100000)) |
(TIPO_INMUEBLE='FINCA' & (AREA_TERRENO_FIN <= 6400 | AREA_TERRENO_FIN > 1000000)) |
(TIPO_INMUEBLE IN ('PARQUEADERO-LAVA_AUTOS', 'INMUEBLE_COMERCIAL', 'EDIFICIO') & (AREA_TERRENO_FIN <= 500 | AREA_TERRENO_FIN > 20000)) |
(TIPO_INMUEBLE='DEPOSITO' & (AREA_TERRENO_FIN <= 72 | AREA_TERRENO_FIN > 500)) |
(TIPO_INMUEBLE='CABANA' & (AREA_TERRENO_FIN <= 200 | AREA_TERRENO_FIN > 10000)))
THEN MARCA_AREA_T = 1;
IF ((CLASE_PREDIO_OFT = 'P') | TIPO_INMUEBLE IN  ("APARTAMENTO", "HABITACION", "GARAJE", "OTROS") )
THEN MARCA_AREA_T = .;

/* BLOQUE 30.4: VALIDACIÓN DE PRECIO DE VENTA */

MARCA_VALOR_VENTA = 0;
IF TIPO_OFERTA = "VENTA" AND  ( PRECIO IN (.) |
(TIPO_INMUEBLE IN ('APARTAMENTO', "CASA", "CASA_LOTE") & (PRECIO <= 50000000 | PRECIO > 3000000000)) |
(TIPO_INMUEBLE='CASA_USO_MIXTO' & (PRECIO <= 80000000 | PRECIO > 3000000000)) |
(TIPO_INMUEBLE='CASA_CAMPESTRE' & (PRECIO <= 100000000 | PRECIO > 5000000000)) |
(TIPO_INMUEBLE IN ('OFICINA', 'LOCAL') & (PRECIO <= 100000000 | PRECIO > 3000000000)) |
(TIPO_INMUEBLE='BODEGA' & (PRECIO <= 200000000 | PRECIO > 20000000000)) |
(TIPO_INMUEBLE='EDIFICIO' & (PRECIO <= 500000000 | PRECIO > 20000000000)) |
(TIPO_INMUEBLE='LOTE' & (PRECIO <= 30000000 | PRECIO > 2000000000)) |
(TIPO_INMUEBLE='FINCA' & (PRECIO <= 10000000 | PRECIO > 5000000000)) |
(TIPO_INMUEBLE IN ('PARQUEADERO-LAVA_AUTOS', 'INMUEBLE_COMERCIAL') & (PRECIO <= 500000000 | PRECIO > 20000000000)) |
(TIPO_INMUEBLE='DEPOSITO' & (PRECIO <= 100000000 | PRECIO > 1000000000)) |
(TIPO_INMUEBLE='GARAJE' & (PRECIO <= 8000000 | PRECIO > 100000000)) |
(TIPO_INMUEBLE='CABANA' & (PRECIO <= 100000000 | PRECIO > 5000000000)))
THEN MARCA_VALOR_VENTA = 1;
IF TIPO_INMUEBLE IN ("HABITACION", "OTROS") THEN MARCA_VALOR_VENTA = .;

/* BLOQUE 30.5: VALIDACIÓN DE PRECIO DE ARRIENDO */

MARCA_VALOR_ARRIENDO = 0;
IF TIPO_OFERTA = "ARRIENDO" AND  ( PRECIO IN (.) |
(TIPO_INMUEBLE='APARTAMENTO' & (PRECIO <= 200000 | PRECIO > 15000000)) |
(TIPO_INMUEBLE='CASA' & (PRECIO <= 300000 | PRECIO > 30000000)) |
(TIPO_INMUEBLE='CASA_USO_MIXTO' & (PRECIO <= 500000 | PRECIO > 30000000)) |
(TIPO_INMUEBLE='CASA_CAMPESTRE' & (PRECIO <= 300000 | PRECIO > 30000000)) |
(TIPO_INMUEBLE='CASA_LOTE' & (PRECIO <= 300000 | PRECIO > 30000000)) |
(TIPO_INMUEBLE='OFICINA' & (PRECIO <= 600000 | PRECIO > 30000000000)) |
(TIPO_INMUEBLE='LOCAL' & (PRECIO <= 600000 | PRECIO > 30000000000)) |
(TIPO_INMUEBLE IN ('BODEGA', 'EDIFICIO', 'INMUEBLE_COMERCIAL') & (PRECIO <= 1000000 | PRECIO > 15000000000)) |
(TIPO_INMUEBLE='DEPOSITO' & (PRECIO <= 800000 | PRECIO > 500000000)) |
(TIPO_INMUEBLE='HABITACION' & (PRECIO <= 50000 | PRECIO > 1000000)) |
(TIPO_INMUEBLE='GARAJE' & (PRECIO <= 30000 | PRECIO > 500000000)) |
(TIPO_INMUEBLE='CABANA' & (PRECIO <= 300000 | PRECIO > 30000000)))
THEN MARCA_VALOR_ARRIENDO = 1;
IF TIPO_INMUEBLE IN ("OTROS", "LOTE", "FINCA", "PARQUEADERO-LAVA_AUTOS") THEN MARCA_VALOR_ARRIENDO = .;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_10;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 31: CÁLCULO DE ANTIGÜEDAD FINAL Y AÑO DE CONSTRUCCIÓN                                                 */
/* Propósito: Derivar antigüedad validada y año estimado de construcción                                     */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA BASE_OFT_CONSOLIDADA_12;
SET BASE_OFT_CONSOLIDADA_11;
IF ((ANTIGUEDAD_INMUEBLE_FIN < 0) AND (ANTIGUEDAD_INMUEBLE_FIN NE .)) THEN ANTIGUEDAD_INMUEBLE_FIN = 0;
YEAR_CONSTRUCCION = YEAR - ANTIGUEDAD_INMUEBLE_FIN;
RUN;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_11 ;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/* SECCIÓN 31.1: Marca de antigüedad anómala */
data  BASE_OFT_CONSOLIDADA_12;
SET BASE_OFT_CONSOLIDADA_12;
MARCA_ANTIGUEDAD = .;
IF ((ANTIGUEDAD_INMUEBLE_FIN >= 0) AND (ANTIGUEDAD_INMUEBLE_FIN NE .) AND (ANTIGUEDAD_INMUEBLE_FIN < 80)) THEN MARCA_ANTIGUEDAD = 0;
IF ((ANTIGUEDAD_INMUEBLE_FIN NE .) AND (ANTIGUEDAD_INMUEBLE_FIN >= 80)) THEN MARCA_ANTIGUEDAD = 1;
IF TIPO_INMUEBLE = "DEPÓSITO" THEN TIPO_INMUEBLE = "DEPOSITO";
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 32: ENRIQUECIMIENTO CON IDENTIFICADORES DE OFERTA DE BASES HISTÓRICAS DE FOCA                        */
/* Propósito: Agregar ID_OFERTA para trazabilidad en sistema FOCA                                            */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA OFERTAS_FOCA_REPORTES;
SET BIENES.OW_GESTTRAM_OFERTAS;
/*WHERE DATEPART(FECHA_CREACION) >= '1OCT2022'd AND FUENTE ="3" AND ESTADO=10;*/
KEEP OBSERVACION ID /*FECHA_CREACION*/;
RUN;

PROC SORT DATA=OFERTAS_FOCA_REPORTES NODUPKEY OUT=UNICAS DUPOUT=REP;BY OBSERVACION;QUIT;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete OFERTAS_FOCA_REPORTES;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

PROC SQL;
CREATE TABLE 
BASE_OFT_CONSOLIDADA_13
AS SELECT 

A.*,
B.ID AS ID_OFERTA

FROM (SELECT * FROM BASE_OFT_CONSOLIDADA_12) AS A
LEFT JOIN (SELECT * FROM UNICAS) AS B
ON SUBSTR(A.IDENTIFICADOR,6,24) = SUBSTR(B.OBSERVACION, 1, 24);
QUIT;

PROC SQL;
CREATE TABLE 
BASE_OFT_CONSOLIDADA_13
AS SELECT 

A.*,
B.ID AS ID_OFERTA_2

FROM (SELECT * FROM BASE_OFT_CONSOLIDADA_13) AS A
LEFT JOIN (SELECT * FROM UNICAS) AS B
ON A.IDENTIFICADOR = SUBSTR(B.OBSERVACION, 1, 29);
QUIT;

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
proc datasets library=work;
   delete BASE_OFT_CONSOLIDADA_12 UNICAS;
run;
quit;
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

DATA BASE_OFT_CONSOLIDADA_13;
SET BASE_OFT_CONSOLIDADA_13;
ID_OFERTA_3 = .;
IF ID_OFERTA = . THEN ID_OFERTA_3 = ID_OFERTA_2; ELSE ID_OFERTA_3 = ID_OFERTA;
DROP ID_OFERTA ID_OFERTA_2;
RUN;

DATA BASE_OFT_CONSOLIDADA_13;
SET BASE_OFT_CONSOLIDADA_13;
RENAME ID_OFERTA_3 = ID_OFERTA;
RUN;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* PARTE 33: SALVAGUARDA FINAL A LIBRERÍAS PERMANENTES                                                         */
/* Propósito: Guardar base consolidada en OFT para uso posterior en FOCA y reportes                           */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

DATA OFT.BASE_OFT_CONSOLIDADA_1;
SET BASE_OFT_CONSOLIDADA_13;
RUN;

/* SECCIÓN 33.1: Base filtrada para Bogotá Distrito Capital */
DATA OFT.BASE_OFT_CONSOLIDADA_BTA;
SET BASE_OFT_CONSOLIDADA_13;
IF CODIGO_MUNICIPIO = "11001";
RUN;

data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* BLOQUE FINAL: CÓDIGO COMENTADO PARA REFERENCIA FUTURA                                                       */
/* Propósito: Preservar infraestructura para consultas futuras de centros comerciales                          */
/* NOTA CRÍTICA: El siguiente bloque NO SE DEBE ELIMINAR - Es requerido en caso de consultas de centros        */
/*               comerciales. Probablemente se necesiten ajustes en el caso de Galería Inmobiliaria, puesto    */
/*               que en algunos casos faltó información                                                         */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */

/*
LIBNAME TEMP "\\prowinfs02\Estadistica\IC_EJERCICIOS_2022\220422_OFERTAS_CENTROS_COMERCIALES\input\BASES_CONSOLIDADAS";

DATA TEMP.BASE_CC;
SET CC_21_03_OF_ALL
CC_21_04_OF_ALL
CC_22_01_OF_ALL;
RUN;

DATA TEMP.BASE_FR;
SET FR_21_08_2
FR_21_09_2
FR_21_10_2
FR_21_11_2
FR_21_12_2
FR_22_01_2
FR_22_02_2
FR_22_03_2;
RUN;

DATA TEMP.BASE_M2;
SET M2_21_08_OF
M2_21_09_OF
M2_21_10_OF
M2_21_11_OF
M2_21_12_OF;
RUN;

DATA TEMP.BASE_PR;
SET PR_21_08_2
PR_21_09_2
PR_21_10_2
PR_21_11_2
PR_21_12_2
PR_22_01_2;
RUN;

DATA TEMP.BASE_GI;
SET BASE_CONSOLIDADA_GI_21_08
BASE_CONSOLIDADA_GI_21_09
BASE_CONSOLIDADA_GI_21_10
BASE_CONSOLIDADA_GI_21_11
BASE_CONSOLIDADA_GI_21_12
BASE_CONSOLIDADA_GI_22_01
BASE_CONSOLIDADA_GI_22_02
BASE_CONSOLIDADA_GI_22_03;
RUN;

%LET VIG = 21;
%LET MES = 09;

DATA PR_&VIG._&MES._2;
SET PR_&VIG._&MES._OF;
NUMERO_ALCOBAS_1 = NUMERO_ALCOBAS*1;
NUMERO_BA_OS_1 = NUMERO_BA_OS*1;
AREA_DE_TERRENO_1 = AREA_DE_TERRENO*1;
AREA_CONSTRUIDA_1 = AREA_CONSTRUIDA*1;
VALOR_M2_INTEGRAL_1 = VALOR_M2_INTEGRAL*1;
VALOR_M2_TERRENO_1 = VALOR_M2_TERRENO*1;
LON2_1 = LON2*1;
LAT2_1 = LAT2*1;
DROP CODIGO_LOCALIDAD CODIGO_UPZ CODIGO_BARRIO MES
NUMERO_ALCOBAS NUMERO_BA_OS AREA_DE_TERRENO AREA_CONSTRUIDA
VALOR_M2_INTEGRAL VALOR_M2_TERRENO LON2 LAT2;
RUN;

%LET VIG = 21;
%LET MES = 08;

DATA FR_&VIG._&MES._2;
SET FR_&VIG._&MES._OF;
AREA_1 = AREA*1;
AREA_PRIVADA_1 = AREA_PRIVADA*1;
DROP AREA AREA_PRIVADA;
RUN;
*/

/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */
/* FIN DEL PROGRAMA - CONSOLIDACIÓN COMPLETA DE OFERTAS MULTIFUENTE (1373 LÍNEAS)                             */
/* ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════ */