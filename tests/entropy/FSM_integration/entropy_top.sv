///////////////////////////////////////////
// entropy_top.sv
//
// Written: kelvin.tran@okstate.edu, james.stine@okstate.edu
// Created: 15 November 2024
//
// Purpose: RISCV top entropy cell for Zkr
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

module entropy_top #(parameter NUM_CELLS=11, parameter NUM_INV_START=11, parameter SIM_MODE=1) (
  input logic 	      clk,
  input logic 	      rst,
  input logic 	      enable_i,
												
  output logic [31:0] seed);

  logic valid_o, error_o;
  logic        initialization;
  logic [7:0]  data_o;
  logic [15:0] seed_temp;

  entropy #(.NUM_CELLS(NUM_CELLS), .NUM_INV_START(NUM_INV_START), .SIM_MODE(SIM_MODE)) dut 
    ( .clk(clk),
      .rst(rst),
      .enable_i(enable_i),
      .data_o(data_o),
      .valid_o(valid_o),
      .error_o(error_o));

  // assign seed_temp = valid_o ? {seed_temp[7:0], data_o} : seed_temp;

  typedef enum logic [1:0] {BIST, WAIT, ES16, DEAD} statetype;
  statetype state, nextstate;

  // state register
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      state <= BIST;
      initialization <= 2'b0;
    end else state <= nextstate;

    if ((initialization == 1'b0) && (valid_o == 1'b1)) initialization = 1'b1;
    else if ((initialization == 1'b1) && (valid_o == 1'b1)) initialization = 1'b0;
  end

  always @(posedge valid_o) begin
    seed_temp = {seed_temp[7:0], data_o};
  end

  // next state logic
  always_comb begin
    case (state)
      BIST: 
        begin
          seed <= 32'b0;
          if (valid_o == 1'b0) nextstate <= WAIT;
          else if ((valid_o == 1'b1) && initialization == 1'b0) nextstate <= ES16;
          // Add some on-demand tests?
        end
      WAIT: 
        begin
          seed <= 32'h4000_0000;
          if (valid_o == 1'b0) nextstate <= WAIT;
          else if ((valid_o == 1'b1) && initialization > 1'b0) nextstate <= ES16;
        end
      ES16: 
        begin
          seed <= {2'b10, 14'b0, seed_temp};
          if (error_o == 1'b1) nextstate <= BIST;
          else if (valid_o == 1'b1) nextstate <= ES16;
          else if (valid_o == 1'b0)  nextstate <= WAIT;
        end
    //   DEAD:          //NOT USED FOR NOW. Difficult to implement dead state currently due to hardware fault detection
    //     begin

    //     end
      default: 
        begin
          seed <= 32'b0;
          nextstate <= BIST;
        end
    endcase
  end
endmodule
