CREATE KEYSPACE IF NOT EXISTS agile_data_science
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};


USE agile_data_science;

CREATE TABLE IF NOT EXISTS flight_delay_classification_response ("Origin" TEXT, "DayOfWeek" INT, "DayOfYear" INT, "DayOfMonth" INT, "Dest" TEXT, "DepDelay" DOUBLE, "Timestamp" TIMESTAMP, "FlightDate" TIMESTAMP, "Carrier" TEXT, "UUID" TEXT, "Distance" DOUBLE, "Route" TEXT, "Prediction" TEXT, PRIMARY KEY ("UUID")); 

