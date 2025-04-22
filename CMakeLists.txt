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
