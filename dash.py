# dash.py

import os
import random
import pygame
import cantools
import can
import time
import json
from config import *
from logging_util import log_row, log_lap
from lap_timer import LapTimer

def load_layout():
    with open(LAYOUT_FILE, "r") as f:
        return json.load(f)["pages"]

COLOR_MAP = {
    "lime": (0,255,0), "yellow": (255,255,0), "cyan": (0,255,255),
    "white": (255,255,255), "blue": (0,128,255), "orange": (255,128,0),
    "green": (0,200,64), "red": (255,0,0)
}

def get_demo_values(lap_time=None, best_lap=None):
    return {
        "rpm": random.randint(900, 7500),
        "speed": random.randint(0, 250),
        "oil_temp": random.randint(70, 130),
        "oil_pressure": round(random.uniform(1.0, 6.0), 1),
        "boost": round(random.uniform(-0.5, 2.0), 2),
        "lambda": round(random.uniform(0.7, 1.2), 2),
        "water_temp": random.randint(80, 110),
        "battery": round(random.uniform(13.0, 14.8), 2),
        "iat": random.randint(20, 60),
        "throttle": random.randint(0, 100),
        "lap_time": lap_time if lap_time else "--",
        "best_lap": best_lap if best_lap else "--",
        "error": ""
    }

def get_can_values(bus, dbc, lap_time=None, best_lap=None):
    msg = bus.recv(0.1)
    if not msg:
        return None
    try:
        decoded = dbc.decode_message(msg.arbitration_id, msg.data)
        return {
            "rpm": int(decoded.get("EngineSpeed", 0)),
            "speed": int(decoded.get("VehicleSpeed", 0)),
            "oil_temp": int(decoded.get("OilTemp", 0)),
            "oil_pressure": float(decoded.get("OilPressure", 0)),
            "boost": float(decoded.get("BoostPressure", 0)),
            "lambda": float(decoded.get("Lambda", 1.0)),
            "water_temp": int(decoded.get("CoolantTemp", 0)),
            "battery": float(decoded.get("BatteryVoltage", 0)),
            "iat": int(decoded.get("IAT", 0)),
            "throttle": int(decoded.get("ThrottlePos", 0)),
            "lap_time": lap_time if lap_time else "--",
            "best_lap": best_lap if best_lap else "--",
            "error": ""
        }
    except Exception as e:
        return None

def can_interface_exists():
    return os.path.exists('/sys/class/net/can0')

DEMO = FORCE_DEMO
dbc = None
bus = None

try:
    if not DEMO and can_interface_exists():
        bus = can.interface.Bus(channel='can0', bustype='socketcan')
        dbc = cantools.database.load_file('emu_black.dbc')
    else:
        DEMO = True
except Exception as e:
    DEMO = True

pygame.init()
screen = pygame.display.set_mode(DISPLAY_RES)
pygame.display.set_caption("EMU Black Dash")
clock = pygame.time.Clock()

def get_font(size):
    return pygame.font.SysFont('Arial', size)

lap_timer = LapTimer()
pages = load_layout()
current_page = 0
lap_time = None
best_lap = None

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            exit()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_q:
                pygame.quit()
                exit()
            if event.unicode == LAP_BUTTON_KEY:
                lap_time, best_lap = lap_timer.new_lap()
                if LOG_TO_CSV:
                    log_lap(LOG_FILENAME, lap_time, best_lap)
            if event.unicode == NEXT_PAGE_KEY:
                current_page = (current_page + 1) % len(pages)

    screen.fill((0,0,0))

    if DEMO:
        values = get_demo_values(lap_time, best_lap)
    else:
        values = get_can_values(bus, dbc, lap_time, best_lap)
        if values is None:
            values = get_demo_values(lap_time, best_lap)

    shiftlight = values["rpm"] >= SHIFTLIGHT_RPM
    warn = {
        "oil_temp": values["oil_temp"] >= WARN["oil_temp"],
        "oil_pressure": values["oil_pressure"] <= WARN["oil_pressure"],
        "water_temp": values["water_temp"] >= WARN["water_temp"],
        "lambda": not (WARN["lambda_min"] <= values["lambda"] <= WARN["lambda_max"]),
        "boost": values["boost"] >= WARN["boost"],
        "rpm": values["rpm"] >= WARN["rpm"]
    }

    page = pages[current_page]
    for field in page["fields"]:
        key = field["key"]
        value = values.get(key, "--")
        color = COLOR_MAP.get(field.get("color","white"), (255,255,255))
        if key in warn and warn[key]:
            color = COLOR_MAP["red"]
        font = get_font(field.get("size",36))
        label = field.get("label", key)
        txt = font.render(f"{label}: {value}", True, color)
        screen.blit(txt, field.get("pos", [10,10]))

    if shiftlight:
        pygame.draw.rect(screen, COLOR_MAP["yellow"], (DISPLAY_RES[0]-80,10,70,70))
        font = get_font(28)
        txt = font.render("SHIFT!", True, COLOR_MAP["red"])
        screen.blit(txt, (DISPLAY_RES[0]-78,50))

    for k, active in warn.items():
        if active:
            font = get_font(28)
            txt = font.render(f"WARNING: {k.upper()}", True, COLOR_MAP["red"])
            screen.blit(txt, (10, DISPLAY_RES[1]-40))

    if LOG_TO_CSV:
        log_row(LOG_FILENAME, values)

    pygame.display.flip()
    clock.tick(10)
