--1. Genere una base de datos en el motor PostgreSQL cuyo nombre sea tp_su_apellido. 
-- Describa los pasos que tuvo que llevar a cabo para lograrlo. 
--Guarde las sentencias que usó para  la creación de las tablas en el archivo sql.

--Abirmos la consola psql con el sistema operativo Windows 10, escribimos el comando 
--localhost para acceder al motor de base de datos y postgres para conectarnos al servidor indicando el puerto '5432' 
--logueamos el usuario (usermame) por defecto "postgres" y password con el que creamos el servidor y accedemos

--creamos la base de datos con en nombre solicitado tp_osores_salas con el siguiente comando
CREATE DATABASE tp_osores_salas ;
--nos conectamos con \c tp_osores_salas para reflejar los datos allí 


--2. Escriba las queries para crear las tablas y estructuras de acuerdo a lo descripto más arriba. 
--	creamos las tablas de manera ordenada según el enunciado(opción 1)


CREATE TABLE usuario(
	usuario VARCHAR(16) PRIMARY KEY,  --el nombre del usuario es clave primaria 
	correo VARCHAR(50),
	fecha_nacimiento DATE,
	ciudad VARCHAR(40),
	nyap VARCHAR(30),
	contrasenia VARCHAR(200) NOT NULL,
	cantidad_pull_request INT DEFAULT 0 --cantidad de pull request cero por defecto.
);	


CREATE TABLE repositorio(
	nombre VARCHAR(12),
	usuario VARCHAR(16),
	tipo_repositorio VARCHAR(12),
	cantidad_favoritos INT DEFAULT 0,  --cantidad de favoritos cero por defecto.
	cantidad_pull_request INT DEFAULT 0,  -- cantidad de pull request cero por defecto.
	PRIMARY KEY ( nombre, usuario)
--defino como clave primaria compuesta por nombre y suario, realizamos las pruebas y no se pueden
--guardar repositorios de un mismo usuario con dos nombres iguales		
	);
	
	
CREATE TABLE archivo(
	id SERIAL PRIMARY KEY, --el id es clave primaria
	nombre_repositorio VARCHAR(12),
	usuario_repositorio VARCHAR(16),
	contenido VARCHAR(255)
	);

CREATE TABLE commit (
	hash VARCHAR(40) PRIMARY KEY,
	id_archivo INT,
	titulo VARCHAR(30),
	descripcion VARCHAR(200),
	fecha_cambio DATE DEFAULT CURRENT_DATE
	);

CREATE TABLE contribucion(
		hash VARCHAR(40),
		usuario VARCHAR(16),
		cantidad_cambios INT,
 		PRIMARY KEY(hash, usuario) 
  --defino una clave compuesta de contribución y lo probamos insertando mismos usuarios 
  --con mismos hash para corroborar que no permite hash y usuario iguales en la pk de contribucion 
		);

--3. Identifique todas las claves foráneas que correspondan y escriba las queries para crearlas.

--TABLA commit tiene id_archivo de foregin key al id de la tabla archivo 
ALTER TABLE commit
ADD CONSTRAINT id_archivo
FOREIGN KEY (id_archivo) REFERENCES archivo(id);

--TABLA repositorio tiene como foregin key al usuario de la tabla usuario
ALTER TABLE repositorio
ADD CONSTRAINT usuario
FOREIGN KEY (usuario) REFERENCES usuario(usuario);

--TABLA archivo tiene como foregin key al atributo usuario_repositorio del usuario de la tabla usuario
ALTER TABLE archivo
ADD CONSTRAINT usuario_repositorio
FOREIGN KEY (usuario_repositorio) REFERENCES usuario(usuario);        

ALTER TABLE contribucion
ADD CONSTRAINT hash
FOREIGN KEY (hash) REFERENCES commit(hash);

ALTER TABLE contribucion
ADD CONSTRAINT usuario
FOREIGN KEY (usuario) REFERENCES usuario(usuario);

--PUNTO 4
--restriccion de fecha maxima en la fecha_nacimiento de usuario
ALTER TABLE usuario ADD CONSTRAINT fecha_maxima CHECK (fecha_nacimiento<='2015/12/12');

--restriccion de "tipos" en el tipo de repositorio
ALTER TABLE repositorio ADD CONSTRAINT tipos_de_repositorio CHECK (tipo_repositorio IN ('informativo','empresarial','educacional','comercial'));

--PUNTO 6 
 -- insertamos los datos copiando los insert especificados en el archivo por cada tabla que generamos anteriormente,
 -- esto se resolvió de manera iterativa para que la integridad referencial pueda cumplirse en todos los casos que existan los FK 

--PUNTO 7
--Para que exista la siguiente información en la base de datos 
--necesitamos insertar los datos con INSERT INTO nombretabla(atributos) VALUES y los valores de cada atributo.


--Usuarios pepim y solan
INSERT INTO usuario(usuario, correo, fecha_nacimiento, ciudad, nyap, contrasenia, cantidad_pull_request) VALUES
    ('pepim','pepim@gmail.com','1997-11-11','Solano', 'Marcos Salas','password123',default),
    ('solan','solan@gmail.com','1997/06/06','Quilmes', 'Bianca Osores','passpass444',default);
    

--repo de usuario pepim 
INSERT INTO repositorio(nombre, usuario, tipo_repositorio, cantidad_favoritos, cantidad_pull_request) VALUES
    ('Material unq','pepim','informativo',30,5);

--archivos
INSERT INTO archivo(id, nombre_repositorio, usuario_repositorio, contenido) VALUES
    (1,'Material unq','pepim','Cosas de Objetos'),
    (2,'Material unq','pepim','Cosas de Orga'),
    (3,'Material unq','pepim','Cosas de INPR');

--commit
INSERT INTO commit(hash, id_archivo, titulo, descripcion, fecha_cambio) VALUES
    ('Hash1',1,'Objetos','Agrego libros de objetos','2015-10-19'),
    ('Hash2',2,'Orga','Modifico libros de orga','2015-02-28'),
    ('Hash3',3,'INPR','Agrego ejercicios de gobstones','2022-10-29');

--contribucion
INSERT INTO contribucion(hash, usuario, cantidad_cambios) VALUES
    ('Hash1','solan',1),
    ('Hash2','solan',2),
    ('Hash3','solan',3);



 





