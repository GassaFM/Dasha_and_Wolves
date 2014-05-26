#!/bin/bash
# Constants for compiling
export NAME=game
# Replace the following two lines by your local path to an installed copy of:
# https://github.com/SiegeLord/DAllegro5
export ALLEGRO5_PATH_WINDOWS="C:\\programs\\git\\DAllegro5"
export ALLEGRO5_PATH_LINUX="/c/programs/git/DAllegro5"
export LINKER_FLAGS="-L/STACK:268435456"
export OUTPUT_NAME="binary\\$NAME.exe"
export SOURCES=`ls source/{,units/}*.d`
#echo $SOURCES
export DEBUG_OPTIONS="-g -debug -unittest -L/SUBSYSTEM:CONSOLE:4.0"
export RELEASE_OPTIONS="-O -release -inline -noboundscheck -L/SUBSYSTEM:WINDOWS:4.0"
export COMMON_OPTIONS="-O -inline -wi -odobject"
