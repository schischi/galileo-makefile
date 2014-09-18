Galileo Makefile
================
This Makefile is intended to replace the ugly IDE.
The Makefile also compile the Galileo library, thus offering the same
features as the IDE.

Files
------
- `install.sh`: download and install the SDK. Default location is */opt/galileo*
- `config.mk`: path of the SDK and others variables
- `Makefile`: the Makefile :)
- `src/main.cc`: simple example

Usage
-----
Edit the `config.mk` file to list your source files, the lib you depend on and
the board version.

- `make`: (hopefully) build the project
- `make upload`: upload the sketch on the board
- `make clean`: remove the generated sketch
- `make distclean`: remove the generated libraries and sketch
