# lap_timer.py
import time

class LapTimer:
    def __init__(self):
        self.laps = []
        self.last_lap_time = time.time()
        self.best_lap = None

    def new_lap(self):
        now = time.time()
        lap_time = now - self.last_lap_time
        self.laps.append(lap_time)
        self.last_lap_time = now
        if self.best_lap is None or lap_time < self.best_lap:
            self.best_lap = lap_time
        return lap_time, self.best_lap

    def get_last_lap(self):
        return self.laps[-1] if self.laps else None

    def get_best_lap(self):
        return self.best_lap
