/* -*- c++ -*- */
/* 
 * Copyright 2013 NanoSatisfi Inc.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gr_io_signature.h>
#include "jblock_impl.h"


namespace gr {
  namespace jmodule {







    jblock::sptr jblock::make(float k)
    { 
      return gnuradio::get_initial_sptr (new jblock_impl(k));
    }
    static const int MIN_IN=1;
    static const int MAX_IN=1;
    static const int MIN_OUT=1;
    static const int MAX_OUT=1;


//*********************Private Constructor***********************//
    jblock_impl::jblock_impl(float k)
      : gr_sync_block("jblock",
		      gr_make_io_signature(MIN_IN, MAX_IN, sizeof (float)),
		      gr_make_io_signature(MIN_IN, MAX_IN, sizeof (float)))
    { 

d_k = k;

d_baudrate = SerialPort::BAUD_115200;
d_charsize = SerialStreamBuf::CHAR_SIZE_8;
d_stopbits = SerialPort::STOP_BITS_1;
d_parity = SerialPort::PARITY_NONE;
d_flowcontrol = SerialPort::FLOW_CONTROL_NONE;

LibSerial::SerialStream PttPort;
PttPort.Open("/dev/ttyACM0", std::ios_base::in);

PttPort.SetBaudRate(d_baudrate);
PttPort.SetCharSize(d_charsize);


}
//***************************************************************//







//**********************Virtual Destructor***********************//
    jblock_impl::~jblock_impl()
    {
    }
//***************************************************************//






//***********************Work Function***************************//
    int jblock_impl::work(int noutput_items,
			  gr_vector_const_void_star &input_items,
			  gr_vector_void_star &output_items)
    {
    using namespace LibSerial;
        const float *in = (const float *) input_items[0];
        float *out = (float *) output_items[0];



        for (int i=0;i<noutput_items;i++){
          out[i] = in[i] * d_k;
          }
        
        return noutput_items;
    }
//***************************************************************//







  } /* namespace jmodule */
} /* namespace gr */

