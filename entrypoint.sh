#!/bin/bash 

  

# Espera a que Cassandra se inicie completamente 

until cqlsh -e "SHOW HOST" 2>&1 | grep "Connected" &> /dev/null; do 

    echo "Esperando a que Cassandra se inicie..." 

    sleep 5 

done 

  

# Ejecuta el script CQL 

cqlsh -f /app/etc/cassandra/schema.cql 

  

# Mantén el contenedor en ejecución 

exec "$@" 
