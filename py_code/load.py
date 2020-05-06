"""Loading data into PostgreSQL."""
import psycopg2 as pg
import yaml
from pathlib2 import Path
import os
import pandas as pd
import configparser
from config import *


def load_config() -> list:
    with open(schema_path) as schema_file:
        config = yaml.safe_load(schema_file)
    return config


def create_tables(config: list, connection: pg.extensions.connection):
    cur = connection.cursor()
    for table in config:
        name = table.get('name')
        schema = table.get('schema')
        to_exec = f"""CREATE TABLE IF NOT EXISTS {name} ({schema})"""
        cur.execute(to_exec)
        print("""Created {} table.""".format(name))

    connection.commit()
    print("""Committed all creations.""")


def load_tables(
    config: list, connection: pg.extensions.connection, prefix: str=None
):
    # Iterate and load
    cur = connection.cursor()
    for table in config:
        table_name = table.get('name')
        table_name_csv = table_name if not prefix else prefix + table_name
        table_source = data_path.joinpath(f"{table_name_csv}.csv")
        print("""Started to load {} data to db from {}.""".format(table_name, table_source))
        with open(table_source, 'r', encoding='utf-8') as f:
            next(f)
            cur.copy_expert(f"COPY {table_name} FROM STDIN CSV NULL AS ''", f)
        connection.commit()
        print("""Completed loading {} table.""".format(table_name))


def load():
    # DB connection
    print("""Loading started""")
    print("""Establising connection to database {} listening on {}, port {} with user name: {}.""".format(dbname, host, port, user))
    connection = pg.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user
    )
    print("""Connection success.""")
    # Table creation and data insert
    csv_prefix = state + yr
    config = load_config()
    create_tables(config=config, connection=connection)
    load_tables(config=config, connection=connection, prefix=csv_prefix)
    print("""Loading completed.""")


if __name__ == '__main__':
    load()
