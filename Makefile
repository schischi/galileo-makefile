################
### SDK PATH ###
################
include config.mk

#############################
### BOARD SPECIFIC CONFIG ###
#############################
ifneq (,$(findstring galileo_v,$(BOARD)))
    BOARD_PATH = x86
    SYSROOT = $(GALILEO_SDK)/hardware/tools/sysroots/i586-poky-linux-uclibc
    TOOLDIR = $(GALILEO_SDK)/hardware/tools/sysroots/x86_64-pokysdk-linux/usr/bin/i586-poky-linux-uclibc
    CC = $(TOOLDIR)/i586-poky-linux-uclibc-gcc
    CXX = $(TOOLDIR)/i586-poky-linux-uclibc-g++
    AR = $(TOOLDIR)/i586-poky-linux-uclibc-ar
    ifeq ($(BOARD),galileo_v1)
        VARIANT = galileo_fab_d
    else ifeq ($(BOARD),galileo_v2)
        VARIANT = galileo_fab_g
    else
        $(error Board $(BOARD) not supported (yet))
    endif
else ifeq ($(BOARD),edison)
    BOARD_PATH = edison
    VARIANT = edison_fab_c
    SYSROOT = $(GALILEO_SDK)/hardware/tools/edison/sysroots/core2-32-poky-linux
    TOOLDIR = $(GALILEO_SDK)/hardware/tools/edison/sysroots/x86_64-pokysdk-linux/usr/bin/i586-poky-linux
    CC = $(TOOLDIR)/i586-poky-linux-gcc
    CXX = $(TOOLDIR)/i586-poky-linux-g++
    AR = $(TOOLDIR)/i586-poky-linux-ar
else
    $(error Board $(BOARD) not supported (yet))
endif
RM = rm -rf

#####################
### USER'S SKETCH ###
#####################
ARCH_FLAGS = -m32 -march=i586
CFLAGS = $(LIB_INCLUDE) \
		 -I$(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/cores/arduino \
		 -I$(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/variants/$(VARIANT) \
		 --sysroot=$(SYSROOT) \
		 -Os -Wl,--gc-sections -march=i586
LDFLAGS += -Llib/ -lm -lpthread

$(TARGET): core_lib dep
	$(CXX) $(ARCH_FLAGS) $(CFLAGS) $(CXXFLAGS) -o $(TARGET) $(SRC) $(LIB_TARGET) $(LDFLAGS)

upload:
	@sh $(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/tools/izmir/clupload_linux.sh \
		$(GALILEO_SDK)/hardware/tools \
		$(TARGET) \
		$(SERIAL)

clean:
	$(RM) $(TARGET)

#############################
### Galileo core librarie ###
#############################
LIB_DIR = lib
LIB_TARGET = $(LIB_DIR)/core.a
LIB_CFLAGS = -m32 -march=i586 \
	     -I$(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/cores/arduino \
		 -I$(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/variants/$(VARIANT) \
		 --sysroot=$(SYSROOT) \
		 -fno-exceptions -ffunction-sections -fdata-sections -fpermissive \
		 -MMD -D__ARDUINO_$(BOARD_PATH)__ -Xassembler -march=i586 \
		-c -g -Os -w
LIB_CXXFLAGS = $(LIB_CFLAGS)

CORES_SRC_PATH = $(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/cores/arduino/
VARIANT_SRC_PATH = $(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/variants/$(VARIANT)/

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
	$(RM) $(OBJ_DIR)
	$(RM) $(LIB_DIR)

#########################
### Galileo libraries ###
#########################
LIB_PATH = $(GALILEO_SDK)/hardware/arduino/$(BOARD_PATH)/libraries
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
