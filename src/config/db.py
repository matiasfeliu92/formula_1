from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
import pyodbc

from src.config.settings import Settings


class ManageDB:
    def __init__(self):
        settings = Settings()
        self.conn_string = (
            f"mssql+pyodbc://@{settings.SQL_SERVER_HOST}/{settings.SQL_SERVER_DB_USE}"
            "?driver=ODBC+Driver+17+for+SQL+Server"
            "&Trusted_Connection=yes"
        )
        self.conn_string_for_cursor = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={settings.SQL_SERVER_HOST};"
            f"DATABASE={settings.SQL_SERVER_DB};"
            "Trusted_Connection=yes;"
        )
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
        try:
            conn = pyodbc.connect(self.conn_string_for_cursor, autocommit=True)
            print("Conexión exitosa")
            return conn
        except pyodbc.Error as ex:
            sqlstate = ex.args[0]
            print(f"Error al conectar: {sqlstate}")
