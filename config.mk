GALILEO_SDK = /opt/galileo
SERIAL = /dev/ttyACM0
TOOLDIR = $(GALILEO_SDK)/hardware/tools/sysroots/x86_64-pokysdk-linux/usr/bin/i586-poky-linux-uclibc
CC = $(TOOLDIR)/i586-poky-linux-uclibc-gcc
CXX = $(TOOLDIR)/i586-poky-linux-uclibc-g++
AR = $(TOOLDIR)/i586-poky-linux-uclibc-ar
GALILEO_LIB = Wire
