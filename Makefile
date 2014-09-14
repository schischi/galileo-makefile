################
### SDK PATH ###
################
include config.mk

#####################
### USER'S SKETCH ###
#####################
TARGET = sketch.elf
SRC = src/main.cc
ARCH_FLAGS = -m32 -march=i586
CFLAGS = $(LIB_INCLUDE) \
		 -I$(GALILEO_SDK)/hardware/arduino/x86/cores/arduino \
		 -I$(GALILEO_SDK)/hardware/arduino/x86/variants/galileo_fab_d \
		 --sysroot=$(GALILEO_SDK)/hardware/tools/sysroots/i586-poky-linux-uclibc \
		 -Os -Wl,--gc-sections -march=i586
CXXFLAGS = -std=c++0x
LDFLAGS = -Llib/ -lm -lpthread -lclas2

all: core_lib dep
	$(CXX) $(ARCH_FLAGS) $(CFLAGS) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LIB_TARGET) $(LDFLAGS)

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
LIB_DIR = lib
LIB_TARGET = $(LIB_DIR)/core.a
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

$(LIB_TARGET): $(OBJ_C_CORE) $(OBJ_CXX_CORE) $(OBJ_VARIANT)
	@mkdir -p $(LIB_DIR)
	$(AR) rcs $(LIB_TARGET) $(OBJ_C_CORE) $(OBJ_CXX_CORE) $(OBJ_VARIANT)

core_lib: $(LIB_TARGET)

$(OBJ_C_CORE): $(OBJ_DIR)/%.o : $(CORES_SRC_PATH)/%.c
	@mkdir -p $(@D)
	$(CC) $(LIB_CFLAGS) -o $@ $<

$(OBJ_CXX_CORE): $(OBJ_DIR)/%.o : $(CORES_SRC_PATH)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(LIB_CXXFLAGS) -o $@ $<

$(OBJ_VARIANT): $(OBJ_DIR)/%.o : $(VARIANT_SRC_PATH)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(LIB_CXXFLAGS) -o $@ $<

distclean: clean
	$(RM) -rf $(OBJ_DIR)
	$(RM) -rf $(LIB_DIR)

#########################
### Galileo libraries ###
#########################
LIB_PATH = $(GALILEO_SDK)/hardware/arduino/x86/libraries
LIB_SRC = $(wildcard $(LIB_PATH)/*/*.cpp)
LIB_LIST = $(notdir $(wildcard $(LIB_PATH)/*))
LIB_OBJ = $(LIB_SRC:$(LIB_PATH)/%.cpp=$(OBJ_DIR)/%.o)
LIB_INCLUDE = $(addprefix -I$(LIB_PATH)/, $(LIB_LIST))

dep: $(addsuffix .a, $(addprefix $(LIB_DIR)/, $(GALILEO_LIB)))

$(LIB_OBJ): $(OBJ_DIR)/%.o : $(LIB_PATH)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(LIB_INCLUDE) $(LIB_CXXFLAGS) -o $@ $<

define func
LIB_$1_SRC = $(wildcard $(LIB_PATH)/$1/*.cpp)
LIB_$1_OBJ = $$(LIB_$1_SRC:$(LIB_PATH)/%.cpp=$(OBJ_DIR)/%.o)
$(LIB_DIR)/$(1).a: $$(LIB_$1_OBJ)
	@mkdir -p $(LIB_DIR)
	$(AR) rcs $(LIB_DIR)/$1.a $$(LIB_$1_OBJ)
endef
$(foreach it,$(LIB_LIST),$(eval $(call func,$(it))))

.PHONY: upload clean distclean lib dep
