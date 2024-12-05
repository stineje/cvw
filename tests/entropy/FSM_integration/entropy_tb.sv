module tb ();

  logic        rst, clk;
  logic        enable_i;
  logic [31:0] seed;
  logic [31:0] temp;
  integer      i, f, count;

  // instantiate device under test
  // Change the number of cells and starter inverters to suit your needs
  // Ensure that Num_Cells and Num_Inv_Start are at least 7 each to meet NIST SP800-90b validations
  entropy_top #(.NUM_CELLS(11), .NUM_INV_START(11), .SIM_MODE(1)) dut 
    (
      .clk(clk),
      .rst(rst),
      .enable_i(enable_i),
      .seed(seed)
    );

  // 5 ns clock
  initial 
  begin	
    clk = 1'b1;
    forever #10 clk = ~clk;
  end

  initial
  begin
    rst = 1'b1;
    #25 rst = ~rst;
  end

  initial
  begin
    enable_i = 1'b0;
    #100 enable_i = ~enable_i;
  end

    initial 
  begin	
    f = $fopen("entropyfsm.txt","wb");
    
    count = 0;
    for (i=0; i<100000; i=i+1) begin
      @(posedge clk) begin
        $fwrite(f,"%h\n",seed);

      end
    end
    $finish;
  end


endmodule
