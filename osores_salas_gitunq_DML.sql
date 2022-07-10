--PUNTO 1 revisado con el nuevo set de datos.
SELECT repositorio.nombre,repositorio.usuario,repositorio.tipo_repositorio 
FROM repositorio
JOIN archivo ON nombre_repositorio=repositorio.nombre
JOIN commit ON archivo.id=commit.id_archivo
JOIN contribucion ON contribucion.hash=commit.hash
JOIN (SELECT * 
	  FROM usuario 
	  WHERE usuario.ciudad='Quilmes') AS quilmenios 
ON quilmenios.usuario=contribucion.usuario  
GROUP BY repositorio.nombre,repositorio.usuario,repositorio.tipo_repositorio 
HAVING COUNT(commit) > 6;


--PUNTO 2 revisado con el nuevo set de datos. 
SELECT * 
FROM commit
JOIN archivo ON archivo.id=commit.id_archivo
JOIN contribucion ON contribucion.hash = commit.hash
WHERE fecha_cambio > ('2021-10-01')
ORDER BY commit.hash DESC, archivo.id ASC, commit.fecha_cambio DESC;


--PUNTO 3 revisado con el nuevo set de datos.
SELECT repositorio.nombre, repositorio.usuario, repositorio.tipo_repositorio, repositorio.cantidad_favoritos, repositorio.cantidad_pull_request 
FROM repositorio
JOIN contribucion ON contribucion.usuario=repositorio.usuario
JOIN usuario ON usuario.usuario=contribucion.usuario
WHERE usuario.ciudad='Solano'

INTERSECT

SELECT repositorio.nombre, repositorio.usuario, repositorio.tipo_repositorio, repositorio.cantidad_favoritos, repositorio.cantidad_pull_request 
FROM repositorio
JOIN contribucion ON contribucion.usuario=repositorio.usuario
JOIN usuario ON usuario.usuario=contribucion.usuario
WHERE date_part('year', age(fecha_nacimiento))::int between 18 AND 21;



 --PUNTO 4 revisado con el nuevo set de datos.
WITH contribucionesEnArchivoDeRepo AS (
SELECT nombre_repositorio, contribucion.usuario, COUNT(contribucion) AS contribuyo 
FROM archivo
JOIN commit ON archivo.id=commit.id_archivo
NATURAL JOIN contribucion
NATURAL JOIN usuario
GROUP BY nombre_repositorio, contribucion.usuario
)

SELECT nombre_repositorio, ROUND(AVG(contribuyo),2) 
FROM contribucionesEnArchivoDeRepo
JOIN 
(SELECT usuario 
FROM usuario 
WHERE usuario.ciudad='Quilmes') AS usuarioQuilmes
ON contribucionesEnArchivoDeRepo.usuario=usuarioQuilmes.usuario
GROUP BY contribucionesEnArchivoDeRepo.nombre_repositorio

INTERSECT --Tiene que ser bien de quilmes y de varela

SELECT nombre_repositorio, ROUND(AVG(contribuyo),2) 
FROM contribucionesEnArchivoDeRepo
JOIN 
(SELECT usuario 
FROM usuario 
WHERE usuario.ciudad='Varela') AS usuarioVarela
ON contribucionesEnArchivoDeRepo.usuario=usuarioVarela.usuario
GROUP BY contribucionesEnArchivoDeRepo.nombre_repositorio;
 
--PUNTO 5 AL HABER DOS USUARIOS CON LA MISMA CANTIDAD DE COMMITS, RETORNA A AMBOS, SI LOS DOS COMMITEARON UNA VEZ, VAN A APARECER LOS DOS EN EL RESULTADO CON UN 1.
WITH commits_por_archivo AS (
							SELECT archivo.id, contribucion.usuario, COUNT(commit) AS cantidad 
							FROM archivo
							JOIN commit ON archivo.id=commit.id_archivo
							NATURAL JOIN contribucion
							GROUP BY archivo.id, contribucion.usuario
							)

SELECT orig.id, orig.usuario, orig.cantidad 
FROM commits_por_archivo AS orig
JOIN (SELECT max(cantidad) AS max_cantidad, id 
						   FROM commits_por_archivo 
						   GROUP BY id) AS max
ON orig.cantidad = max.max_cantidad AND orig.id = max.id;


--PUNTO 6
WITH contribucionesEnArchivoDeRepo AS (
SELECT contribucion.usuario, contribucion.cantidad_cambios AS cantcambios, COUNT(contribucion) AS sumaDeContribuciones 
FROM archivo
JOIN commit ON archivo.id=commit.id_archivo
NATURAL JOIN contribucion
GROUP BY contribucion.usuario, contribucion.cantidad_cambios
)

SELECT contribucionesEnArchivoDeRepo.usuario, SUM(contribucionesEnArchivoDeRepo.sumaDeContribuciones) AS sumaContribuciones, AVG(contribucionesEnArchivoDeRepo.cantcambios) AS promediocambios
FROM contribucionesEnArchivoDeRepo
GROUP BY contribucionesenarchivoderepo.usuario, contribucionesEnArchivoDeRepo.sumaDeContribuciones 
ORDER BY sumaContribuciones DESC, promediocambios DESC;


--PUNTO 7 

--uno todos los usuarios que hicieron contribuciones y son dueños del repo,
-- les resto los que tienen 0 contribuciones, y le hago una unión con los
--usuarios que tienen al menos 3 contribuciones
--revisado con el nuevo set de datos.
(SELECT repositorio.usuario, repositorio.nombre 
 FROM repositorio
 JOIN contribucion ON repositorio.usuario=contribucion.usuario

EXCEPT 

SELECT repositorio.usuario, repositorio.nombre 
FROM repositorio
JOIN contribucion ON repositorio.usuario=contribucion.usuario
GROUP BY repositorio.usuario, repositorio.nombre
HAVING COUNT(contribucion.usuario)=0)

UNION

SELECT repositorio.usuario, repositorio.nombre 
FROM repositorio
JOIN contribucion ON repositorio.usuario=contribucion.usuario
GROUP BY repositorio.usuario, repositorio.nombre
HAVING COUNT(contribucion.usuario) >= 3;



--PUNTO 8 revisado con el nuevo set de datos.
SELECT COUNT(repositorio.nombre) AS reposSuperSeguros 
FROM repositorio
JOIN usuario ON usuario.usuario=repositorio.usuario
JOIN contribucion ON usuario.usuario=contribucion.usuario
WHERE usuario.contrasenia LIKE '%#%' 
AND char_length(usuario.contrasenia) > 32 
GROUP BY repositorio.cantidad_favoritos
HAVING COUNT(contribucion.usuario) > 10
ORDER BY repositorio.cantidad_favoritos DESC;



--PUNTO 9 revisado con el nuevo set de datos.

SELECT masmodificados.id 
FROM
((SELECT archivo.id, cantidad_cambios 
FROM archivo
JOIN commit ON archivo.id=commit.id_archivo
JOIN contribucion ON commit.hash=contribucion.hash
JOIN usuario ON contribucion.usuario=usuario.usuario
WHERE usuario.cantidad_pull_request > 6 AND fecha_cambio between '2021/01/01' AND '2021/12/31')

UNION

(SELECT archivo.id, cantidad_cambios 
FROM archivo
JOIN repositorio ON repositorio.usuario=archivo.usuario_repositorio
JOIN contribucion ON contribucion.usuario = archivo.usuario_repositorio
GROUP BY archivo.id, contribucion.cantidad_cambios
HAVING COUNT(repositorio.usuario) < 3)) AS masmodificados
ORDER BY masmodificados.cantidad_cambios DESC
LIMIT 3;

--PUNTO 10  revisado con el nuevo set de datos, cada contribuidor menor a 21 años solo hizo una contribución por repositorio
WITH cantContEdad AS (
					 SELECT contribucion.usuario, contribucion.hash, COUNT(contribucion.usuario) as contribuidores 
					 FROM contribucion
 					 JOIN usuario ON contribucion.usuario=usuario.usuario
  					 WHERE date_part('year', age(fecha_nacimiento))::int < 21
  					 GROUP BY contribucion.usuario, contribucion.hash, date_part('year', age(fecha_nacimiento))::int 
)

SELECT archivo.nombre_repositorio, cantContEdad.contribuidores
FROM cantContEdad
JOIN commit ON cantContEdad.hash=commit.hash
JOIN archivo ON commit.id_archivo=archivo.id
GROUP BY archivo.nombre_repositorio, cantContEdad.contribuidores;

--PUNTO 11 revisado con el nuevo set de datos.

WITH commits_usuarios AS (
 			  SELECT usuario.usuario, COUNT(commit.hash) AS cant_commit, nyap, ciudad 
              FROM contribucion
              JOIN usuario ON contribucion.usuario=usuario.usuario
              JOIN commit ON commit.hash=contribucion.hash
              GROUP BY usuario.usuario)
     
     
SELECT usuario, cant_commit 
FROM commits_usuarios
GROUP BY usuario, cant_commit, nyap, ciudad
HAVING cant_commit > (SELECT AVG(cant_commit) 
		      FROM commits_usuarios)
ORDER BY nyap ASC, ciudad ASC, cant_commit DESC;

     
--PUNTO 12 revisado con el nuevo set de datos
WITH commits_por_usuario AS (
						SELECT repositorio.nombre, contribucion.usuario, SUM(cantidad_cambios) AS cantidad_total 
						FROM contribucion
  						JOIN commit ON commit.hash=contribucion.hash
  						JOIN archivo ON archivo.id=commit.id_archivo
  						JOIN repositorio ON repositorio.nombre=archivo.nombre_repositorio
						GROUP BY repositorio.nombre, contribucion.usuario					
),

     usuario_insignia AS (
     SELECT commits_por_usuario.nombre, MAX(cantidad_total) as mayor 
     FROM commits_por_usuario
	 GROUP BY commits_por_usuario.nombre
     )


SELECT commits_por_usuario.usuario 
FROM usuario_insignia
JOIN commits_por_usuario ON commits_por_usuario.nombre=usuario_insignia.nombre
GROUP BY commits_por_usuario.usuario,usuario_insignia.mayor, commits_por_usuario.cantidad_total
HAVING usuario_insignia.mayor = commits_por_usuario.cantidad_total;

--PUNTO 13 DE LA PARTE DE DML 
CREATE INDEX idx_commit ON commit (id_archivo, fecha_cambio);


--PUNTO 14
create view view_usuarios_del_punto_14( usuarios_resultantes.usuario )AS (

        with usuarios_repositorios AS(
            SELECT repositoriosEspeciales.usuario, repositoriosEspeciales.nombre 
              FROM 
                (SELECT usuario, COUNT(usuario)
                 FROM repositorio
                 GROUP BY usuario
                 HAVING COUNT(usuario) < 3)AS repositorios
                JOIN
                (SELECT usuario, nombre 
                  FROM repositorio
                  WHERE cantidad_favoritos > 100 AND cantidad_pull_request <20)AS repositoriosEspeciales
                  ON repositorios.usuario = repositoriosEspeciales.usuario
                  JOIN usuario ON usuario.usuario = repositorios.usuario
                  WHERE date_part('year', age(fecha_nacimiento))::int BETWEEN 1990 AND 1999
        ),
          contribuciones_en_repos_quilmes AS (
                        SELECT nombre_repositorio, contribucion.usuario, COUNT(contribucion) AS contribuyo 
                        FROM archivo
                        JOIN commit ON archivo.id=commit.id_archivo
                        NATURAL JOIN contribucion
                        JOIN repositorio ON archivo.nombre_repositorio = repositorio.nombre
                        JOIN usuario ON repositorio.usuario=usuario.usuario
                        WHERE usuario.ciudad='Quilmes'
                        GROUP BY nombre_repositorio, contribucion.usuario
          )


      (	SELECT contribuciones_en_repos_quilmes.usuario 
      	FROM contribuciones_en_repos_quilmes
      	GROUP BY contribuciones_en_repos_quilmes.nombre_repositorio, contribuciones_en_repos_quilmes.usuario
      	HAVING AVG(contribuyo) > 5

   		INTERSECT 

      	SELECT usuarios_repositorios.usuario 
      	FROM usuarios_repositorios
      	JOIN(SELECT usuario, archivo.nombre_repositorio 
            FROM contribucion 
            JOIN commit ON contribucion.hash = commit.hash
            JOIN archivo ON archivo.id = commit.id_archivo
            GROUP BY usuario, archivo.nombre_repositorio
            HAVING COUNT(commit)>= 5 )AS commiteros 
            ON usuarios_repositorios.usuario = commiteros.usuario
     )AS usuarios_resultantes
);

--PUNTO 15
--En la tabla usuario conocemos su usuario, pero tenemos un requerimiento que exige al sistema que la
--combinación de correos y ciudad sea única. Aplique una estrategia para resolverlo.
--SOL: Para responder a la solicitud debería incorporar a la clave primaria de la tabla usuario los atributos ciudad y correo en la misma, logrando tener por ejemplo:
-- bianca, bianca_neuquen@gmail.com, neuquen
-- bianca, bianca_cordoba@gmail.com, cordoba 
-- en este caso podemos notar que cada usuario va a tener más de un correo y más de una ciudad, pero no se podrá repertir la tupla (ciudad,correo) en cada insercción de la fila logrando la unicidad en cada combinación. 
