#!/bin/bash

# Import our enriched airline data as the 'airlines' collection
mongoimport --host mongo-container -d agile_data_science -c origin_dest_distances --file /practica_creativa/data/origin_dest_distances.jsonl
mongo agile_data_science --eval 'db.origin_dest_distances.ensureIndex({Origin: 1, Dest: 1})'
