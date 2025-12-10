from datetime import datetime, timedelta
import logging
import pandas as pd
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.models.param import Param
from airflow.providers.postgres.hooks.postgres import PostgresHook

from config.settings import Settings
from scripts import Extract, Load
from utils.helpers import Helpers

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

class ELT:
    def __init__(self, year: int, month: int):
        self.year = str(year)
        self.month = str(month)
        self.settings = Settings()
        self.helpers = Helpers()
        self.session_endpoint = self.settings.SESSIONS_ENDPOINT
        self.meetings_endpoint = self.settings.MEETINGS_ENDPOINT
        self.drivers_endpoint = self.settings.DRIVERS_ENDPOINT
        self.cars_endpoint = self.settings.CARS_ENDPOINT
        self.laps_endpoint = self.settings.LAPS_ENDPOINT
        self.min_max_date = self.helpers.get_max_date_of_month(
            int(self.year), int(self.month)
        )
        self.min_date = self.min_max_date[0]
        self.max_date = self.min_max_date[1]
        self.extract = Extract()
        self.load = Load("docker")
        self.sessions = pd.DataFrame()
        self.meetings = pd.DataFrame()
        self.drivers = pd.DataFrame()
        self.cars_data = pd.DataFrame()
        self.laps = pd.DataFrame()

    def run(self):
        logging.info(
            f"----------------------EXTRACTING DATA FOR YEAR: {self.year}, MONTH: {self.month}, BETWEEN {self.min_date} AND {self.max_date}----------------------"
        )
        logging.info(
            "-----------------------------------------sessions-----------------------------------------"
        )
        self.sessions = self.extract.extract_data(
            self.session_endpoint.format(self.min_date, self.max_date)
        )
        if not self.sessions.empty:
            logging.info(self.sessions.info())
            self.load.load_data_in_DB(
                self.sessions, "sessions", self.year, self.month
            )
            logging.info("")
            logging.info("")
            logging.info("")
            logging.info(
                "-----------------------------------------meetings-----------------------------------------"
            )
            self.meetings = self.extract.extract_data(
                self.meetings_endpoint.format(
                    self.min_date, self.max_date, self.year
                )
            )
            if not self.meetings.empty:
                logging.info(self.meetings.info())
            self.load.load_data_in_DB(
                self.meetings, "meetings", self.year, self.month
            )
            logging.info("")
            logging.info("")
            logging.info("")
            logging.info(
                "-----------------------------------------drivers-----------------------------------------"
            )
            self.drivers = self.extract.extract_data(
                self.drivers_endpoint, self.sessions
            )
            if not self.drivers.empty:
                logging.info(self.drivers.info())
            self.load.load_data_in_DB(
                self.drivers, "drivers", self.year, self.month
            )
            logging.info("")
            logging.info("")
            logging.info("")
        else:
            logging.error(
                f"THERE ARE NO SESSIONS AVAILABLES FOR PERIOD {self.year}-{self.month}"
            )
        if not self.drivers.empty:
            logging.info(
                "-----------------------------------------cars data-----------------------------------------"
            )
            self.cars_data = self.extract.extract_data(
                self.cars_endpoint, self.drivers
            )
            if not self.cars_data.empty:
                logging.info(self.cars_data.info())
            self.load.load_data_in_DB(
                self.cars_data, "cars_data", self.year, self.month
            )
            logging.info("")
            logging.info("")
            logging.info("")
            logging.info(
                "-----------------------------------------laps-----------------------------------------"
            )
            self.laps = self.extract.extract_data(self.laps_endpoint, self.drivers)
            if not self.laps.empty:
                logging.info(self.laps.info())
            self.load.load_data_in_DB(self.laps, "laps", self.year, self.month)
            logging.info("")
            logging.info("")
            logging.info("")
        df_error_logs = self.extract.create_error_log_table()
        logging.info(f"LOS ERROR LOG TIENEN {df_error_logs.shape[0]} FILAS")
        self.load.load_csv(
            df_error_logs,
            "error_logs",
            __timestamp__=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        )

def run_elt_task(**kwargs):
    """
    Función que Airflow llama. Extrae los parámetros y ejecuta la lógica.
    """
    params = kwargs['params']
    year = params.get('execution_year', datetime.now().year)
    month = params.get('execution_month', datetime.now().month)

    logging.info(f"Airflow Task received parameters: Year={year}, Month={month}")

    elt_instance = ELT(year=year, month=month)
    elt_instance.run()

def union_similar_tables():
    hook = PostgresHook(postgres_conn_id="mi_conexion_formula1")
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'raw'
        and tablename LIKE '%sessions_20%'
        or tablename LIKE '%meetings_20%'
        or tablename LIKE '%cars_data_20%'
        or tablename LIKE '%drivers_20%'
        or tablename LIKE '%laps_20%'
    """)
    tables = [row[0] for row in cursor.fetchall()]
    logging.info(f"''''''''''''TABLAS ENCONTRADAS: {tables}''''''''''''")
    similar_tables = {}
    similar_tables["sessions"] = 'CREATE OR REPLACE VIEW raw.all_sessions AS '+' UNION '.join([f"SELECT * FROM raw.{table}" for table in tables if 'sessions' in table])
    similar_tables["meetings"] = 'CREATE OR REPLACE VIEW raw.all_meetings AS '+' UNION '.join([f"SELECT * FROM raw.{table}" for table in tables if 'meetings' in table])
    similar_tables["drivers"] = 'CREATE OR REPLACE VIEW raw.all_drivers AS '+' UNION '.join([f"SELECT * FROM raw.{table}" for table in tables if 'drivers' in table])
    similar_tables["cars"] = 'CREATE OR REPLACE VIEW raw.all_cars AS '+' UNION '.join([f"SELECT * FROM raw.{table}" for table in tables if 'cars_data' in table])
    similar_tables["laps"] = 'CREATE OR REPLACE VIEW raw.all_laps AS '+' UNION '.join([f"SELECT * FROM raw.{table}" for table in tables if 'laps' in table])
    logging.info(f"''''''''''''QUERIES TABLAS UNIFICADAS: {similar_tables}''''''''''''")

    for item, view_query in similar_tables.items():
        cursor.execute(view_query)
        conn.commit()

    cursor.close()
    conn.close()

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['matumazparrote@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}
    
with DAG(
    dag_id='ELT_Formula_1',
    default_args=default_args,
    description='Extract, Load, and Transform data of Formula 1 using execution parameters (Year/Month).',
    schedule_interval=None,
    start_date=datetime(2023, 1, 1),
    catchup=False,
    tags=['formula1', 'elt', 'dynamic'],
    params={
        "execution_year": Param(
            datetime.now().year, 
            type="integer",
            minimum=2023,
            description="Año de los datos a procesar (YYYY)"
        ),
        "execution_month": Param(
            datetime.now().month, 
            type="integer",
            minimum=1,
            maximum=12,
            description="Mes de los datos a procesar (MM)"
        )
    }
) as dag:
    
    run_main_elt = PythonOperator(
        task_id="run_main_elt_process",
        python_callable=run_elt_task,
        op_kwargs={"year": datetime.now().year, "month": datetime.now().month}
    )

    union_tables = PythonOperator(
        task_id="unir_tablas_por_prefijo",
        python_callable=union_similar_tables
    )

    run_main_elt >> union_tables