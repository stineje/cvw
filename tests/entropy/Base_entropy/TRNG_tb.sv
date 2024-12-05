module tb ();

  logic        rst, clk;
  logic        enable_i, valid_o;
  logic [7:0]  data_o;
  logic [31:0] temp;
  integer      i, f, count;

  // instantiate device under test
  trng #(.NUM_CELLS(5), .NUM_INV_START(5), .SIM_MODE(1)) dut 
    (
      .clk(clk),
      .rst(rst),
      .enable_i(enable_i),
      .data_o(data_o),
      .valid_o(valid_o)
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

  // always @(posedge valid_o) begin
  //   $display(data_o);
  // end

    initial 
  begin	
    f = $fopen("output.txt","wb");
    // f = $fopen("output2.txt","w");
    count = 0;

    for (i=0; i<1000000; i=i+1) begin
      @(posedge valid_o) begin
        if (count < 3) begin
          $fwrite(f,"%h",data_o);
          count = count + 1;
        end else begin
          $fwrite(f,"%h\n",data_o);
          count = 0;
        end
      end
    end

    // for (i=0; i<250000; i=i+1) begin
    //   @(posedge valid_o) begin
    //     $fwrite(f,"%h\n",data_o);
    //   end
    // end

    // temp = 32'b0;
    // for (i=0; i<32; i=i+1) begin
    //   @(posedge valid_o) begin
    //     if (count < 3) begin
    //       temp = {temp[23:0], data_o};
    //       count = count + 1;
    //     end else begin
    //       temp = {temp[23:0], data_o};
    //       $fwrite(f,"%u",temp);
    //       $display("%h",temp);
    //       count = 0;
    //     end
    //   end
    // end


    // for (i=0; i<512; i=i+1) begin
    //   @(posedge valid_o) begin
    //     $fwrite(f,"%d\n",data_o);
    //   end
    // end
    $finish;
  end


endmodule
