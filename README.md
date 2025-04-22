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
