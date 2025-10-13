import os
import sys
import requests
import pandas as pd
import time
import fastf1

from scripts import Extract, Transform, Load

years = [elem for elem in sys.argv[1:] if elem.isdigit()]

if __name__ == "__main__":
    extract = Extract(years)
    if 'E' in sys.argv[1:]:
        print("-------------------------------------------------------------------------------EXTRACTING DATA-------------------------------------------------------------------------------")
        formula_1_data = {}
        print("-----------------------------------------sessions-----------------------------------------")
        sessions = extract.extract_data("/sessions?")
        print(sessions.info())
        print("")
        print("")
        print("")
        print("-----------------------------------------meetings-----------------------------------------")
        meetings = extract.extract_data("/meetings?")
        print(meetings.info())
        print("")
        print("")
        print("")
        print("-----------------------------------------drivers-----------------------------------------")
        drivers = extract.extract_data("/drivers?session_key={}", sessions)
        print(drivers.info())
        print("")
        print("")
        print("")
        print("-----------------------------------------cars data-----------------------------------------")
        cars_data = extract.extract_data("/car_data?driver_number={}&session_key={}&speed>=315", drivers)
        print(cars_data.info())
        print("")
        print("")
        print("")
        print("-----------------------------------------laps-----------------------------------------")
        laps = extract.extract_data("/laps?session_key={}&driver_number={}", drivers)
        print(laps.info())
        # print(laps.head())
        formula_1_data[f"sessions"] = sessions
        formula_1_data[f"meetings"] = meetings
        formula_1_data[f"drivers"] = drivers
        formula_1_data[f"laps"] = laps
        formula_1_data[f"cars_data"] = cars_data
        print(formula_1_data)

        extract.save_raw_data(formula_1_data)

    print("-------------------------------------------------------------------------------TRANSFORMING DATA-------------------------------------------------------------------------------")
    # transform = Transform()
    transform = Transform()
    unified_data = transform.unify_data()
    transformed_data = transform.transform_data(unified_data)
    load = Load()
    print("")
    print("")
    formula_1_model = load.model_data(transformed_data)
    load.load_data(formula_1_model)