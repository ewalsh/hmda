# HMDA
project utilizing the home mortgage discolure act data

## Preparation
I will utilize a PostgreSQL 11 server for storing and retrieving
data and Docker for hosting it. Please make sure docker is installed.

Once installed, run the folling commands in your terminal:
1. To run the server:
`docker run -d --name pg_server -v dbdata:/var/lib/postgresql/data -p 54320:5432 postgres:11`
2. Check the logs to make sure the server is running.
`docker logs -f pg_server`
3. Create the databse:
`docker exec -it pg_server psql -U postgres -c "create database hmda_db"`
4. Modify the paths in the config.py script and run it to load the csv training data into the DB. Then populate the database:
`python etl.py`
