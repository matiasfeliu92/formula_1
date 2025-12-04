import logging
import time
import requests
import pandas as pd

from src.config.settings import Settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


class Extract:
    def __init__(self):
        self.settings = Settings()
        self.api_url = self.settings.BASE_URL
        self.base_dir = self.settings.BASE_DIR
        self.year = None
        self.error_logs = []

    def _request_with_retries(self, url, retries=3, delay=1, backoff=2):
        attempt = 1
        while attempt <= retries:
            try:
                logging.info(f"[Request Attempt {attempt}] -> {url}")
                response = requests.get(url, timeout=15)
                response.raise_for_status()
                return response.json()
            except (requests.exceptions.RequestException, ValueError) as e:
                logging.error(f"[Error Attempt {attempt}] {e}")
                if attempt == retries:
                    logging.error("Max retries reached. Aborting.")
                    raise
                sleep_time = delay * (backoff ** (attempt - 1))
                logging.warning(f"Retrying in {sleep_time}s...")
                time.sleep(sleep_time)
                attempt += 1

    def extract_data(
        self,
        _endpoint_: str = None,
        df: pd.DataFrame = None,
        meeting_key=None,
        session_key=None,
    ):
        if "sessions" in _endpoint_ or "meetings" in _endpoint_:
            df_data = pd.DataFrame()
            try:
                logging.info(
                    f"-------------complete url: {self.api_url+_endpoint_}-------------"
                )
                sessions_data = self._request_with_retries(self.api_url + _endpoint_)
                df = pd.json_normalize(sessions_data)
                df_data = pd.concat([df_data, df], ignore_index=True)
                self.year = df_data["year"][0]
            except requests.exceptions.RequestException as e:
                logging.info("")
                logging.error(f"Error during request: {e}")
                self.error_logs.append(
                    {
                        "endpoint": (
                            "meetings" if "meetings" in _endpoint_ else "sessions"
                        ),
                        "year": self.year,
                        "url": self.api_url + _endpoint_,
                        "error": str(e),
                    }
                )
                logging.info("")
                return pd.DataFrame()
            except requests.exceptions.HTTPError as e:
                logging.info("")
                logging.error(f"HTTP error occurred: {e}")
                self.error_logs.append(
                    {
                        "endpoint": (
                            "meetings" if "meetings" in _endpoint_ else "sessions"
                        ),
                        "year": self.year,
                        "url": self.api_url + _endpoint_,
                        "error": str(e),
                    }
                )
                logging.info("")
                return pd.DataFrame()
            except Exception as e:
                logging.info("")
                logging.error(f"An unexpected error occurred: {e}")
                self.error_logs.append(
                    {
                        "endpoint": (
                            "meetings" if "meetings" in _endpoint_ else "sessions"
                        ),
                        "year": self.year,
                        "url": self.api_url + _endpoint_,
                        "error": str(e),
                    }
                )
                logging.info("")
                return pd.DataFrame()
            return df_data
        elif "laps" in _endpoint_:
            df_data = pd.DataFrame()
            df_params = (
                df.groupby(["session_key", "driver_number"])
                .agg({"country_code": "max"})
                .reset_index()
            )
            for _, row in df_params.iterrows():
                session_key = row["session_key"]
                driver_number = row["driver_number"]
                logging.info(
                    f"-------------complete url: {self.api_url+_endpoint_.format(session_key, driver_number)}-------------"
                )
                try:
                    laps_data = self._request_with_retries(
                        self.api_url + _endpoint_.format(session_key, driver_number)
                    )
                    df = pd.json_normalize(laps_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                except requests.exceptions.RequestException as e:
                    logging.info("")
                    logging.error(f"Error during request: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "laps",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(session_key, driver_number),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except requests.exceptions.HTTPError as e:
                    logging.info("")
                    logging.error(f"HTTP error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "laps",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(session_key, driver_number),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except Exception as e:
                    logging.info("")
                    logging.error(f"An unexpected error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "laps",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(session_key, driver_number),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
            return df_data
        elif "drivers" in _endpoint_:
            df_data = pd.DataFrame()
            df_params = (
                df.groupby(["session_key"]).agg({"country_code": "max"}).reset_index()
            )
            for _, row in df_params.iterrows():
                session_key = row["session_key"]
                logging.info(
                    f"-------------complete url: {self.api_url+_endpoint_.format(session_key)}-------------"
                )
                try:
                    drivers_data = self._request_with_retries(
                        self.api_url + _endpoint_.format(session_key)
                    )
                    df = pd.json_normalize(drivers_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                except requests.exceptions.RequestException as e:
                    logging.info("")
                    logging.error(f"Error during request: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "drivers",
                            "year": self.year,
                            "url": self.api_url + _endpoint_.format(session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except requests.exceptions.HTTPError as e:
                    logging.info("")
                    logging.error(f"HTTP error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "drivers",
                            "year": self.year,
                            "url": self.api_url + _endpoint_.format(session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except Exception as e:
                    logging.info("")
                    logging.error(f"An unexpected error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "drivers",
                            "year": self.year,
                            "url": self.api_url + _endpoint_.format(session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
            return df_data
        elif "car_data" in _endpoint_:
            df_data = pd.DataFrame()
            for _, row in df.iterrows():
                driver_number = row["driver_number"]
                session_key = row["session_key"]
                logging.info(
                    f"-------------complete url: {self.api_url+_endpoint_.format(driver_number, session_key)}-------------"
                )
                try:
                    cars_data = self._request_with_retries(
                        self.api_url + _endpoint_.format(driver_number, session_key)
                    )
                    df = pd.json_normalize(cars_data)
                    df_data = pd.concat([df_data, df], ignore_index=True)
                except requests.exceptions.RequestException as e:
                    logging.info("")
                    logging.error(f"Error during request: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "cars_data",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(driver_number, session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except requests.exceptions.HTTPError as e:
                    logging.info("")
                    logging.error(f"HTTP error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "cars_data",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(driver_number, session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
                except Exception as e:
                    logging.info("")
                    logging.error(f"An unexpected error occurred: {e}")
                    self.error_logs.append(
                        {
                            "endpoint": "cars_data",
                            "year": self.year,
                            "url": self.api_url
                            + _endpoint_.format(driver_number, session_key),
                            "error": str(e),
                        }
                    )
                    logging.info("")
                    continue
            return df_data

    def create_error_log_table(self):
        df_error_logs = pd.DataFrame(self.error_logs)
        logging.info(f"-----ERROR LOG has {df_error_logs.shape[0]} filas-----")
        return df_error_logs
