# Teil 2: Hauptquelldateien erstellen
# -----------------------------------
# Speichern Sie dieses Skript als "create_project_part2.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle Hauptquelldateien in: $projectPath" -ForegroundColor Green

# Erstelle main.c
$mainPath = Join-Path -Path $projectPath -ChildPath "src\main.c"
$mainContent = @'
#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
#include "can_interface.h"
#include "data_manager.h"
#include "display.h"

int main(void) {
    printf("EMU Black Display v1.0 startet...\n");
    
    // WiringPi initialisieren
    if (wiringPiSetup() == -1) {
        printf("Fehler beim Initialisieren von WiringPi\n");
        return 1;
    }
    
    // Komponenten initialisieren
    if (data_manager_init() < 0) {
        printf("Fehler beim Initialisieren des Daten-Managers\n");
        return 1;
    }
    
    if (display_init() < 0) {
        printf("Fehler beim Initialisieren des Displays\n");
        return 1;
    }
    
    if (can_interface_init() < 0) {
        printf("Fehler beim Initialisieren der CAN-Schnittstelle\n");
        return 1;
    }
    
    printf("EMU Black Display erfolgreich gestartet\n");
    
    // Hauptschleife
    while (1) {
        // Display aktualisieren
        display_update();
        
        // Kurze Pause
        delay(10);  // 10ms
    }
    
    return 0;
}
'@
Set-Content -Path $mainPath -Value $mainContent
Write-Host "Datei erstellt: src\main.c" -ForegroundColor Cyan

# Erstelle can_interface.h
$canHeaderPath = Join-Path -Path $projectPath -ChildPath "include\can_interface.h"
$canHeaderContent = @'
#ifndef CAN_INTERFACE_H
#define CAN_INTERFACE_H

#include <linux/can.h>

int can_interface_init(void);
int can_receive_message(struct can_frame *frame);
int can_send_message(struct can_frame *frame);

#endif /* CAN_INTERFACE_H */
'@
Set-Content -Path $canHeaderPath -Value $canHeaderContent
Write-Host "Datei erstellt: include\can_interface.h" -ForegroundColor Cyan

# Erstelle data_manager.h
$dataHeaderPath = Join-Path -Path $projectPath -ChildPath "include\data_manager.h"
$dataHeaderContent = @'
#ifndef DATA_MANAGER_H
#define DATA_MANAGER_H

int data_manager_init(void);
int data_update(void);
float get_engine_rpm(void);
float get_engine_temp(void);
float get_throttle_position(void);

#endif /* DATA_MANAGER_H */
'@
Set-Content -Path $dataHeaderPath -Value $dataHeaderContent
Write-Host "Datei erstellt: include\data_manager.h" -ForegroundColor Cyan

# Erstelle display.h
$displayHeaderPath = Join-Path -Path $projectPath -ChildPath "lib\Display\include\display.h"
$displayHeaderContent = @'
#ifndef DISPLAY_H
#define DISPLAY_H

int display_init(void);
int display_update(void);
void display_clear(void);
void display_draw_text(int x, int y, const char* text, int size, int color);
void display_draw_gauge(int x, int y, int value, int max_value, int width, int height, int color);

#endif /* DISPLAY_H */
'@
Set-Content -Path $displayHeaderPath -Value $displayHeaderContent
Write-Host "Datei erstellt: lib\Display\include\display.h" -ForegroundColor Cyan

Write-Host "Hauptquelldateien erfolgreich erstellt!" -ForegroundColor Green
