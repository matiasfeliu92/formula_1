import json
import os
import pandas as pd
import numpy as np

class Transform:
    missing_drivers = None

    def __init__(self):
        self.BASE_DIR = os.getcwd()
        self.raw_data = [
            os.path.join(self.BASE_DIR, "data", "raw", file_name) 
            for file_name in os.listdir(os.path.join(self.BASE_DIR, "data", "raw"))
            if '_202' not in file_name
        ]
        self.unified_f1_data = {}
        with open(os.path.join(self.BASE_DIR, "data", "other", 'missing_drivers.json'), 'r', encoding='utf-8') as archivo:
            self.missing_drivers = json.load(archivo)
    
    def unify_data(self):
        paths = {file_.split("\\")[-1].split(".")[0].split("_")[0] for file_ in self.raw_data}
        for path in paths:
            df_unified = pd.DataFrame()
            path_files = [file_name for file_name in self.raw_data if path in file_name]
            reference_columns = None
            print("PATH: ", path_files)
            for i, file_ in enumerate(path_files):
                df = pd.read_csv(file_, sep=";")
                if i == 0:
                    reference_columns = df.columns.to_list()
                else:
                    df = df[reference_columns]
                    print({"FILE": file_, "COLUMNS after reorder": df.columns.to_list()})
                df_unified = pd.concat([df_unified, df], ignore_index=True)
            print({"**********PATH**********": path, "**********COLUMNS**********": df_unified.columns.to_list()})
            self.unified_f1_data[path] = df_unified
        return self.unified_f1_data
    
    def fill_nuls(self, key: str, df_: pd.DataFrame):
        for column_ in df_.columns:
            nulos = df_[column_].isnull().sum()
            porcentaje = (nulos / len(df_)) * 100
            print(f"-----------------NULL VALUES FOR {key}['{column_}']: {round(porcentaje, 2)}% BEFORE FILL-----------------")
            if 'duration' in column_:
                df_[column_] = df_[column_].fillna(0)
            if 'date' in column_:
                df_[column_] = df_[column_].fillna(pd.NaT)
            if key == 'drivers':
                for key_, value_ in self.missing_drivers.items():
                    find_condition = df_['broadcast_name'].str.contains(key_, case=False, na=False)
                    for col, val in value_.items():
                        df_.loc[find_condition, col] = val
            print(f"-----------------NULL VALUES FOR {key}['{column_}']: {round(porcentaje, 2)}% AFTER FILL-----------------")

    def convert_fields(self, df_: pd.DataFrame):
        print("**********CONVERSION DE TIPO DE DATOS**********")
        for column_ in df_.columns:
            if 'date_' in column_:
                df_[column_] = pd.to_datetime(df_[column_], errors="coerce")
            if 'date' in column_:
                df_[column_] = pd.to_datetime(df_[column_], format='mixed', utc=True, errors='coerce')
            if 'duration' in column_:
                df_[column_] = df_[column_].replace([np.inf, -np.inf], np.nan)
                df_[column_] = df_[column_].astype("int64") // 10**6
            if 'gmt_offset' in column_:
                df_[column_] = df_[column_].astype(str).str.strip()
                df_[column_] = pd.to_timedelta(df_[column_], errors='coerce')
            if '_key' in column_ or '_number' in column_:
                df_[column_] = df_[column_].round().astype('int64')
            if 'speed' in column_ and not '_speed' in column_ or 'throttle' in column_ or 'drs' in column_ or 'rpm' in column_ or 'n_gear' in column_:
                df_[column_] = df_[column_].round().astype('int64')

    def remove_timezones(self, df, sheet_name=None):
        tz_cols = df.select_dtypes(include=["datetimetz"]).columns
        if len(tz_cols) > 0 and sheet_name:
            print(f"🕒 '{sheet_name}': columnas con timezone -> {list(tz_cols)}")
        for col in tz_cols:
            df[col] = df[col].dt.tz_localize(None)

    def transform_data(self, unified_data_: dict):
        for key, value in unified_data_.items():
            print("")
            print({'SOURCE': key, 'COLUMNS': value.columns})
            print(value.info())
            print("")
            self.fill_nuls(key, value)
            print("")
            self.convert_fields(value)
            print("")
            self.remove_timezones(value)
        return self.unified_f1_data