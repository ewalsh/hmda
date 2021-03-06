"""Config file."""
import os
from pathlib2 import Path

# Set Path
schema_path = Path(
    os.environ['HOME'],
    'Projects',
    'hmda',
    'py_code',
    'misc',
    'schemas.yaml'
)

data_path = Path(
    os.environ['HOME'],
    'Projects',
    'hmda',
    'data',
    'load'
)

host = 'localhost'
port = 54320
dbname = 'hmda_db'
user = 'postgres'
state = 'OH'
yr = 2016
api_key = #'ENTER YOUR KEY INTO ./py_code/config.py'
