# Práctica Final - Predicción de vuelos

## Implementaciones realizadas

A partir del escenario proporcionado, se han realizado las siguientes implementaciones:

- Se ha modificado el código para que el resultado de la predicción se escriba en Cassandra en lugar de MongoDB y se presente en la aplicación.
- Se ha Dockerizado cada uno de los servicios que componen la arquitectura completa y desplegado el escenario completo usando docker-compose.
- Se ha desplegado el escenario completo (docker-compose) en Google Cloud.

### Cassandra como BBDD para el resultado de la predicción

Se han modificado los archivos `predict_flask.py` y `MakePrediction.scala` para modificar la base de datos de guardado de la predicción. Concectándolo así con Cassandra.

### Dockerizado de los servicios

Para el dockerizado de los servicios presentes en el sistema ha sido necesario la creación de las imagenes:

- cassandra-service
- flask-web-service
- spark-service

Además se han empleado imagenes existentes para:

- mongo:6.0
- bitnami/zookeeper:3.7
- bitnami/kafka:3.4

Mediante el _docker-compose_ se han creado los contenedores:

- mongo-container
- zookeeper-container
- kafka
- cassandra-container
- flask-container
- spark-master
- spark-worker-1
- spark-worker-2
- spark-submit

Al dockerizar todos los servicios del escenario ha sido necesario modificar los archivos `predict_flask.py` y `MakePrediction.scala` para conectarlos con los contenedores necesarios que ejecuten cada servicio.

### Despliegue del escenario en Google Cloud

Para el despliegue del escenario en Google Cloud se ha hecho uso de los créditos facilitados por la Escuela. 
Se ha creado una máquina virtual en Google Cloud y desplegado el sistema siguiendo los pasos indicados a continuación.


## Instrucciones para el despliegue del escenario

Para el despliegue del escenario en Google Cloud serán necesarios 3 pasos.
- Crear y configurar la máquina virtual.
- Instalar las dependencias necesarias.
- Arrancar el sistema propiamente dicho.

### Creación y configuración de la máquina virtual

En cuanto a la creación del escenario. Debemos dirigirnos a nuestro panel de Google Cloud y crear una Máquina Virtual dentro de nuestro espacio de trabajo.
**IMPORTANTE** Necesitaremos aumentar el tamaño del disco de la MV, de esta manera podremos trabajar sin problemas de almacenamiento al crear las diferentes imágenes de docker.

Además, es importante crear 2 reglas de Firewall, para habilitar las comunicaciones in & out por el puerto 5001.

### Instalaciones previas

Para el desarrollo del despligue es necesario disponer de diferentes dependencias.

- Instalación de docker

- Intalación de docker-compose

- Instalación de sbt

- Instalación de git


### Inicio del sistema

Una vez arrancada la MV, es recomendable abrir 4 terminales diferentes, para así poder manejar de mejor manera los distintos componentes del sistema.

#### Importación del escenario

Abriremos un terminal y ejecutaremos:
```
git clone https://github.com/Fernyeah/PFinal_BDFI.git
```
Además, ejecutaremos:
```
resources/download_data.sh
```

#### Construcción de las imagenes

Para construir las imagenes necesarias contamos con diferentes Dockerfiles, para crear estas imagenes ejecutaremos:
```
docker build -t cassandra-service -f Dockerfile-cassandra
```
```
docker build -t flask-web-service -f Dockerfile-flask
```
```
docker build -t spark-service -f Dockerfile-spark 
```

#### Inicio del escenario

Una vez creadas las imagenes, crearemos el compose, con el comando:
```
docker-compose up
```

Una vez arranque el despliegue, es cuando utilizaremos los otros 3 terminales que hemos iniciado.

En uno de los terminales, entraremos en el contenedor de _Mongo_ para importar los datos:
```
docker exec -it mongo-container /bin/bash
```

Importaremos los datos con:
```
mongoimport --host mongo-container -d agile_data_science -c origin_dest_distances --file /practica_creativa/data/origin_dest_distances.jsonl
```

En un nuevo terminal, crearemos el topic de _Kafka_:
```
docker exec kafka /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic flight_delay_classification_request --partitions 1 --replication-factor 1 --bootstrap-server kafka:9092 
```

En el último de los terminales, entraremos al contenedor de _Cassandra_, para crear la base de datos y la tabla.
```
docker exec -it cassandra-container /bin/bash
```

```
cqlsh
```

Una vez dentro del terminal cqlsh (no será accesible hasta pasados unos segundos):
```
CREATE KEYSPACE IF NOT EXISTS agile_data_science WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}; 
```

```
USE agile_data_science; 
```

```
CREATE TABLE IF NOT EXISTS flight_delay_classification_response ("Origin" TEXT, "DayOfWeek" INT, "DayOfYear" INT, "DayOfMonth" INT, "Dest" TEXT, "DepDelay" DOUBLE, "Timestamp" TIMESTAMP, "FlightDate" TIMESTAMP, "Carrier" TEXT, "UUID" TEXT, "Distance" DOUBLE, "Route" TEXT, "Prediction" TEXT, PRIMARY KEY ("UUID")); 
```

Una vez realizados estos comandos, pasados xxx segundos desde el inicio de _docker-compose up_ se ejecutará el comando _spark-submit_.
Después, podremos ver como se ejecuta el contenedor _flask_ , entonces será cuando podamos acceder a la web para comprobar el correcto funcionamiento del sistema.

Accede a la dirección http://localhost:5001/flights/delays/predict_kafka .

Ejecuta el submit de la página web y comprueba los resultados obtenidos. 

Para comprobar el correcto guardado de dichas predicciones en nuestra base de datos _Cassandra_ ejecuta en el terminal de _cqlsh_ de Cassandra el siguiente comando:
```
SELECT * FROM flight_delay_classification_response;
```

