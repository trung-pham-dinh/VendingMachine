module vending_machine_tb (
);
  parameter PERIOD     = 10;

  parameter MAX_AMOUNT = 40;
  parameter UNIT       = 5;
  parameter NICKLE     = 5;
  parameter DIME       = 10;
  parameter QUARTER    = 25;
  parameter SODA       = 20;

  logic       i_clk;
  logic       i_rst;
  logic       i_nickle;
  logic       i_dime;
  logic       i_quarter;
  logic       o_soda;
  logic [2:0] o_change;

  vending_machine #(
    .MAX_AMOUNT(MAX_AMOUNT),   
    .UNIT      (UNIT      ),
    .NICKLE    (NICKLE    ),
    .DIME      (DIME      ),
    .QUARTER   (QUARTER   ),
    .SODA      (SODA      )
  ) dut (
    .*
  );    

  initial begin
    i_clk     = 0;
    i_rst     = 1;
    i_nickle  = 0;
    i_dime    = 0;
    i_quarter = 0;

    forever begin
      #(PERIOD/2) i_clk = ~i_clk;
    end
  end

  initial begin
    #(5*PERIOD);
    i_rst = 0;

    forever begin
      @(posedge i_clk);
      {i_nickle,i_dime,i_quarter} = 3'b1 << $urandom()%4;
    end
  end

  initial begin
    #(100*PERIOD);
    $finish;
  end

endmodule
