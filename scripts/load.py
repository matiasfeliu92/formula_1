import os
import pandas as pd
from DB import Config
from dotenv import load_dotenv

load_dotenv()

class Load:
    def __init__(self):
        self.BASE_DIR = os.getcwd()
        self.DimCountries = pd.DataFrame()
        self.DimCircuits = pd.DataFrame()
        self.DimMeetings = pd.DataFrame()
        self.DimDrivers = pd.DataFrame()
        self.DimSessions = pd.DataFrame()
        self.FactCars = pd.DataFrame()
        self.FactLaps = pd.DataFrame()
        self.data_model = {}
        self.DB_USER = os.getenv("SQL_SERVER_USER")
        self.DB_PASSWORD = os.getenv("SQL_SERVER_PASS")
        self.DB_HOST = os.getenv("SQL_SERVER_HOST")
        self.DB_NAME = os.getenv("SQL_SERVER_DB")
        self.config = Config(self.DB_HOST, self.DB_USER, self.DB_PASSWORD, self.DB_NAME)

    def model_data(self, dict_: dict):
        print("**********MODELING TRANSFORMED DATA**********")
        for key, value in dict_.items():
            if key == 'meetings':
                df_countries = value[['country_key', 'country_code', 'country_name']].drop_duplicates(subset=['country_key'])
                self.DimCountries = pd.concat([self.DimCountries, df_countries], ignore_index=True).sort_values(by='country_key', ascending=True)
                self.data_model['DimCountries'] = self.DimCountries

                df_circuits = value[['circuit_key',	'circuit_short_name', 'meeting_code', 'location']].drop_duplicates(subset=['circuit_key', 'circuit_short_name', 'meeting_code', 'location'])
                self.DimCircuits = pd.concat([self.DimCircuits, df_circuits], ignore_index=True).sort_values(by='circuit_key', ascending=True)
                self.data_model['DimCircuits'] = self.DimCircuits

                df_meetings = value[['meeting_key', 'meeting_name', 'circuit_key', 'country_key']].drop_duplicates(subset=['meeting_key', 'meeting_name', 'circuit_key', 'country_key'])
                self.DimMeetings = pd.concat([self.DimMeetings, df_meetings], ignore_index=True).sort_values(by='meeting_key', ascending=True)
                self.data_model['DimMeetings'] = self.DimMeetings
            if key == 'drivers':
                df_drivers = value[['driver_number', 'broadcast_name', 'full_name', 'team_name', 'country_code']].drop_duplicates(subset=['driver_number'])
                self.DimDrivers = pd.concat([self.DimDrivers, df_drivers], ignore_index=True).sort_values(by='driver_number', ascending=True)
                self.data_model['DimDrivers'] = self.DimDrivers
            if key == 'sessions':
                df_sessions = value[['session_key', 'meeting_key', 'date_start', 'date_end', 'session_type', 'session_name', 'country_key', 'circuit_key']]
                self.DimSessions = pd.concat([self.DimSessions, df_sessions], ignore_index=True).sort_values(by='session_key', ascending=True)
                self.data_model['DimSessions'] = self.DimSessions
            if key == 'cars':
                df_cars = value[[
                    "date", "session_key", "meeting_key", "driver_number", 
                    "brake", "throttle", "drs", "speed", "rpm", "n_gear"
                ]]
                self.FactCars = pd.concat([self.FactCars, df_cars], ignore_index=False)
                self.FactCars.index = range(1, len(self.FactCars) + 1)
                self.FactCars.index.name = "cars_id"
                self.data_model[f'FactCars'] = self.FactCars
            if key == 'laps':
                df_laps = value[["lap_number", "session_key", "driver_number", "date_start", "lap_duration", "duration_sector_1",	"duration_sector_2", "duration_sector_3", "i1_speed", "i2_speed", "is_pit_out_lap", "segments_sector_1", "segments_sector_2", "segments_sector_3", "st_speed"]]
                self.FactLaps = pd.concat([self.FactLaps, df_laps], ignore_index=False)
                self.FactLaps.index = range(1, len(self.FactLaps) + 1)
                self.FactLaps.index.name = "laps_id"
                self.data_model[f'FactLaps'] = self.FactLaps
        return self.data_model
    
    def load_data(self, dict: dict):
        cursor = self.config.create_connection()
        cursor.execute("""
            IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Formula1')
            BEGIN
                CREATE DATABASE Formula1
            END
        """)
        cursor.execute("USE Formula1;")
        self.config = Config(self.DB_HOST, self.DB_USER, self.DB_PASSWORD, "Formula1")
        engine = self.config.create_engine()
        output_dir = os.path.join(self.BASE_DIR, "data", "transformed")
        os.makedirs(output_dir, exist_ok=True)
        for key, value in dict.items():
            print({"TABLE": key, "COLUMNS": value.columns})
            if "Fact" in key:
                print(value.sample(5))
                print(value.info())
                value.to_csv(os.path.join(output_dir, f'{key}.csv'), index=True, sep=";")
                print(f"FILE {os.path.join(output_dir, f'{key}.csv')} WAS SAVED")
                sql_server_table = key
                value.to_sql(
                    name=sql_server_table,
                    con=engine,
                    if_exists='replace',
                    index=False
                )
                print(f"TABLE {sql_server_table} WAS SAVED")
            else:
                value.to_csv(os.path.join(output_dir, f'{key}.csv'), index=False, sep=";")
                print(f"FILE {os.path.join(output_dir, f'{key}.csv')} WAS SAVED")
                sql_server_table = key
                value.to_sql(
                    name=sql_server_table,
                    con=engine,
                    if_exists='replace',
                    index=False
                )
                print(f"TABLE {sql_server_table} WAS SAVED")