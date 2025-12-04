from datetime import datetime
import sys
import pandas as pd
import logging

from src.config.settings import Settings
from src.scripts import Extract, Load
from src.utils.helpers import Helpers

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)


class Main:
    def __init__(self):
        self.year = [
            elem for elem in sys.argv[1:] if elem.isdigit() and len(elem) == 4
        ][0]
        self.month = [
            elem for elem in sys.argv[1:] if elem.isdigit() and len(elem) <= 2
        ][0]
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
        self.load = Load()
        self.sessions = pd.DataFrame()
        self.meetings = pd.DataFrame()
        self.drivers = pd.DataFrame()
        self.cars_data = pd.DataFrame()
        self.laps = pd.DataFrame()

    def run(self):
        if "E" in sys.argv[1:]:
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


if __name__ == "__main__":
    main = Main()
    main.run()
