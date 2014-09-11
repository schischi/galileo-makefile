################
### SDK PATH ###
################
include config.mk

#####################
### USER'S SKETCH ###
#####################
TARGET = sketch.elf
SRC = src/main.cc
CFLAGS = -m32 -march=i586 \
	     -I$(GALILEO_SDK)/hardware/arduino/x86/cores/arduino \
		 -I$(GALILEO_SDK)/hardware/arduino/x86/variants/galileo_fab_d \
		 --sysroot=$(GALILEO_SDK)/hardware/tools/sysroots/i586-poky-linux-uclibc \
		 -Os -Wl,--gc-sections -march=i586
CXXFLAGS = $(CFLAGS)
LDFLAGS = -Llib/ -lm -lpthread

all: lib
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LIB_TARGET) $(LDFLAGS)

upload:
	@sh $(GALILEO_SDK)/hardware/arduino/x86/tools/izmir/clupload_linux.sh \
		$(GALILEO_SDK)/hardware/tools \
		$(TARGET) \
		$(SERIAL)

clean:
	$(RM) -rf $(TARGET)

#############################
### Galileo core librarie ###
#############################
LIB_TARGET = core.a
LIB_CFLAGS = -m32 -march=i586 \
	     -I$(GALILEO_SDK)/hardware/arduino/x86/cores/arduino \
		 -I$(GALILEO_SDK)/hardware/arduino/x86/variants/galileo_fab_d \
		 --sysroot=$(GALILEO_SDK)/hardware/tools/sysroots/i586-poky-linux-uclibc \
		 -fno-exceptions -ffunction-sections -fdata-sections -fpermissive \
		 -MMD -D__ARDUINO_X86__ -Xassembler -march=i586 \
		-c -g -Os -w
LIB_CXXFLAGS = $(LIB_CFLAGS)

CORES_SRC_PATH = $(GALILEO_SDK)/hardware/arduino/x86/cores/arduino/
VARIANT_SRC_PATH = $(GALILEO_SDK)/hardware/arduino/x86/variants/galileo_fab_d/

CORES_C_SRC = $(wildcard $(CORES_SRC_PATH)/*.c)
CORES_CXX_SRC = $(wildcard $(CORES_SRC_PATH)/*.cpp)
VARIANT_SRC = $(wildcard $(VARIANT_SRC_PATH)/*.cpp)

OBJ_DIR = objs
OBJ_C_CORE = $(CORES_C_SRC:$(CORES_SRC_PATH)/%.c=$(OBJ_DIR)/%.o)
OBJ_CXX_CORE = $(CORES_CXX_SRC:$(CORES_SRC_PATH)/%.cpp=$(OBJ_DIR)/%.o)
OBJ_VARIANT = $(VARIANT_SRC:$(VARIANT_SRC_PATH)/%.cpp=$(OBJ_DIR)/%.o)

lib: $(OBJ_C_CORE) $(OBJ_CXX_CORE) $(OBJ_VARIANT)
	$(AR) rcs $(LIB_TARGET) $(OBJ_C_CORE) $(OBJ_CXX_CORE) $(OBJ_VARIANT)

$(OBJ_C_CORE): $(OBJ_DIR)/%.o : $(CORES_SRC_PATH)/%.c
	@mkdir -p objs
	$(CC) $(LIB_CFLAGS) -o $@ $<

$(OBJ_CXX_CORE): $(OBJ_DIR)/%.o : $(CORES_SRC_PATH)/%.cpp
	@mkdir -p objs
	$(CXX) $(LIB_CXXFLAGS) -o $@ $<

$(OBJ_VARIANT): $(OBJ_DIR)/%.o : $(VARIANT_SRC_PATH)/%.cpp
	@mkdir -p objs
	$(CXX) $(LIB_CXXFLAGS) -o $@ $<

distclean: clean
	$(RM) -rf $(OBJ_DIR)
	$(RM) -rf $(LIB_TARGET)
