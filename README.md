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
`python load.py`

I will be using a toy spark cluster for the smaller scale analysis. This will allow for easy scale-up later on.
1. Pull docker image:
`docker pull ewalsh200/toyspark:latest`
2. Build the image:
`docker build --tag ewalsh/toyspark:latest .`
3. Then connect to the spark docker instance:
`docker run -it --name espark -p 8080:8080 ewalsh200/toyspark:latest bash`
4. From the docker instance command line run the following:
4a. Start master.
`./sbin/start-master.sh`
4b. Find ip address.
`ip=$(hostname -i)``
4c. Start slave.
`./sbin/start-slave.sh $ip:7077`
