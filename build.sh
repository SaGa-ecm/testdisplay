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
