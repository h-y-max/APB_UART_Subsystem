module uart_rx(
       input CLK,
       input reset_n,
       input uart_rx,
       output reg [7:0] Rx_data,
       output reg [7:0] LED,
       output reg Rx_done,
       output reg Rx_LED
    );
       parameter CLOCK=50_000_000;
       parameter BAUD=9600;
       parameter MCNT_BAUD0=CLOCK/BAUD-1;
       parameter MCNT_BAUD1=CLOCK/(2*BAUD)-1;
       reg [12:0] counter_baud;
       reg [3:0] counter_bit;
       reg en_counter_baud;
       reg [7:0] r_Rx_data;
       reg uart_rx_ff0;
       reg uart_rx_ff1;
       reg r_uart_rx;
       wire w_Rx_done;
       wire nedge;
//波特率计数器
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           counter_baud<=0;
       else if(en_counter_baud)begin
           if(counter_baud==MCNT_BAUD0)
                 counter_baud<=0;
           else
                 counter_baud<=counter_baud+1'd1;
       end
       else
            counter_baud<=0;
//位计数器
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           counter_bit<=0;
       else if(counter_baud==MCNT_BAUD1)begin
           if(counter_bit==9)
               counter_bit<=0;
           else
               counter_bit<=counter_bit+1'd1;
       end
       else
           counter_bit<=counter_bit;
//波特率计数器使能装置
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
          en_counter_baud<=0;
       else if(nedge)
          en_counter_baud<=1'd1;
       else if((counter_bit==0) && (counter_baud==MCNT_BAUD1) && (r_uart_rx==1))
          en_counter_baud<=0;
       else if((counter_bit==9) && (counter_baud==MCNT_BAUD1))
          en_counter_baud<=0;
//数据存储
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
            Rx_data<=0;
       else
            Rx_data<=r_Rx_data;
//亚稳态处理
always@(posedge CLK)begin
      uart_rx_ff0<=uart_rx;
      uart_rx_ff1<=uart_rx_ff0;
      r_uart_rx<=uart_rx_ff1;
end
//下降沿定义
assign nedge=((uart_rx_ff1==0) && (r_uart_rx==1));
//结束标志
assign w_Rx_done=((counter_bit==9) && (counter_baud==MCNT_BAUD1));
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
          Rx_done<=0;
       else
          Rx_done<=w_Rx_done;
//uart_rx
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           r_Rx_data<=0;
       else if(counter_baud==MCNT_BAUD1)begin
           case(counter_bit)
                1:r_Rx_data[0]<=r_uart_rx;
                2:r_Rx_data[1]<=r_uart_rx;
                3:r_Rx_data[2]<=r_uart_rx;
                4:r_Rx_data[3]<=r_uart_rx;
                5:r_Rx_data[4]<=r_uart_rx;
                6:r_Rx_data[5]<=r_uart_rx;
                7:r_Rx_data[6]<=r_uart_rx;
                8:r_Rx_data[7]<=r_uart_rx;
              default:r_Rx_data<=r_Rx_data;
            endcase
       end
//LED闪烁
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
          LED<=0;
       else if(w_Rx_done)
          LED<=r_Rx_data;
//LED翻转
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
          Rx_LED<=0;
       else if(w_Rx_done)
          Rx_LED<=~Rx_LED;
endmodule
