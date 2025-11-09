import os
import time
import requests
import pandas as pd
class Extract:
    def __init__(self, years: list = None):
        self.API_URL = "https://api.openf1.org/v1"
        self.BASE_DIR = os.getcwd()
        self.YEARS = years
        print({"YEARS": self.YEARS})

    def extract_data(self, _endpoint_: str = None, df: pd.DataFrame = None, meeting_key = None, session_key=None):
        if 'sessions' in _endpoint_ or 'meetings' in _endpoint_:
            df_data = pd.DataFrame()
            try:
                print({"complete url": self.API_URL+_endpoint_})
                r = requests.get(self.API_URL+_endpoint_)
                sessions_data = r.json()
                df = pd.json_normalize(sessions_data)
                df_data = pd.concat([df_data, df], ignore_index=True)
                time.sleep(5)
            except requests.exceptions.RequestException as e:
                print(f"Error during request: {e}")
                return None
            except requests.exceptions.HTTPError as e:
                print(f"HTTP error occurred: {e}")
                return None
            except Exception as e:
                print(f"An unexpected error occurred: {e}")
                return None
            return df_data
        elif 'laps' in _endpoint_:
            df_data = pd.DataFrame()
            df_params = df.groupby(["session_key", "driver_number"]).agg({'country_code': 'max'}).reset_index()
            for index, row in df_params.iterrows():
                session_key = row["session_key"]
                driver_number = row["driver_number"]
                print({"complete url": self.API_URL+_endpoint_.format(session_key, driver_number)})
                try:
                    r = requests.get(self.API_URL+_endpoint_.format(session_key, driver_number))
                    laps_data = r.json()
                    df = pd.json_normalize(laps_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                except requests.exceptions.RequestException as e:
                    print(f"Error during request: {e}")
                    return None
                except requests.exceptions.HTTPError as e:
                    print(f"HTTP error occurred: {e}")
                    return None
                except Exception as e:
                    print(f"An unexpected error occurred: {e}")
                    return None
            return df_data
        elif 'drivers' in _endpoint_:
            df_data = pd.DataFrame()
            df_params = df.groupby(["session_key"]).agg({'country_code': 'max'}).reset_index()
            for index, row in df_params.iterrows():
                session_key = row["session_key"]
                print({"complete url": self.API_URL+_endpoint_.format(session_key)})
                try:
                    r = requests.get(self.API_URL+_endpoint_.format(session_key))
                    drivers_data = r.json()
                    df = pd.json_normalize(drivers_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                    time.sleep(5)
                except requests.exceptions.RequestException as e:
                    print(f"Error during request: {e}")
                    return None
                except requests.exceptions.HTTPError as e:
                    print(f"HTTP error occurred: {e}")
                    return None
                except Exception as e:
                    print(f"An unexpected error occurred: {e}")
                    return None
            return df_data
        elif 'car_data' in _endpoint_:
            df_data = pd.DataFrame()
            for index, row in df.iterrows():
                driver_number = row["driver_number"]
                session_key = row["session_key"]
                print({"complete url": self.API_URL+_endpoint_.format(driver_number, session_key)})
                try:
                    r = requests.get(self.API_URL+_endpoint_.format(driver_number, session_key))
                    cars_data = r.json()
                    df = pd.json_normalize(cars_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                except requests.exceptions.RequestException as e:
                    print(f"Error during request: {e}")
                    return None
                except requests.exceptions.HTTPError as e:
                    print(f"HTTP error occurred: {e}")
                    return None
                except Exception as e:
                    print(f"An unexpected error occurred: {e}")
                    return None
            return df_data
            
    def save_raw_data(self, dict_: dict):
        print("BASE DIR --> ", self.BASE_DIR)
        output_dir = os.path.join(self.BASE_DIR, "data", "raw")
        os.makedirs(output_dir, exist_ok=True)
        for key, value in dict_.items():
            if value is not None:
                file_name = key+'.csv'
                value.to_csv(os.path.join(output_dir, file_name), encoding="utf-8-sig", index=False, sep=";")
                print(f"File {file_name} was saved")