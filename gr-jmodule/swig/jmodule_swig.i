/* -*- c++ -*- */

#define JMODULE_API

%include "gnuradio.i"			// the common stuff

%{
#include "jmodule/jblock.h"
%}


%include "jmodule/jblock.h"
GR_SWIG_BLOCK_MAGIC2(jmodule, jblock);
