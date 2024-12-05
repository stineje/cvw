///////////////////////////////////////////
// ring_osc_gen.sv
//
// Written: kelvin.tran@okstate.edu, james.stine@okstate.edu
// Created: 15 November 2024
//
// Purpose: RISCV ring oscillator generator
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

module ring_osc_gen #(parameter SIM_MODE = 1) (
  input logic clk, 
  input logic rst,
  input logic en_i,
  input logic latch_in,
  input logic sreg,
  input logic inv_in,
  output logic latch,
  output logic inv_out);

  always @(*) begin
    if (rst == 1'b1)  latch = 1'b0;
    if (en_i == 1'b0) latch = 1'b0;
    else if (sreg == 1'b0) latch = latch_in;
    else latch = inv_out;

    @(posedge clk) begin
      inv_out = ~inv_in;
      if (sreg == 1'b1) latch = inv_out;
      // Physical code removed since there is no way for testing currently
    end

  end
  
endmodule
