# Teil 4: Build-Konfigurationsdateien erstellen
# --------------------------------------------
# Speichern Sie dieses Skript als "create_project_part4.ps1"

# Definieren Sie den Projektpfad (aktuelles Verzeichnis, wenn nicht anders angegeben)
$projectPath = Get-Location

Write-Host "Erstelle Build-Konfigurationsdateien in: $projectPath" -ForegroundColor Green

# Erstelle Makefile
$makefilePath = Join-Path -Path $projectPath -ChildPath "Makefile"
$makefileContent = @'
# Compiler und Flags
CC = gcc
CFLAGS = -Wall -Wextra -g

# Verzeichnisse
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib
BUILD_DIR = build

# Quellcode-Dateien finden
SRCS = $(wildcard $(SRC_DIR)/*.c) \
       $(wildcard $(SRC_DIR)/can/*.c) \
       $(wildcard $(SRC_DIR)/data/*.c) \
       $(wildcard $(LIB_DIR)/Display/src/*.c)

# Objektdateien generieren
OBJS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(SRCS)))

# Include-Pfade
INCLUDES = -I$(INC_DIR) -I$(LIB_DIR)/Display/include

# Bibliotheken
LIBS = -lwiringPi -lpthread

# Ziel-Executable
TARGET = emu_display

# Hauptregel
all: $(BUILD_DIR) $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/can/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/data/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(LIB_DIR)/Display/src/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

.PHONY: all clean
'@
Set-Content -Path $makefilePath -Value $makefileContent
Write-Host "Datei erstellt: Makefile" -ForegroundColor Cyan

# Erstelle CMakeLists.txt
$cmakePath = Join-Path -Path $projectPath -ChildPath "CMakeLists.txt"
$cmakeContent = @'
cmake_minimum_required(VERSION 3.10)
project(emu_black_display C)

# Fügen Sie Include-Verzeichnisse hinzu
include_directories(include)
include_directories(lib/Display/include)

# Fügen Sie Quellcode-Dateien hinzu
file(GLOB SOURCES "src/*.c" "src/can/*.c" "src/data/*.c" "lib/Display/src/*.c")

# Erstellen Sie das ausführbare Programm
add_executable(emu_display ${SOURCES})

# Verknüpfen Sie mit erforderlichen Bibliotheken
target_link_libraries(emu_display wiringPi pthread)
'@
Set-Content -Path $cmakePath -Value $cmakeContent
Write-Host "Datei erstellt: CMakeLists.txt" -ForegroundColor Cyan

# Erstelle build.sh
$buildScriptPath = Join-Path -Path $projectPath -ChildPath "build.sh"
$buildScriptContent = @'
#!/bin/bash
# Build-Skript für Raspberry Pi Zero 2 W

# Verzeichnisse
SRC_DIR=src
INC_DIR=include
LIB_DIR=lib
BUILD_DIR=build

# Erstelle Build-Verzeichnis
mkdir -p $BUILD_DIR

# Kompiliere alle Quelldateien
echo "Kompiliere Quelldateien..."
gcc -Wall -Wextra -g -I$INC_DIR -I$LIB_DIR/Display/include \
    $SRC_DIR/*.c $SRC_DIR/can/*.c $SRC_DIR/data/*.c $LIB_DIR/Display/src/*.c \
    -o $BUILD_DIR/emu_display -lwiringPi -lpthread

if [ $? -eq 0 ]; then
    echo "Build erfolgreich!"
else
    echo "Build fehlgeschlagen!"
    exit 1
fi
'@
Set-Content -Path $buildScriptPath -Value $buildScriptContent
Write-Host "Datei erstellt: build.sh" -ForegroundColor Cyan

Write-Host "Build-Konfigurationsdateien erfolgreich erstellt!" -ForegroundColor Green
