/*	Proyecto Final del curso "SQL" (Proteco)
	Trabajo realizado por: Ricardo Cuevas Mondragón
	Junio 2017 
*/

-- Conexión a Oracle como sysdba
sqlplus / as sysdba

-- Creación de usuario
CREATE USER rcm IDENTIFIED BY rcm DEFAULT TABLESPACE users QUOTA 100M ON users;
--Otorgar permisos a usuario
GRANT CREATE SESSION, CREATE TABLE TO rcm;
GRANT CREATE SEQUENCE, CREATE VIEW TO rcm;
GRANT CREATE SYNONYM TO rcm;

-- Conexión con usuario creado
conn rcm/rcm

/*	Tablas por crear:
	Estudiante, carrera, carrera_asignatura, asignatura, plan_estudios,
	curso, semestre, horario_clase, curso_horario, profesor y grado_estudios.
*/

set linesize 200;

-- Creación de tabla GRADO_ESTUDIOS
-- Llave primaria a nivel columna
CREATE TABLE grado_estudios(
	grado_estudios_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	clave VARCHAR2(2) NOT NULL,
	descripcion VARCHAR2(100) NOT NULL
);

/*  Ya que solo existen 3 posibles grados de estudios, no es necesario
	que la longitud de la variable sea de 10.
	La cambiamos a 1 con el uso de ALTER.
*/
ALTER TABLE grado_estudios MODIFY grado_estudios_id NUMERIC(1,0);

-- Creación de tabla PROFESOR
-- Llave primaria y foránea a nivel columna
CREATE TABLE profesor(
	profesor_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	nombre VARCHAR2(40) NOT NULL,
	ap_paterno VARCHAR2(40) NOT NULL,
	ap_materno VARCHAR2(40) NOT NULL,
	rfc VARCHAR2(40) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	cedula VARCHAR2(20) NOT NULL,
	grado_estudios_id NUMERIC(1,0) NOT NULL 
	REFERENCES grado_estudios(grado_estudios_id)
);

-- Creación de tabla HORARIO_CLASE
-- Llave primaria a nivel columna
CREATE TABLE horario_clase(
	horario_clase_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
	dia NUMERIC(2,0) NOT NULL,
	hora_inicio TIMESTAMP NOT NULL,
	hora_fin TIMESTAMP NOT NULL
);

/*  Ya que el dia solo va de Lunes=1 hasta Sábado=6, no es necesario
	que la longitud de la variable sea de 2.
	La cambiamos a 1 con el uso de ALTER.
*/
ALTER TABLE horario_clase MODIFY dia NUMERIC(1,0);

-- Creación de tabla SEMESTRE
-- Llave primaria a nivel tabla
CREATE TABLE semestre(
	semestre_id NUMERIC(10,0) NOT NULL,
	anio NUMERIC(4,0) NOT NULL,
	periodo NUMERIC(1,0) NOT NULL,
	CONSTRAINT pk_semestre_id PRIMARY KEY (semestre_id)
);

-- Creación de tabla PLAN_ESTUDIOS
-- Llave primaria a nivel tabla
CREATE TABLE plan_estudios(
	plan_estudios_id NUMERIC(5,0) NOT NULL,
	clave VARCHAR2(7) NOT NULL,
	fecha_aprobacion DATE NOT NULL,
	fecha_fin DATE,
	CONSTRAINT pk_plan_estudios_id PRIMARY KEY (plan_estudios_id)
);

-- Creación de tabla AIGNATURA
-- LLaves a nivel tabla
CREATE TABLE asignatura(
	asignatura_id NUMERIC(10,0) NOT NULL,
	clave VARCHAR2(4) NOT NULL,
	num_semestre NUMERIC(2,0) NOT NULL,
	creditossss NUMERIC(2,0) NOT NULL,
	plan_estudios NUMERIC(5,0) NOT NULL,
	asignatura_requerida NUMERIC(10,0),
	CONSTRAINT pk_asignatura_id PRIMARY KEY (asignatura_id),
	CONSTRAINT fk_plan_estudios FOREIGN KEY (plan_estudios)
	REFERENCES plan_estudios(plan_estudios_id),
	CONSTRAINT fk_asignatura_requerida FOREIGN KEY (asignatura_requerida) 
	REFERENCES asignatura(asignatura_id)
);

-- Cambiar la variable CREDITOSSSS por CREDITOS. Usando ALTER.
ALTER TABLE asignatura RENAME COLUMN creditossss TO creditos;
-- Agregar la variable NOMBRE con un ALTER.
ALTER TABLE asignatura ADD (nombre VARCHAR2(40) NOT NULL);

-- Creación de tabla CURSO
-- Llaves a nivel tabla
CREATE TABLE curso(
	curso_id NUMERIC(10,0) NOT NULL,
	num_grupo NUMERIC(2,0) NOT NULL,
	asignatura_id NUMERIC(10,0) NOT NULL,
	profesor_id NUMERIC(10,0),
	semestre_id NUMERIC(10,0) NOT NULL,
	dia NUMERIC(1,0) NOT NULL,
	CONSTRAINT pk_curso_id PRIMARY KEY (curso_id),
	CONSTRAINT fk_asignatura_id FOREIGN KEY (asignatura_id)REFERENCES asignatura(asignatura_id),
	CONSTRAINT fk_profesor_id FOREIGN KEY (profesor_id)REFERENCES profesor(profesor_id),
	CONSTRAINT fk_semestre_id FOREIGN KEY (semestre_id) REFERENCES semestre(semestre_id)
);

-- Ya que el DIA no va en ésta tabla lo eliminamos con ALTER.
ALTER TABLE curso DROP COLUMN dia;

-- Creación de tabla CURSO_HORARIO
-- Llaves a nivel tabla 
CREATE TABLE curso_horario(
	curso_horario_id NUMERIC(10,0) NOT NULL,
	salon varchar2(4) NOT NULL, --Salon cadena formada por una letra y hasta 3 dígitos
	curso_id NUMERIC(10,0) NOT NULL,
	horario_id NUMERIC(10,0) NOT NULL,
	CONSTRAINT pk_curso_horario PRIMARY KEY (curso_horario_id),
	CONSTRAINT fk_curso_id FOREIGN KEY(curso_id) REFERENCES curso(curso_id),
	CONSTRAINT fk_horario_id FOREIGN KEY(horario_id) REFERENCES horario_clase(horario_clase_id) 
);

-- Creación de tabla CARRERA
-- Llave a nivel tabla
CREATE TABLE carrera(
	carrera_id NUMERIC(10,0) NOT NULL,
	clave VARCHAR2(5) NOT NULL,
	nombre VARCHAR2(40) NOT NULL,
	descripcion VARCHAR2(500) NOT NULL,
	CONSTRAINT pk_carrera_id PRIMARY KEY (carrera_id)
);

-- Creación de tabla CARRERA_ASIGNATURA
-- Llaves a nivel tabla
CREATE TABLE carrera_asignatura(
	carrera_asignatura_id NUMERIC(10,0) NOT NULL,
	numero_semestre NUMERIC(2,0) NOT NULL,
	carrera_id NUMERIC(10,0) NOT NULL,
	asignatura_id NUMERIC(10,0) NOT NULL,
	CONSTRAINT pk_carrera_asignatura PRIMARY KEY (carrera_asignatura_id),
	CONSTRAINT fk_carrera_id FOREIGN KEY (carrera_id)
	REFERENCES carrera(carrera_id),
	CONSTRAINT fk_asignatura_id2 FOREIGN KEY (asignatura_id)
	REFERENCES asignatura(asignatura_id)
);

-- Creación de tabla ESTUDIANTE
-- Llaves solo declaradas, para después añadirlas con un ALTER
CREATE TABLE estudiante(
	estudiante_id NUMERIC(10,0) NOT NULL,
	nombre VARCHAR2(40) NOT NULL,
	ap_paterno VARCHAR2(40) NOT NULL,
	ap_materno VARCHAR2(40) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	numero_cuenta VARCHAR2(10) NOT NULL,
	carrera_id NUMERIC(10,0) NOT NULL,
	plan_estudios NUMERIC(5,0) NOT NULL
);

-- Ahora si agregamos los CONSTRAINTS con un ALTER
ALTER TABLE estudiante ADD CONSTRAINT pk_estudiante_id PRIMARY KEY(estudiante_id);
ALTER TABLE estudiante ADD CONSTRAINT fk_carrera_id2 FOREIGN KEY(carrera_id)
REFERENCES carrera(carrera_id);
ALTER TABLE estudiante ADD CONSTRAINT fk_plan_estudios2 FOREIGN KEY(plan_estudios)
REFERENCES plan_estudios(plan_estudios_id);

-- Creación de secuencias

-- Tabla GRADO_ESTUDIOS
CREATE SEQUENCE sequence_grado START WITH 1 INCREMENT BY 1;
-- Tabla PROFESOR
CREATE SEQUENCE sequence_profesor START WITH 1 INCREMENT BY 1;
-- Tabla HORARIO_CLASE
CREATE SEQUENCE sequence_horario START WITH 1 INCREMENT BY 1;
-- Tabla SEMESTRE
CREATE SEQUENCE sequence_semestre START WITH 1 INCREMENT BY 1;
-- Tabla PLAN_ESTUDIOS
CREATE SEQUENCE sequence_plan START WITH 1 INCREMENT BY 1;
-- Tabla ASIGNATURA
CREATE SEQUENCE sequence_asignatura START WITH 1 INCREMENT BY 1;
-- Tabla CURSO
CREATE SEQUENCE sequence_curso START WITH 1 INCREMENT BY 1;
-- Tabla CURSO_HORARIO
CREATE SEQUENCE sequence_curso_horario START WITH 1 INCREMENT BY 1;
-- Tabla CARRERA
CREATE SEQUENCE sequence_carrera START WITH 1 INCREMENT BY 1;
-- Tabla CARRERA_ASIGNATURA
CREATE SEQUENCE sequence_carrera_asignatura START WITH 1 INCREMENT BY 1;
-- Tabla ESTUDIANTE
CREATE SEQUENCE sequence_estudiante START WITH 1 INCREMENT BY 1;


-- Inserción de datos. Diez(10) registros por cada tabla, excepto en la tabla
-- GRADO_ESTUDIOS en donde sólo hay tres(3) opciones. 

--Inserciones tabla GRADO_ESTUDIOS
INSERT INTO grado_estudios VALUES(sequence_grado.nextval,'LI','Licenciatura');
INSERT INTO grado_estudios VALUES(sequence_grado.nextval,'MA','Maestria');
INSERT INTO grado_estudios VALUES(sequence_grado.nextval,'DR','Doctorado');

--Inserciones tabla PROFESOR
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Stalin','Muñoz','Gutierrez','MUGS700228L64',to_date('28/02/1970','dd/mm/yyyy'),'3017823',3);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Edna','Marquez','Marquez','MAME670802',to_date('02/08/1967','dd/mm/yyyy'),'7255128',1);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Salvador','Perez','Viramontes','PEVS801113N87',to_date('13/11/1980','dd/mm/yyyy'),'8924338',2);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Eduardo','Espinosa','Avila','ESAE680107G24',to_date('07/01/1968','dd/mm/yyyy'),'1592974',2);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Patricia','Hong','Cirion','HOCP690330L54',to_date('30/03/1969','dd/mm/yyyy'),'4143503',1);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Julia','Vazquez','Fuentes','VAFJ761211M01',to_date('11/12/1976','dd/mm/yyyy'),'1030178',2);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Osvaldo','Sanchez','Zamora','SAZO760921',to_date('21/09/1976','dd/mm/yyyy'),'0190312',2);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Alejandra','Vargas','Espinoza','VAEA840801B14',to_date('01/08/1984','dd/mm/yyyy'),'3582202',1);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Agustin','Fernandez','Nuñez','FENA800218J43',to_date('18/02/1980','dd/mm/yyyy'),'8142347',2);
INSERT INTO profesor VALUES(sequence_profesor.nextval,'Carlos','Rivera','Lara','RILC790327K83',to_date('27/03/1979','dd/mm/yyyy'),'9443108',3);

-- Inserciones tabla HORARIO_CLASE
INSERT INTO horario_clase VALUES(sequence_horario.nextval,1,to_timestamp('9:00','hh24:mi'),to_timestamp('11:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,3,to_timestamp('13:00','hh24:mi'),to_timestamp('14:30','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,2,to_timestamp('11:00','hh24:mi'),to_timestamp('13:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,5,to_timestamp('15:00','hh24:mi'),to_timestamp('17:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,6,to_timestamp('7:00','hh24:mi'),to_timestamp('10:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,1,to_timestamp('13:00','hh24:mi'),to_timestamp('15:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,3,to_timestamp('9:15','hh24:mi'),to_timestamp('11:30','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,4,to_timestamp('11:00','hh24:mi'),to_timestamp('13:15','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,1,to_timestamp('16:00','hh24:mi'),to_timestamp('18:00','hh24:mi'));
INSERT INTO horario_clase VALUES(sequence_horario.nextval,2,to_timestamp('7:00','hh24:mi'),to_timestamp('9:15','hh24:mi'));

-- Inserciones tabla SEMESTRE
INSERT INTO semestre VALUES(sequence_semestre.nextval,2013,2);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2014,1);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2014,2);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2015,1);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2015,2);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2016,1);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2016,2);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2017,1);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2017,2);
INSERT INTO semestre VALUES(sequence_semestre.nextval,2018,1);

-- Inserciones tabla PLAN_ESTUDIOS
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1998,to_date('08/08/1998','dd/mm/yyyy'),to_date('14/03/2001','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,2010,to_date('12/12/2010','dd/mm/yyyy'),to_date('11/12/2011','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1996,to_date('31/05/1996','dd/mm/yyyy'),to_date('18/01/1997','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,2001,to_date('14/03/2001','dd/mm/yyyy'),to_date('12/12/2010','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1997,to_date('18/01/1997','dd/mm/yyyy'),to_date('08/08/1998','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,2015,to_date('21/09/2015','dd/mm/yyyy'),NULL);
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1992,to_date('30/07/1992','dd/mm/yyyy'),to_date('31/05/1996','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1985,to_date('24/06/1985','dd/mm/yyyy'),to_date('14/02/1988','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,2011,to_date('11/12/2011','dd/mm/yyyy'),to_date('21/09/2015','dd/mm/yyyy'));
INSERT INTO plan_estudios VALUES(sequence_plan.nextval,1988,to_date('14/02/1988','dd/mm/yyyy'),to_date('30/07/1992','dd/mm/yyyy'));

-- Inserciones tabla ASIGNATURA
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'1107',1,9,6,NULL,'Calculo Integral');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'1100',2,9,6,1,'Calculo Vectorial');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'1492',2,6,2,NULL,'Derecho Mercantil');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'9990',3,6,9,3,'Derecho Fiscal');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'4109',4,6,4,4,'Derecho Laboral');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'1211',1,12,6,NULL,'Fisiologia');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'1207',1,9,6,NULL,'Radiologia');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'5306',5,11,2,NULL,'Sistemas Estructurales');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'4312',4,8,2,NULL,'Macroeconomia');
INSERT INTO asignatura VALUES(sequence_asignatura.nextval,'8422',8,11,1,NULL,'Inteligencia Artificial');

-- Inserciones tabla CURSO
INSERT INTO curso VALUES(sequence_curso.nextval,12,8,2,3);
INSERT INTO curso VALUES(sequence_curso.nextval,18,6,5,7);
INSERT INTO curso VALUES(sequence_curso.nextval,2,3,8,1);
INSERT INTO curso VALUES(sequence_curso.nextval,11,10,4,6);
INSERT INTO curso VALUES(sequence_curso.nextval,16,4,10,8);
INSERT INTO curso VALUES(sequence_curso.nextval,1,9,1,3);
INSERT INTO curso VALUES(sequence_curso.nextval,8,3,NULL,2);
INSERT INTO curso VALUES(sequence_curso.nextval,12,7,3,1);
INSERT INTO curso VALUES(sequence_curso.nextval,5,1,9,5);
INSERT INTO curso VALUES(sequence_curso.nextval,3,2,9,10);

-- Inserciones tabla CURSO_HORARIO
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'B102',4,8);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'S003',2,6);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'B401',1,2);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'A107',6,8);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'I301',10,4);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'K108',8,9);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'O003',5,1);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'P008',3,7);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'J102',7,3);
INSERT INTO curso_horario VALUES(sequence_curso_horario.nextval,'I203',9,10);

-- Inserciones tabla CARRERA
INSERT INTO carrera VALUES(sequence_carrera.nextval,110,'Ingenieria en Computacion','El profesionista inegniero en computacion aplica sus conocimientos en software, hardware, seguridad, redes, bases de datos y sistemas inteligentes');
INSERT INTO carrera VALUES(sequence_carrera.nextval,114,'Ingenieria Industrial','El profesionista ingeniero industrial tiene un campo de trabajo amplio y bien pagado');
INSERT INTO carrera VALUES(sequence_carrera.nextval,203,'Enfermeria y Obstetricia','El profesionista enfermero trabaja en un hospital de ayudante de los medicos');
INSERT INTO carrera VALUES(sequence_carrera.nextval,305,'Derecho','El profesionista en derecho estudia leyes para aplicarlas al salir de la carrera y poder ser un exitoso abogado');
INSERT INTO carrera VALUES(sequence_carrera.nextval,306,'Economia','El profesionista economista se encarga de las finanzas de un negocio');
INSERT INTO carrera VALUES(sequence_carrera.nextval,115,'Ingenieria Mecanica','El profesionista ingeniero mecanico aplica sus conocimientos en cualquier sistema con movimiento');
INSERT INTO carrera VALUES(sequence_carrera.nextval,102,'Arquitectura','El profesionista arquitecto aplica sus conocimientos en el diseño y construccion de casas o edificios');
INSERT INTO carrera VALUES(sequence_carrera.nextval,315,'Comunicacion','El profesionista en comunicacion puede trabajar en radio, television o periodicos');
INSERT INTO carrera VALUES(sequence_carrera.nextval,202,'Cirujano Dentista','El profesionista cirujano dentista se encarga de la salud bucal de las personas');
INSERT INTO carrera VALUES(sequence_carrera.nextval,406,'Diseño Grafico','El profesionista diseñador grafico tiene usualmente poco trabajo');

-- Inserciones tabla CARRERA_ASIGNATURA
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,2,1,2);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,3,2,2);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,3,6,2);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,4,6,8);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,9,7,8);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,5,3,7);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,8,9,7);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,1,5,9);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,1,4,9);
INSERT INTO carrera_asignatura VALUES(sequence_carrera_asignatura.nextval,3,2,9);

-- Inserciones tabla ESTUDIANTE
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Ricardo','Cuevas','Mondragon',to_date('31/05/1996','dd/mm/yyyy'),'415031976',1,2);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Charleen','Gruhlich','Uliknich',to_date('09/07/1995','dd/mm/yyyy'),'312381995',5,4);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Yareni','Lisette','Montreal',to_date('22/01/1995','dd/mm/yyyy'),'823814522',4,4);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Brenda','Mondragon','Pozas',to_date('03/02/1998','dd/mm/yyyy'),'929741435',7,6);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Mateo','Josep','Tobon',to_date('12/11/1993','dd/mm/yyyy'),'531320059',6,1);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Carlos','Hernandez','Rojas',to_date('01/09/1996','dd/mm/yyyy'),'812432582',3,2);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Fernando','Molina','Lara',to_date('14/10/1993','dd/mm/yyyy'),'425034982',5,1);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Juan','Chavarria','Perez',to_date('17/03/1997','dd/mm/yyyy'),'998721568',9,6);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Maria','Regina','Castillo',to_date('10/12/1994','dd/mm/yyyy'),'214150272',10,4);
INSERT INTO estudiante VALUES(sequence_estudiante.nextval,'Aranza','Santana','Errasti',to_date('14/06/1991','dd/mm/yyyy'),'425538572',8,1);

----------------------------------------------------------------------------------------
-- Actualizar 5 registros, con UPDATE
-- Actualizar en tabla GRADO_ESTUDIOS, maestría por maestria (agregar acento)
UPDATE grado_estudios SET descripcion='Maestría' WHERE descripcion='Maestria';

-- Actualizar doctorado por maestria a la profesora EDNA MARQUEZ MARQUEZ
UPDATE profesor SET grado_estudios_id=3 WHERE grado_estudios_id=1 AND nombre='Edna';

-- Actualizar la seriazcion de materias: Calculo Vectorial ---> Inteligencia Artificial
UPDATE asignatura SET asignatura_requerida=2 WHERE nombre='Inteligencia Artificial';

-- Actualizar en el curso 2 de Fisiologia, quitar a profesor y dejarlo NULL
UPDATE curso SET profesor_id=NULL WHERE profesor_id=5 AND asignatura_id=6;

-- Actualizar el apellido materno de la estudiante MARIA REGINA
UPDATE estudiante SET ap_materno='Quintana' WHERE numero_cuenta='214150272'; 

----------------------------------------------------------------------------------------
-- Consultas sencillas con uso de funciones
-- Obtener el promedio de créditos por asignatura
SELECT AVG(creditos) AS "AVG creditos/asignatura" FROM asignatura;
-- Obtener las carreras en orden alfabético
SELECT carrera_id AS id, nombre FROM carrera ORDER BY nombre ASC;
-- Funcion CONCAT, obtener nombre completo de los estudiantes
SELECT CONCAT(CONCAT(CONCAT(CONCAT(nombre,' '),ap_paterno),' '),ap_materno) AS "Nombre Completo" FROM estudiante;
-- Obtener cuantos profesor nacieron en la decada de los 60's
SELECT count(*) AS "Profes de los 60's" FROM profesor WHERE fecha_nacimiento BETWEEN to_date('01/01/1960','dd/mm/yyyy') AND to_date('31/12/1969','dd/mm/yyyy');

-----------------------------------------------------------------------------------------
-- Consultas con uso de subquerys
-- Obtener la carrera que tiene más asignaturas. Como hay un empate seleccionamos las dos carreras.
SELECT carrera_id,nombre AS "Carrera con más asignaturas" FROM (SELECT carrera_id, count(*) FROM carrera_asignatura GROUP BY carrera_id
ORDER BY count(carrera_id) DESC) natural join carrera  WHERE ROWNUM<=2;

-- Obtener el estudiante más joven
SELECT nombre||' '||ap_paterno||' '||ap_materno AS "Nombre Completo",(EXTRACT(YEAR FROM sysdate)-EXTRACT(YEAR FROM fecha_nacimiento))
 AS "Edad" FROM estudiante WHERE fecha_nacimiento=(SELECT MAX(fecha_nacimiento) FROM estudiante);

-- Mostrar las asignaturas, sus creditos y se compara con el mayor numero de creditos que tiene una asignatura
 SELECT nombre, creditos,(SELECT MAX(creditos) FROM asignatura) AS "Max Creditos" FROM asignatura;


------------------------------------------------------------------------------------------
-- Una consulta donde se tengan que relacionar al menos 4 tablas
-- Mostrar la(s) asignatura(s) que imparte cada profesor, tambien se muestra el grado de estudios de cada profesor
SELECT p.nombre||' '||p.ap_paterno||' '||p.ap_materno||' tiene '||g.descripcion||' e imparte: '||a.nombre AS "Query Results" 
from grado_estudios g JOIN profesor p ON g.grado_estudios_id=p.grado_estudios_id JOIN curso c ON p.profesor_id=c.profesor_id 
JOIN asignatura a ON c.asignatura_id=a.asignatura_id;


------------------------------------------------------------------------------------------
--Crear 2 vistas
-- Le haré una vista a la consulta de arriba
CREATE OR REPLACE VIEW AsigImpartidasPorCadaProf AS SELECT p.nombre||' '||p.ap_paterno||' '||p.ap_materno||' tiene '||g.descripcion||' e imparte: '||a.nombre AS "Query Results" 
from grado_estudios g JOIN profesor p ON g.grado_estudios_id=p.grado_estudios_id JOIN curso c ON p.profesor_id=c.profesor_id 
JOIN asignatura a ON c.asignatura_id=a.asignatura_id;

SELECT * FROM AsigImpartidasPorCadaProf; 

-- Una vista para la consulta de obtener la carrera que estudia cada estudiante
CREATE OR REPLACE VIEW CarreraDeCadaEstudiante AS SELECT e.nombre||' '||e.ap_paterno||' '||e.ap_materno AS Nombre,c.nombre AS Carrera
FROM estudiante e JOIN carrera c ON e.carrera_id=c.carrera_id;

SELECT * FROM  CarreraDeCadaEstudiante;


-------------------------------------------------------------------------------------------
-- Crear 2 sinónimos
-- Literalmente estudiante y alumno son sinónimos, y materia con asignatura también lo son. 
CREATE SYNONYM alumno FOR estudiante;
CREATE SYNONYM materia FOR asignatura;

commit;



