`timescale 1ns / 1ps
`define WCLK_PERIOD 20
module APB_uart_top_tb();
       reg CLK;
       reg reset_n;
       reg user_write;
       reg user_en;
       reg [31:0] user_addr;
       reg [31:0] user_wdata;
       wire [31:0] user_rdata;
       wire  user_tran_done;
       wire uart_tx;
       wire uart_rx;
APB_uart_top APB_uart_top_inst(
       .CLK(CLK),
       .reset_n(reset_n),
       .user_en(user_en),
       .user_write(user_write),
       .user_wdata(user_wdata),
       .user_addr(user_addr),
       .user_tran_done(user_tran_done),
       .user_rdata(user_rdata),
       .uart_tx(uart_tx),
       .uart_rx(uart_rx)
 );
assign uart_rx=uart_tx;
initial begin
    CLK=0;
    forever
       #(`WCLK_PERIOD/2) CLK=~CLK;
end

initial begin
reset_n=0;
user_en=0;
user_write=0;
user_addr=32'd0;
user_wdata=32'd0;
#100;
reset_n=1;
#20;

user_en=1;
user_write=1;
user_addr=32'd0;
user_wdata=32'd27;
@(posedge CLK);
user_en=0;
@(posedge user_tran_done);
#2_000_000;

user_en=1;
user_write=0;
user_addr=32'd4;
@(posedge CLK);
user_en=0;
@(posedge user_tran_done);
#2_000_000;
    $finish;
end
endmodule
