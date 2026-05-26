module APB_uart_Master(
       input CLK,
       input reset_n,
       input user_en,
       input user_write,
       input [31:0] user_addr,
       input [31:0] user_wdata,
       output user_tran_done,
       output [31:0] user_rdata,
       input PREADY,
       input [31:0] PRDATA,
       output PWRITE,
       output PSEL,
       output PENABLE,
       output [31:0] PWDATA,
       output [31:0] PADDR,
       output [3:0] PSTRB
    );
       localparam STA_IDLE=6'b000_001;
       localparam STA_WR=6'b000_010;
       localparam STA_RD=6'b000_100;
       localparam STA_ENABLE=6'b001_000;
       localparam STA_DONE=6'b010_000;
       localparam STA_WAIT=6'b100_000;
       reg [5:0] state_cur;
       reg [5:0] state_nxt;
       reg r_tran_done;
       reg [31:0] r_rdata;
       reg r_PWRITE;
       reg r_PSEL;
       reg r_PENABLE;
       reg [31:0] r_PWDATA;
       reg [31:0] r_PADDR;
       reg [3:0] r_PSTRB;
 assign user_tran_done=r_tran_done;
 assign user_rdata=r_rdata;
 assign PWRITE=r_PWRITE;
 assign PSEL=r_PSEL;
 assign PENABLE=r_PENABLE;
 assign PWDATA=r_PWDATA;
 assign PADDR=r_PADDR;
 assign PSTRB=r_PSTRB;
 //三段式状态机
 //第一段
 always@(posedge CLK or negedge reset_n)
        if(!reset_n)
            state_cur<=STA_IDLE;
        else
            state_cur<=state_nxt;
 //第二段
 always@(*)begin
        if(!reset_n)
            state_nxt=STA_IDLE;
        else begin
            case(state_cur)
                STA_IDLE:
                    if(user_en && user_write)
                          state_nxt=STA_WR;
                    else if(user_en && !user_write)
                          state_nxt=STA_RD;
                    else
                          state_nxt=state_nxt;
                STA_WR:
                    state_nxt=STA_ENABLE;
                STA_RD:
                    state_nxt=STA_ENABLE;
                STA_ENABLE:
                    if(PREADY)
                       state_nxt=STA_DONE;
                    else
                       state_nxt=state_nxt;
                STA_DONE:
                    state_nxt=STA_WAIT;
                STA_WAIT:
                    state_nxt=STA_IDLE;
              default:state_nxt=STA_IDLE;
            endcase
        end
  end
//第三段
 always@(posedge CLK or negedge reset_n)
        if(!reset_n)begin
            r_tran_done<=1'd0;
            r_rdata<=32'd0;
            r_PWRITE<=1'd0;
            r_PSEL<=1'd0;
            r_PENABLE<=1'd0;
            r_PWDATA<=32'd0;
            r_PADDR<=32'd0;
            r_PSTRB<=4'b1111;
        end
        else begin
            case(state_cur)
                STA_IDLE:
                    begin
                       r_tran_done<=1'd0;
                       r_PWRITE<=1'd0;
                       r_PSEL<=1'd0;
                       r_PENABLE<=1'd0;
                       r_PWDATA<=32'd0;
                       r_PADDR<=32'd0;
                       r_PSTRB<=4'b1111;
                    end
                STA_WR:
                    begin
                       r_PWRITE<=1'd1;
                       r_PSEL<=1'd1;
                       r_PENABLE<=1'd0;
                       r_PWDATA<=user_wdata;
                       r_PADDR<=user_addr;
                    end
                STA_RD:
                    begin
                       r_PWRITE<=1'd0;
                       r_PSEL<=1'd1;
                       r_PENABLE<=1'd0;
                       r_PADDR<=user_addr;
                    end 
                STA_ENABLE:
                       r_PENABLE<=1'd1;
                STA_DONE:
                    begin
                       r_PENABLE<=1'd0;
                       r_PSEL<=1'd0;
                    end
                STA_WAIT:
                    begin
                       r_tran_done<=1'd1;
                       r_rdata<=PRDATA;
                    end
              default:begin
                        r_tran_done<=1'd0;
                        r_rdata<=32'd0;
                        r_PWRITE<=1'd0;
                        r_PSEL<=1'd0;
                        r_PENABLE<=1'd0;
                        r_PWDATA<=32'd0;
                        r_PADDR<=32'd0;
                        r_PSTRB<=4'b1111;
                     end
          endcase
      end                         
endmodule

