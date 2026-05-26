module APB_uart_Slave(
       input CLK,
       input reset_n,
       input [31:0] PADDR,
       input [31:0] PWDATA,
       input PSEL,
       input PWRITE,
       input PENABLE,
       input [3:0] PSTRB,
       output [31:0] PRDATA,
       output PREADY,
       output uart_tx,
       input uart_rx
    );
       localparam ADDR_TX=8'd0;
       localparam ADDR_RX=8'd4;
       localparam ADDR_STA=8'd8;
       reg [7:0] Tx_data;
       wire Tx_done;
       reg send_go;
       wire [7:0] Rx_data;
       wire Rx_done;
       reg [31:0] r_rdata;
uart_tx uart_tx_inst0(
       .CLK(CLK),
       .reset_n(reset_n),
       .Tx_data(Tx_data),
       .Tx_done(Tx_done),
       .uart_tx(uart_tx),
       .Tx_LED(),
       .send_go(send_go)
 );
 uart_rx uart_rx_inst0(
       .CLK(CLK),
       .reset_n(reset_n),
       .Rx_data(Rx_data),
       .Rx_done(Rx_done),
       .uart_rx(uart_rx),
       .Rx_LED(),
       .LED()
 );    
always@(posedge CLK or negedge reset_n)
       if(!reset_n)begin
           Tx_data<=8'd0;
           send_go<=1'd0;
       end
       else if(PSEL && PWRITE && PENABLE && PADDR[7:0]==ADDR_TX)begin
           Tx_data<=PWDATA[7:0];
           send_go<=1'd1;
       end
       else
           send_go<=0;
           
always@(posedge CLK or negedge reset_n)
        if(!reset_n)
            r_rdata<=0;
        else if(PSEL && PENABLE && !PWRITE)begin
            case(PADDR[7:0])
              ADDR_RX: 
                   r_rdata<={24'b0,Rx_data};
              ADDR_STA:
                   r_rdata<={30'b0,Tx_done,Rx_done};
             default:r_rdata<=32'b0;
            endcase
         end
         else
            r_rdata<=32'b0;
            
 assign PREADY=1'd1;
 assign PRDATA=r_rdata;
            
endmodule
