Galileo Makefile
================
This Makefile is intended to replace the ugly IDE.
The Makefile also compile the Galileo library, thus offering the same
features of the IDE.

Files
------
- `install.sh`: download and install the SDK. Default location is */opt/galileo*
- `config.mk`: path of the SDK and others variables
- `Makefile`: the Makefile :)
- `src/main.cc`: simple example

Usage
-----
Just list your sources files in the ``SRC`` variables of the Makefile.

- `make`: (hopefully) build the project
- `make upload`: upload the sketch on the board
- `make clean`: remove the generated sketch
- `make distclean`: remove the generated libraries and sketch
