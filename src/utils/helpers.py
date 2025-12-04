import calendar
from datetime import datetime
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

class Helpers:
    min_date = None
    max_date = None
    def get_max_date_of_month(cls, __year__: int, __month__: int):
        _, days_count = calendar.monthrange(__year__, __month__)
        last_day_month = days_count
        current_date = datetime.now()
        current_year = current_date.year
        current_month = current_date.month
        current_day = current_date.day
        if __year__ == current_year and __month__ == current_month:
            if __month__ < 10:
                cls.min_date = f"{__year__}-0{__month__}-01T00:00:00+00:00"
                cls.max_date = f"{__year__}-0{__month__}-{current_day}T00:00:00+00:00"
            else:
                cls.min_date = f"{__year__}-{__month__}-01T00:00:00+00:00"
                cls.max_date = f"{__year__}-{__month__}-{current_day}T00:00:00+00:00"
        else:
            if __month__ < 10:
                cls.min_date = f"{__year__}-0{__month__}-01T00:00:00+00:00"
                cls.max_date = f"{__year__}-0{__month__}-{last_day_month}T00:00:00+00:00"
            else:
                cls.min_date = f"{__year__}-{__month__}-01T00:00:00+00:00"
                cls.max_date = f"{__year__}-{__month__}-{last_day_month}T00:00:00+00:00"
        logging.info({"-----YEAR-----": __year__, "-----MONTH-----": __month__, "-----MIN DATE-----": cls.min_date,"-----MAX DATE-----": cls.max_date})
        return cls.min_date, cls.max_date