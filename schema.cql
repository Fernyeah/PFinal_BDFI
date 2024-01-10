CREATE KEYSPACE IF NOT EXISTS agile_data_science
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE agile_data_science;

CREATE TABLE IF NOT EXISTS flight_delay_classification_response (
    UUID UUID PRIMARY KEY,
    Carrier TEXT,
    DayOfMonth INT,
    DayOfWeek INT,
    DayOfYear INT,
    DepDelay INT,
    Dest TEXT,
    Distance INT,
    FlightDate DATE,
    Origin TEXT,
    Prediction DOUBLE,
    Route TEXT,
    Timestamp TIMESTAMP
);
