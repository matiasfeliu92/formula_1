import os
import logging
from typing import List
from sqlalchemy import create_engine, exc
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


class Settings:
    BASE_URL = "https://api.openf1.org/v1"
    BASE_DIR = os.getcwd()
    SESSIONS_ENDPOINT = "/sessions?date_start>{}&date_end<{}"
    MEETINGS_ENDPOINT = "/meetings?date_start>{}&date_start<{}&year={}" ##/meetings?date_start>2025-02-01T00:00:00+00:00&date_start<2025-02-28T00:00:00+00:00&year=2025
    DRIVERS_ENDPOINT = "/drivers?session_key={}"
    CARS_ENDPOINT = "/car_data?driver_number={}&session_key={}&speed>=290"
    LAPS_ENDPOINT = "/laps?session_key={}&driver_number={}"
    BASE_DIR = os.getcwd()
    # SQL_SERVER_USER = os.getenv("SQL_SERVER_USER")
    # SQL_SERVER_PASS = os.getenv("SQL_SERVER_PASS")
    # SQL_SERVER_HOST = os.getenv("SQL_SERVER_HOST")
    # SQL_SERVER_DB = os.getenv("SQL_SERVER_DB")
    # SQL_SERVER_DB_USE = os.getenv("SQL_SERVER_DB_USE")
    # SQL_SERVER_DB_USE = os.getenv("SQL_SERVER_DB_USE")
    POSTGRES_DB_USER = os.getenv("DB_USER")
    POSTGRES_DB_PASS = os.getenv("DB_PASS")
    POSTGRES_DB_HOST = os.getenv("DB_HOST")
    POSTGRES_DB_HOST_DOCKER = os.getenv("DB_HOST_DOCKER")
    POSTGRES_DB_NAME = os.getenv("DB_NAME")
    POSTGRES_DB_NAME_USE = os.getenv("DB_NAME_USE")
    # SQL_SERVER_CONNECTION_STRING = (
    #     f"mssql+pyodbc://{SQL_SERVER_USER}:{SQL_SERVER_PASS}@{SQL_SERVER_HOST}/{SQL_SERVER_DB}?"
    #     "driver=ODBC+Driver+17+for+SQL+Server"
    # )
    POSTGRES_CONNECTION_STRING = (
        f"postgresql+psycopg2://{POSTGRES_DB_USER}:{POSTGRES_DB_PASS}"
        f"@{POSTGRES_DB_HOST}:5432/{POSTGRES_DB_NAME_USE}"
    )
    POSTGRES_CONNECTION_STRING_DOCKER = (
        f"postgresql+psycopg2://{POSTGRES_DB_USER}:{POSTGRES_DB_PASS}"
        f"@{POSTGRES_DB_HOST_DOCKER}:5432/{POSTGRES_DB_NAME_USE}"
    )
    # SQL_SERVER_CURSOR_CONNECTION_STRING = (
    #     "DRIVER={{ODBC Driver 17 for SQL Server}};"
    #     "SERVER={server};"
    #     "DATABASE={db};"
    #     "UID={user};"
    #     "PWD={pwd};"
    # ).format(
    #     server=SQL_SERVER_HOST,
    #     db=SQL_SERVER_DB,
    #     user=SQL_SERVER_USER,
    #     pwd=SQL_SERVER_PASS,
    # )
    POSTGRES_CURSOR_CONNECTION_STRING = (
        "dbname={db} user={user} password={pwd} host={host} port={port}"
    ).format(
        db=POSTGRES_DB_NAME_USE,
        user=POSTGRES_DB_USER,
        pwd=POSTGRES_DB_PASS,
        host=POSTGRES_DB_HOST,
        port=5432,
    )
    POSTGRES_CURSOR_CONNECTION_STRING_DOCKER = (
        "dbname={db} user={user} password={pwd} host={host} port={port}"
    ).format(
        db=POSTGRES_DB_NAME_USE,
        user=POSTGRES_DB_USER,
        pwd=POSTGRES_DB_PASS,
        host=POSTGRES_DB_HOST_DOCKER,
        port=5432,
    )

    def create_new_dir(self, path: List[str]):
        logging.info(f'-------NEW DIR ---> {os.path.join(self.BASE_DIR, *path)}-------')
        os.makedirs(os.path.join(self.BASE_DIR, *path), exist_ok=True)
        output_dir = os.path.join(self.BASE_DIR, *path)
        return output_dir
    
    def get_file_path(self, path: List[str], file_name):
        logging.info(f'-------FILE PATH ---> {os.path.join(self.BASE_DIR, *path, file_name)}-------')
        file_path = os.path.join(self.BASE_DIR, *path, file_name)
        return file_path