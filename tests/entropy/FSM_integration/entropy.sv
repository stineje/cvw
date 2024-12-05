module entropy #(parameter NUM_CELLS=11, parameter NUM_INV_START=11, parameter SIM_MODE=1) (
  input  logic       clk,
  input  logic       rst,
  input  logic       enable_i,
  output logic [7:0] data_o,
  output logic       valid_o,
  output logic       error_o);

  // Entropy Cell Interconnect
  logic [NUM_CELLS-1:0] cell_en_in;
  logic [NUM_CELLS-1:0] cell_en_out;
  logic [NUM_CELLS-1:0] cell_rnd;
  logic                 cell_sum;

  // De-Biasing
  logic [1:0] debias_sreg;
  logic       debias_state;
  logic       debias_valid;
  logic       debias_data;

  // Sampling Control
  logic       sample_en;
  logic [7:0] sample_sreg;
  logic [6:0] sample_cnt;

  // Health Tests
  integer cutoff1, cutoff2, B1_in, B2_in, W_in;
  logic [7:0] A1_in, A2_in;
  logic repetition, adaptive;                   // Change logic to output later to send an error signal outwards

  genvar i;
  integer j;
  logic temp;

  // Generate Entropy Cells / Entropy Source
  generate 
    for(i=0; i<NUM_CELLS; i=i+1) begin: Generate_Instantiations
      entropy_cell #(.NUM_INV(NUM_INV_START + 2*i), .SIM_MODE(SIM_MODE)) inst (
        .clk(clk),
        .rst(rst),
        .en_i(cell_en_in[i]),
        .en_o(cell_en_out[i]),
        .rnd_o(cell_rnd[i])
      );
    end
  endgenerate

  // // Enable Shift-Register Chain
  assign cell_en_in[0] = sample_en;
  assign cell_en_in[NUM_CELLS-1:1] = cell_en_out[NUM_CELLS-2:0];

  // Combine Cell Outputs
  always @(cell_rnd) begin
    temp <= 0;
    for (j=0; j<NUM_CELLS; j=j+1) begin
      temp =  temp^cell_rnd[j];
    end
    cell_sum = temp;
  end

  // De-Biasing
  always @(rst, posedge clk) begin
    if (rst == 1'b1) begin
      debias_sreg <= 0;
      debias_state <= 0;
      cell_sum <= 0;

      cutoff1 <= 21; 
      cutoff2 <= 664;       // Detailed in Paper: "Recommendation for the Entropy Sources Used for Random Bit Generation"
      B1_in <= 1;
      B2_in <= 1;
      A1_in <= 0;
      A2_in <= 0;
      W_in <= 1;
      repetition <= 0;
      adaptive <= 0;
    end else begin
      debias_sreg <= {debias_sreg[0], cell_sum};
      debias_state <= ~debias_state & cell_en_out[NUM_CELLS-1];
    end
  end
  assign debias_valid = debias_state & (debias_sreg[1]^debias_sreg[0]);
  assign debias_data = debias_sreg[0];

  // Sampling Control
  always @(rst, posedge clk) begin
    if (rst == 1'b1) begin
      sample_en <= 0;
      sample_cnt <= 0;
      sample_sreg <= 0;
    end else begin
      sample_en <= enable_i;
      if ((sample_en == 1'b0) || (sample_cnt[6] == 1'b1)) begin
        sample_cnt <= 0;
        sample_sreg <= 0;
      end else if (debias_valid == 1'b1) begin
        sample_cnt <= sample_cnt + 1'b1;
        sample_sreg <= {sample_sreg[6:0], (sample_sreg[7]^debias_data)};
      end
    end
  end

  // TRNG Output Stream
  assign data_o = sample_sreg;
  assign valid_o = sample_cnt[6];

  // Health Tests --------------------------------------------------
  always@(posedge valid_o) begin
    if (cutoff1 == 0) begin
      A1_in = data_o;
      A2_in = data_o;
    end

    // Repetition Count Test
    if (A1_in == data_o) begin
      B1_in = B1_in + 1;
      if ((B1_in > cutoff1) && ~repetition) begin
        repetition = 1'b1;
        error_o = 1'b0;
      end 
    end else begin
      A1_in = data_o;
      B1_in = 1;
      repetition = 1'b0;
      error_o = 0;
    end

    // Adaptive Proportion Test
    if (W_in <= 1024) begin
      if (A2_in == data_o) B2_in = B2_in + 1;
      if ((B2_in > cutoff2) && ~adaptive) begin
        adaptive = 1'b1;
        error_o = 1'b0;
      end
      W_in = W_in + 1;
    end else begin
      A2_in = data_o;
      W_in = 0;
      B2_in = 0;
      adaptive = 1'b0;
      error_o = 0;
    end
  end
endmodule