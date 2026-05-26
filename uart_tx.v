module uart_tx(
       input CLK,
       input reset_n,
       input [7:0] Tx_data,
       input send_go,
       output reg Tx_done,
       output reg uart_tx,
       output reg Tx_LED
    );
       parameter CLOCK=50_000_000;
       parameter MCNT_DELAY=CLOCK-1;
       parameter BAUD=9600;
       parameter MCNT_BAUD=CLOCK/BAUD-1;
       reg [25:0] counter_delay;
       reg [12:0] counter_baud;
       reg [3:0] counter_bit;
       reg en_counter_baud;
       reg send_go_ff0;
       reg send_go_ff1;
       reg r_send_go;
       reg [7:0] r_Tx_data;
       wire send_go_pluse;
       wire w_Tx_done;
//1s延时计数器
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           counter_delay<=0;
       else if(counter_delay==MCNT_DELAY)
           counter_delay<=0;
       else if(send_go_pluse)
           counter_delay<=0;
       else if(en_counter_baud)
           counter_delay<=counter_delay;
       else
           counter_delay<=counter_delay+1'd1;
//波特率计数器
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           counter_baud<=0;
       else if(en_counter_baud)begin
           if(counter_baud==MCNT_BAUD)
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
       else if(counter_baud==MCNT_BAUD)begin
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
       else if((send_go_pluse) || (counter_delay==MCNT_DELAY))
           en_counter_baud<=1'd1;
       else if((counter_baud==MCNT_BAUD) && (counter_bit==9))
           en_counter_baud<=0;
//手动发送装置
    //亚稳态处理
    always@(posedge CLK)begin
        send_go_ff0<=send_go;
        send_go_ff1<=send_go_ff0;
        r_send_go<=send_go_ff1;
    end
    //脉冲信号定义
    assign send_go_pluse=((send_go_ff1==1) && (r_send_go==0));
//结束标志
assign w_Tx_done=((counter_baud==MCNT_BAUD) && (counter_bit==9));
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           Tx_done<=0;
       else
           Tx_done<=w_Tx_done;
//数据存储
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
           r_Tx_data<=0;
       else
           r_Tx_data<=Tx_data;
//uart_tx
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
            uart_tx<=1'd1;
       else if(en_counter_baud)begin
            case(counter_bit)
                0:uart_tx<=0;
                1:uart_tx<=r_Tx_data[0];
                2:uart_tx<=r_Tx_data[1];
                3:uart_tx<=r_Tx_data[2];
                4:uart_tx<=r_Tx_data[3];
                5:uart_tx<=r_Tx_data[4];
                6:uart_tx<=r_Tx_data[5];
                7:uart_tx<=r_Tx_data[6];
                8:uart_tx<=r_Tx_data[7];
                9:uart_tx<=1'd1;
              default:uart_tx<=uart_tx;
             endcase
        end
//LED翻转
always@(posedge CLK or negedge reset_n)
       if(!reset_n)
          Tx_LED<=0;
       else if(w_Tx_done)
          Tx_LED<=!Tx_LED;
endmodule
