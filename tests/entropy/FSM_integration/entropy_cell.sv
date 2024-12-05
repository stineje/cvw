///////////////////////////////////////////
// entropy_cell.sv
//
// Written: kelvin.tran@okstate.edu, james.stine@okstate.edu
// Created: 15 November 2024
//
// Purpose: RISCV entropy cell for Zkr
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

module entropy_cell #(parameter NUM_INV = 3, parameter SIM_MODE = 0) (
  input logic  clk,
  input logic  rst,
  input logic  en_i,
								      
  output logic en_o,
  output logic rnd_o);

  logic [NUM_INV-1:0] latch;
  logic [NUM_INV-1:0] latch_temp;
  logic [NUM_INV-1:0] inv_in, inv_out;
  logic [NUM_INV-1:0] inv_in_temp;
  logic [NUM_INV-1:0] sreg;
  logic [1:0]         sync;
  genvar i;

  always @(rst, posedge clk) begin // Enable Shift-Register
    if (rst == 1'b1) begin
      sreg <= 0;
    end else begin
      sreg = {sreg[NUM_INV-2:0], en_i};
    end

  end
  assign en_o = sreg[NUM_INV-1];

  generate
    for(i=0; i<NUM_INV; i=i+1) begin
      ring_osc_gen #(.SIM_MODE(SIM_MODE)) rosc (
        .clk(clk),
        .rst(rst),
        .en_i(en_i),
        .latch_in(latch_temp[i]),
        .sreg(sreg[i]),
        .inv_in(inv_in_temp[i]),
        .latch(latch[i]),
        .inv_out(inv_out[i]));
      
    end
  endgenerate
  assign inv_in[0] = latch[NUM_INV-1];
  assign inv_in[NUM_INV-1:1] = latch[NUM_INV-2:0];

  always @(*) begin
    latch_temp = latch;
    inv_in_temp = inv_in;
  end

  // Output Synchronizer and Shift-Register Enable
  always @(rst, posedge clk) begin
    if (rst) begin
      sync <= 0;
    end
    else begin
      sync <= {sync[0], latch[NUM_INV-1]};
    end
  end

  assign rnd_o = sync[1];

endmodule
