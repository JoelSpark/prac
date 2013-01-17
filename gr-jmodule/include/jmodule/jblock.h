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


#ifndef INCLUDED_JMODULE_JBLOCK_H
#define INCLUDED_JMODULE_JBLOCK_H

#include <jmodule/api.h>
#include <gr_sync_block.h>
#include <types/time_spec.hpp>
#include <gr_complex.h>
#include <SerialStream.h>
#include <SerialPort.h>

namespace gr {
  namespace jmodule {

    class JMODULE_API jblock : virtual public gr_sync_block
    {
    protected:
    float d_k;
    public:
       typedef boost::shared_ptr<jblock> sptr;

       static sptr make(float k);

       float k() const {return d_k;}
       void set_k(float k) {d_k=k;}
    };

  } // namespace jmodule
} // namespace gr

#endif /* INCLUDED_JMODULE_JBLOCK_H */

