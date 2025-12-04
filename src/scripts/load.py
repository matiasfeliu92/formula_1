import logging
import pandas as pd
from sqlalchemy import text

from src.scripts.extract import Extract
from src.config.db import ManageDB
from src.config.settings import Settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


class Load:
    def __init__(self):
        self.settings = Settings()
        self.manage_db = ManageDB()
        self.extract = Extract()
        self.engine = None

    def load_csv(self, __df__: pd.DataFrame, __path__, __timestamp__=None):
        if "logs" in __path__:
            csv_logs_dir = self.settings.create_new_dir(["src", "logs", "csv"])
            output_dir_file = self.settings.get_file_path(
                ["src", "logs", "csv"], f"{__path__}_{__timestamp__}"
            )
            if not __df__.empty:
                __df__.to_csv(output_dir_file, encoding="utf-8-sig", index=False)
                logging.info(
                    f"Table {__path__}_{__timestamp__} was saved in {csv_logs_dir}"
                )

    def load_data_in_DB(self, __df__: pd.DataFrame, __path__, __year__, __month__):
        connection = self.manage_db.create_connection()
        cursor = connection.cursor()
        cursor.execute(
            f"""
            IF DB_ID('{self.settings.SQL_SERVER_DB_USE}') IS NULL
            BEGIN
                CREATE DATABASE {self.settings.SQL_SERVER_DB_USE};
            END
        """
        )
        connection.commit()
        cursor.execute(f"USE {self.settings.SQL_SERVER_DB_USE};").commit()
        logging.info(
            f'USANDO BASE DE DATOS: {cursor.execute("SELECT DB_NAME() AS current_database;").fetchone()}'
        )
        logging.info(
            cursor.execute(
                "SELECT name FROM sys.schemas WHERE name LIKE '%raw%';"
            ).fetchone()
        )
        cursor.execute(
            """
            IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'raw')
            BEGIN
                EXEC('CREATE SCHEMA raw AUTHORIZATION dbo')
            END
        """
        )
        connection.commit()
        self.engine = self.manage_db.create_engine()
        if not __df__.empty:
            logging.info(f"EL DATAFRAME POSEE {__df__.shape[0]} FILAS")
            schema = "raw"
            table_name = (
                f"{__path__}_{__year__}_{__month__}"
                if int(__month__) >= 10
                else f"{__path__}_{__year__}_0{__month__}"
            )
            with self.engine.connect() as conn:
                logging.info(
                    f"-----------------CONECTADO CORRECTAMENTE A {self.engine.url}-----------------"
                )
                __df__.to_sql(
                    table_name, conn, schema=schema, if_exists="replace", index=False
                )
                logging.info(
                    f"Table {table_name} was saved in {self.settings.SQL_SERVER_DB_USE}.{schema}"
                )
