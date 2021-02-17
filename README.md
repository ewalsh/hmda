# HMDA
project utilizing the home mortgage discolure act data

## Results and Output
The results can be found in a jupyter notebook within the py_code folder or within the pdf

## Preparation
I will utilize a PostgreSQL 11 server for storing and retrieving
data. Please make sure docker is installed.


Once installed, run the folling commands in your terminal:
1. To run the server:
`docker run -d --name pg_server -v dbdata:/var/lib/postgresql/data -p 54320:5432 postgres:11`
2. Check the logs to make sure the server is running.
`docker logs -f pg_server`
3. Create the databse:
`docker exec -it pg_server psql -U postgres -c "create database hmda_db"`
4. Load the notebook:
4a. Go to they python code directory:
`cd ./py_code`
4b. Launch the notebook
`jupyter notebook`
