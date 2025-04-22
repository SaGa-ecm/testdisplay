#!/bin/bash

set -e

echo "==== EMU Black Dash Installation ===="

# 1. Systemupdate
echo "[1/9] Systemupdate..."
sudo apt update && sudo apt upgrade -y

# 2. Benötigte Pakete installieren
echo "[2/9] Benötigte Pakete installieren..."
sudo apt install -y python3 python3-pip python3-pygame python3-can git python3-numpy

# 3. Python-Bibliotheken installieren
echo "[3/9] Python-Bibliotheken installieren..."
pip3 install --user cantools flask

# 4. Repository klonen (URL anpassen!)
echo "[4/9] Repository klonen..."
cd ~
if [ ! -d emu_black_dash ]; then
    git clone https://github.com/DEIN-USERNAME/emu_black_dash.git
fi
cd emu_black_dash

# 5. DBC-Datei prüfen
echo "[5/9] Prüfe auf emu_black.dbc..."
if [ ! -f emu_black.dbc ]; then
    echo "!!! ACHTUNG: Bitte lege deine emu_black.dbc ins Projektverzeichnis ~/emu_black_dash"
    echo "Installation kann fortgesetzt werden, aber ohne DBC keine echten Fahrzeugdaten!"
fi

# 6. Konfigurationsdateien und Layout anlegen, falls nicht vorhanden
if [ ! -f config.py ]; then
cat > config.py <<EOC
# config.py

DISPLAY_RES = (480, 320)
WARN = {
    "oil_temp": 120,
    "oil_pressure": 1.5,
    "water_temp": 105,
    "lambda_min": 0.80,
    "lambda_max": 1.20,
    "boost": 1.8,
    "rpm": 7000
}
SHIFTLIGHT_RPM = 6500
LOG_TO_CSV = True
LOG_FILENAME = "dash_log.csv"
LAP_BUTTON_KEY = "l"
NEXT_PAGE_KEY = "n"
FORCE_DEMO = False
LAYOUT_FILE = "layout_config.json"
EOC
fi

if [ ! -f layout_config.json ]; then
cat > layout_config.json <<EOC
{
    "pages": [
        {
            "name": "Track",
            "fields": [
                {"label": "RPM", "key": "rpm", "pos": [10,10], "size": 48, "color": "lime"},
                {"label": "OilP", "key": "oil_pressure", "pos": [10,90], "size": 36, "color": "yellow"},
                {"label": "Boost", "key": "boost", "pos": [220,90], "size": 36, "color": "cyan"},
                {"label": "Lap", "key": "lap_time", "pos": [10,160], "size": 36, "color": "white"}
            ]
        },
        {
            "name": "Street",
            "fields": [
                {"label": "Speed", "key": "speed", "pos": [10,10], "size": 48, "color": "white"},
                {"label": "Water", "key": "water_temp", "pos": [10,90], "size": 36, "color": "blue"},
                {"label": "Battery", "key": "battery", "pos": [220,90], "size": 36, "color": "orange"},
                {"label": "Lambda", "key": "lambda", "pos": [10,160], "size": 36, "color": "green"}
            ]
        }
    ]
}
EOC
fi

# 7. systemd-Service für Autostart einrichten
echo "[6/9] systemd-Service anlegen..."
cat > emu-black-dash.service <<EOC
[Unit]
Description=EMU Black Dash

[Service]
ExecStart=/usr/bin/python3 /home/pi/emu_black_dash/dash.py
WorkingDirectory=/home/pi/emu_black_dash/
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOC

sudo cp emu-black-dash.service /etc/systemd/system/emu-black-dash.service
sudo systemctl daemon-reload
sudo systemctl enable emu-black-dash.service

# 8. Rechte für Logging
touch dash_log.csv
chmod 666 dash_log.csv

# 9. README ergänzen/aktualisieren
cat > README.md <<EOC
# EMU Black Dash (Release)

**Features:**
- Mehrere Layouts/Seiten (umschaltbar mit Taste 'n')
- Konfigurierbare Warnungen und Popups
- Schaltblitz, Lap-Timer, Logging (CSV), Fehlercode-Anzeige
- Demomodus (automatisch oder in config.py erzwingen)
- Konfiguration über config.py und layout_config.json

**Bedienung:**
- 'n' = nächste Seite
- 'l' = neue Runde (Lap-Timer)
- 'q' = Beenden

**Installation:**
1. DBC-Datei ins Projektverzeichnis legen (emu_black.dbc)
2. System und Python-Abhängigkeiten installieren (siehe install_emu_black_dash.sh)
3. Dashboard starten:  
   cd ~/emu_black_dash && python3 dash.py  
   (oder nach Reboot automatisch als Service)

**Konfiguration:**
- Warnschwellen, Logging, Layout etc. in config.py und layout_config.json anpassen.

**Demomodus:**
- Wird automatisch gestartet, wenn kein CAN-Interface erkannt wird.
- Oder in config.py mit FORCE_DEMO = True erzwingen.

**Web-Konfiguration:**
- (Platz für spätere Erweiterung: Flask-Webserver für Konfiguration)
EOC

echo "==== Installation abgeschlossen! ===="
echo "Starte das Dashboard mit:"
echo "cd ~/emu_black_dash && python3 dash.py"
echo "Oder nach Reboot automatisch als Service!"
