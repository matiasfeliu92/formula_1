import logging
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
import pyodbc
import psycopg2

from src.config.settings import Settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


class ManageDB:
    def __init__(self, host=None):
        logging.info(f"------------HOST: {host} IN MANAGE DB------------")
        settings = Settings()
        self.conn_string = settings.POSTGRES_CONNECTION_STRING if host == "localhost" else settings.POSTGRES_CONNECTION_STRING_DOCKER
        self.conn_string_for_cursor = settings.POSTGRES_CURSOR_CONNECTION_STRING if host == "localhost" else settings.POSTGRES_CURSOR_CONNECTION_STRING_DOCKER
        self.engine = None

    def create_engine(self):
        try:
            self.engine = create_engine(self.conn_string)
            with self.engine.connect() as connection:
                print("CONNECTION ESTABISH SUCCESSFULLY")
            return self.engine
        except SQLAlchemyError as e:
            print("THERE WAS AN ERROR WITH CONNECTION \n", str(e))

    def create_connection(self):
        if "postgresql" in self.conn_string:
            try:
                conn = psycopg2.connect(self.conn_string_for_cursor)
                print("CONNECTION ESTABISH SUCCESSFULLY")
                return conn
            except psycopg2.Error as ex:
                print(f"Error al conectar: {ex}")
        else:
            try:
                conn = pyodbc.connect(self.conn_string_for_cursor, autocommit=True)
                print("Conexión exitosa")
                return conn
            except pyodbc.Error as ex:
                sqlstate = ex.args[0]
                print(f"Error al conectar: {sqlstate}")
