#!/bin/sh
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/joel/joel/prac/gr-jmodule/lib
export PATH=/home/joel/joel/prac/gr-jmodule/build/lib:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-jmodule 
