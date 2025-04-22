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
