# logging_util.py
import csv
import os
from datetime import datetime

def log_row(filename, data_dict):
    file_exists = os.path.isfile(filename)
    with open(filename, "a", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=data_dict.keys())
        if not file_exists:
            writer.writeheader()
        writer.writerow(data_dict)

def log_lap(filename, lap_time, best_lap):
    with open(filename, "a") as f:
        f.write(f"LAP,{datetime.now().isoformat()},{lap_time:.2f},{best_lap:.2f}\n")
