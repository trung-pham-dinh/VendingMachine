module vending_machine #(
  parameter MAX_AMOUNT = 40,
  parameter UNIT    = 5,
  parameter NICKLE  = 5,
  parameter DIME    = 10,
  parameter QUARTER = 25,
  parameter SODA    = 20
)(
  input  logic       i_clk,
  input  logic       i_rst,
  input  logic       i_nickle,
  input  logic       i_dime,
  input  logic       i_quarter,
  output logic       o_soda,
  output logic [2:0] o_change
);
  localparam CNT_WIDTH  = $clog2(MAX_AMOUNT/UNIT + 1);
  // Scale every cost based on unit -> calculate on fewer number of bits
  // A soda cost 20 -> cost 4 unit -> calculate using 4 instead of 20

  logic [CNT_WIDTH-1:0] deposited_cnt;
  logic [CNT_WIDTH-1:0] deposited_cnt_nxt;
  logic [CNT_WIDTH-1:0] deposited_cnt_raw;
  logic [CNT_WIDTH-1:0] accepted_cnt;
  logic [CNT_WIDTH:0]   change_cnt;    // extra bit for sign
  logic                 is_enough;
  logic                 is_valid_coin; // check if there is only one input coin each cycle

  always_ff @( posedge i_clk ) begin
    if(i_rst) begin
      o_soda        <= 1'b0;         
      o_change      <= 3'b0; 
      deposited_cnt <= CNT_WIDTH'(0); 
    end
    else begin
      o_soda        <= is_enough; 
      o_change      <= is_enough ? change_cnt[2:0] : 3'b0; 
      deposited_cnt <= deposited_cnt_nxt; 
    end
  end

  always_comb begin
    // Check if input is onehot code
    is_valid_coin = ~|(({i_nickle,i_dime,i_quarter}-1'b1) & {i_nickle,i_dime,i_quarter}); 

    accepted_cnt =  is_valid_coin ? {CNT_WIDTH{i_nickle}}  & CNT_WIDTH'(NICKLE/UNIT)
                                  | {CNT_WIDTH{i_dime}}    & CNT_WIDTH'(DIME/UNIT)
                                  | {CNT_WIDTH{i_quarter}} & CNT_WIDTH'(QUARTER/UNIT) 
                                  : CNT_WIDTH'(0);
    deposited_cnt_raw = CNT_WIDTH'(deposited_cnt + accepted_cnt);
    change_cnt        = deposited_cnt_raw - CNT_WIDTH'(SODA/UNIT);
    // Enough if change amount is not negative
    is_enough         = ~change_cnt[CNT_WIDTH]; 
    deposited_cnt_nxt = is_enough ? CNT_WIDTH'(0) : deposited_cnt_raw;
  end

  // ASSERT_SINGLE_COINT: assert property 
  //                      (@(posedge i_clk) disable iff (i_rst) 
  //                      (~$onehot0({i_nickle,i_dime,i_quarter}) |-> accepted_cnt==0));
endmodule
