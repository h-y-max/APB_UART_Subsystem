module APB_uart_top(
       input CLK,
       input reset_n,
       input user_en,
       input user_write,
       input [31:0] user_addr,
       input [31:0] user_wdata,
       output user_tran_done,
       output [31:0] user_rdata,
       output uart_tx,
       input uart_rx
    ); 
       wire [31:0] w_PADDR;
       wire [31:0] w_PWDATA;
       wire w_PENABLE;
       wire w_PSEL;
       wire w_PWRITE;
       wire w_PREADY;
       wire [31:0] w_PRDATA;
       wire [3:0] w_PSTRB;
 APB_uart_Slave APB_uart_Slave_inst(
       .CLK(CLK),
       .reset_n(reset_n),
       .PADDR(w_PADDR),
       .PWDATA(w_PWDATA),
       .PSEL(w_PSEL),
       .PENABLE(w_PENABLE),
       .PREADY(w_PREADY),
       .PSTRB(w_PSTRB),
       .PRDATA(w_PRDATA),
       .PWRITE(w_PWRITE),
       .uart_tx(uart_tx),
       .uart_rx(uart_rx)
);
APB_uart_Master APB_uart_Master_inst(
       .CLK(CLK),
       .reset_n(reset_n),
       .PADDR(w_PADDR),
       .PWDATA(w_PWDATA),
       .PSEL(w_PSEL),
       .PENABLE(w_PENABLE),
       .PREADY(w_PREADY),
       .PSTRB(w_PSTRB),
       .PRDATA(w_PRDATA),
       .PWRITE(w_PWRITE),
       .user_en(user_en),
       .user_write(user_write),
       .user_wdata(user_wdata),
       .user_addr(user_addr),
       .user_tran_done(user_tran_done),
       .user_rdata(user_rdata)
 );
endmodule
