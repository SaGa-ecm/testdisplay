# Teil 3: Implementierungsdateien erstellen
# ----------------------------------------
# Speichern Sie dieses Skript als "create_project_part3.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle Implementierungsdateien in: $projectPath" -ForegroundColor Green

# Erstelle can_interface.c
$canImplPath = Join-Path -Path $projectPath -ChildPath "src\can\can_interface.c"
$canImplContent = @'
#include "can_interface.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>

int can_socket = -1;

int can_interface_init(void) {
    struct sockaddr_can addr;
    struct ifreq ifr;
    
    // Socket erstellen
    can_socket = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (can_socket < 0) {
        perror("Fehler beim Erstellen des CAN-Sockets");
        return -1;
    }
    
    // Interface-Name setzen (z.B. "can0")
    strcpy(ifr.ifr_name, "can0");
    ioctl(can_socket, SIOCGIFINDEX, &ifr);
    
    // Socket binden
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (bind(can_socket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("Fehler beim Binden des CAN-Sockets");
        close(can_socket);
        return -1;
    }
    
    printf("CAN-Schnittstelle initialisiert\n");
    return 0;
}

int can_receive_message(struct can_frame *frame) {
    int nbytes = read(can_socket, frame, sizeof(struct can_frame));
    if (nbytes < 0) {
        perror("Fehler beim Lesen vom CAN-Bus");
        return -1;
    }
    return nbytes;
}

int can_send_message(struct can_frame *frame) {
    int nbytes = write(can_socket, frame, sizeof(struct can_frame));
    if (nbytes < 0) {
        perror("Fehler beim Senden auf den CAN-Bus");
        return -1;
    }
    return nbytes;
}
'@
Set-Content -Path $canImplPath -Value $canImplContent
Write-Host "Datei erstellt: src\can\can_interface.c" -ForegroundColor Cyan

# Erstelle data_manager.c
$dataImplPath = Join-Path -Path $projectPath -ChildPath "src\data\data_manager.c"
$dataImplContent = @'
#include "data_manager.h"
#include "can_interface.h"
#include <stdio.h>
#include <stdlib.h>
#include <linux/can.h>

// Globale Variablen für Motordaten
static float engine_rpm = 0.0;
static float engine_temp = 0.0;
static float throttle_position = 0.0;

// EMU Black CAN-IDs
#define EMU_BLACK_BASE_ID 0x600
#define EMU_RPM_ID (EMU_BLACK_BASE_ID + 1)
#define EMU_TEMP_ID (EMU_BLACK_BASE_ID + 2)
#define EMU_THROTTLE_ID (EMU_BLACK_BASE_ID + 3)

int data_manager_init(void) {
    printf("Daten-Manager initialisiert\n");
    return 0;
}

int data_update(void) {
    struct can_frame frame;
    
    // CAN-Nachricht empfangen
    if (can_receive_message(&frame) < 0) {
        return -1;
    }
    
    // Nachricht basierend auf der CAN-ID verarbeiten
    switch (frame.can_id) {
        case EMU_RPM_ID:
            // RPM aus den ersten beiden Bytes extrahieren
            engine_rpm = (float)((frame.data[0] << 8) | frame.data[1]);
            break;
            
        case EMU_TEMP_ID:
            // Motortemperatur aus dem ersten Byte extrahieren
            engine_temp = (float)frame.data[0];
            break;
            
        case EMU_THROTTLE_ID:
            // Drosselklappenposition aus dem ersten Byte extrahieren (0-100%)
            throttle_position = (float)frame.data[0];
            break;
            
        default:
            // Unbekannte CAN-ID ignorieren
            break;
    }
    
    return 0;
}

float get_engine_rpm(void) {
    return engine_rpm;
}

float get_engine_temp(void) {
    return engine_temp;
}

float get_throttle_position(void) {
    return throttle_position;
}
'@
Set-Content -Path $dataImplPath -Value $dataImplContent
Write-Host "Datei erstellt: src\data\data_manager.c" -ForegroundColor Cyan

# Erstelle display.c
$displayImplPath = Join-Path -Path $projectPath -ChildPath "lib\Display\src\display.c"
$displayImplContent = @'
#include "display.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>

// Display-Konfiguration
#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 240
#define SPI_CHANNEL 0
#define SPI_SPEED 32000000  // 32 MHz

// Farben
#define COLOR_BLACK 0x0000
#define COLOR_WHITE 0xFFFF
#define COLOR_RED 0xF800
#define COLOR_GREEN 0x07E0
#define COLOR_BLUE 0x001F

// Globale Variablen
static int display_initialized = 0;

int display_init(void) {
    // SPI initialisieren
    if (wiringPiSPISetup(SPI_CHANNEL, SPI_SPEED) < 0) {
        printf("Fehler beim Initialisieren des SPI-Bus\n");
        return -1;
    }
    
    // Display-spezifische Initialisierung hier...
    // (Abhängig vom tatsächlich verwendeten Display)
    
    display_initialized = 1;
    printf("Display initialisiert\n");
    
    // Display löschen
    display_clear();
    
    return 0;
}

int display_update(void) {
    if (!display_initialized) {
        return -1;
    }
    
    // Hier würden Sie die Anzeige mit den aktuellen Daten aktualisieren
    // Beispiel:
    // display_draw_text(10, 10, "EMU Black Display", 2, COLOR_WHITE);
    // display_draw_gauge(10, 50, get_engine_rpm(), 8000, 300, 30, COLOR_RED);
    
    return 0;
}

void display_clear(void) {
    if (!display_initialized) {
        return;
    }
    
    // Display mit schwarzer Farbe füllen
    // Implementierung abhängig vom tatsächlich verwendeten Display
    printf("Display gelöscht\n");
}

void display_draw_text(int x, int y, const char* text, int size, int color) {
    if (!display_initialized || !text) {
        return;
    }
    
    // Text auf dem Display zeichnen
    // Implementierung abhängig vom tatsächlich verwendeten Display
    printf("Text gezeichnet: %s (an Position %d,%d)\n", text, x, y);
}

void display_draw_gauge(int x, int y, int value, int max_value, int width, int height, int color) {
    if (!display_initialized) {
        return;
    }
    
    // Balkenanzeige auf dem Display zeichnen
    // Implementierung abhängig vom tatsächlich verwendeten Display
    printf("Balkenanzeige gezeichnet: Wert %d von %d (an Position %d,%d)\n", value, max_value, x, y);
}
'@
Set-Content -Path $displayImplPath -Value $displayImplContent
Write-Host "Datei erstellt: lib\Display\src\display.c" -ForegroundColor Cyan

Write-Host "Implementierungsdateien erfolgreich erstellt!" -ForegroundColor Green
