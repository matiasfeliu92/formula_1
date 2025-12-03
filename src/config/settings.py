import os
import logging
import pyodbc
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
    SQL_SERVER_USER = os.getenv("SQL_SERVER_USER")
    SQL_SERVER_PASS = os.getenv("SQL_SERVER_PASS")
    SQL_SERVER_HOST = os.getenv("SQL_SERVER_HOST")
    SQL_SERVER_DB = os.getenv("SQL_SERVER_DB")
    SQL_SERVER_DB_USE = os.getenv("SQL_SERVER_DB_USE")
    SQL_SERVER_CONNECTION_STRING = (
        f"mssql+pyodbc://{SQL_SERVER_USER}:{SQL_SERVER_PASS}@{SQL_SERVER_HOST}/{SQL_SERVER_DB}?"
        "driver=ODBC+Driver+17+for+SQL+Server"
    )
    SQL_SERVER_CURSOR_CONNECTION_STRING = (
        "DRIVER={{ODBC Driver 17 for SQL Server}};"
        "SERVER={server};"
        "DATABASE={db};"
        "UID={user};"
        "PWD={pwd};"
    ).format(
        server=SQL_SERVER_HOST,
        db=SQL_SERVER_DB,
        user=SQL_SERVER_USER,
        pwd=SQL_SERVER_PASS,
    )

    def create_new_dir(self, path: list[str]):
        logging.info(f'-------NEW DIR ---> {os.path.join(self.BASE_DIR, *path)}-------')
        os.makedirs(os.path.join(self.BASE_DIR, *path), exist_ok=True)
        output_dir = os.path.join(self.BASE_DIR, *path)
        return output_dir
    
    def get_file_path(self, path: list[str], file_name):
        logging.info(f'-------FILE PATH ---> {os.path.join(self.BASE_DIR, *path, file_name)}-------')
        file_path = os.path.join(self.BASE_DIR, *path, file_name)
        return file_path