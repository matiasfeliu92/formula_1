from sqlalchemy import create_engine, exc
import pyodbc

class Config:
    def __init__(self, _db_host_, _db_user_, _db_password_, _db_name_):
        self.conn_string = (
            f'mssql+pyodbc://{_db_user_}:{_db_password_}@{_db_host_}/{_db_name_}?'
            'driver=ODBC+Driver+17+for+SQL+Server'
        )
        self.conn_string_for_cursor = (
            'DRIVER={{ODBC Driver 17 for SQL Server}};'
            'SERVER={server};'
            'DATABASE={db};'
            'UID={user};'
            'PWD={pwd};'
        ).format(
            server=_db_host_,
            db=_db_name_,
            user=_db_user_,
            pwd=_db_password_
        )
        self.engine = None
    
    def create_engine(self):
        try:
            self.engine = create_engine(self.conn_string)
            with self.engine.connect() as connection:
                print("CONNECTION ESTABISH SUCCESSFULLY")
            return self.engine
        except exc as e:
            print("THERE WAS AN ERROR WITH CONNECTION \n", str(e))

    def create_connection(self):
        try:
            conn = pyodbc.connect(self.conn_string_for_cursor, autocommit=True)
            print("Conexión exitosa")
            cursor = conn.cursor()
            return cursor
        except pyodbc.Error as ex:
            sqlstate = ex.args[0]
            print(f"Error al conectar: {sqlstate}")