module uart_regfile(tx_intr,rx_intr,rec_data,ready_rec,bit_cnt_out,A,rst,clk,WE,WD,RD,uart_sel,uart_baud_divisor_out,uart_data_out,uart_tx_control_out);
input logic clk,WE,uart_sel,rst;
input logic [31:0] A,WD;
output logic [31:0] RD,uart_baud_divisor_out,uart_data_out,uart_tx_control_out;
output logic tx_intr,rx_intr;
input logic [3:0] bit_cnt_out;
input logic [7:0] rec_data;
input logic ready_rec;

 // Memory-mapped register addresses
    localparam UART_DATA_REG = 32'h8000_0000;
    localparam UART_BAUD_REG = 32'h8000_0004;
    localparam UART_CTRL_REG = 32'h8000_0008;
    localparam UART_RXDA_REG = 32'h8000_000C;
    localparam UART_IE_REG   = 32'h8000_0010;
    localparam UART_IP_REG   = 32'h8000_0014;
    
    logic rx_busy_flag,tx_int_flag,rx_int_flag;
    reg [31:0] uart_data_reg;
    reg [31:0] uart_baud_divisor_reg;
    reg [31:0] uart_tx_control_reg;
    reg [31:0] uart_rx_data_reg;
    reg [31:0] uart_ie_reg;
    reg [31:0] uart_ip_reg;
    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            uart_data_reg <=0;
            uart_baud_divisor_reg <=0;
            uart_tx_control_reg <=0;
            uart_rx_data_reg <= 0;
            uart_ie_reg  <=0;
            uart_ip_reg  <=0;
end
        else begin
            if (bit_cnt_out == 8)begin
                        uart_data_reg[31]  =0;        // trasn busy flag
                    end 
            if (WE & uart_sel) begin                              // write case
                case (A)
                UART_DATA_REG:begin 
                    if ( uart_data_reg[31] == 0)begin  // checking busy flag
                        uart_data_reg[7:0] <= WD[7:0];
                        uart_data_reg[30:8]<= 0;
                        uart_data_reg[31]  <=1;        // busy flag
                   
                    end
                end
                UART_BAUD_REG: uart_baud_divisor_reg <= WD;
                UART_CTRL_REG: uart_tx_control_reg <= WD;
                UART_IE_REG  : begin 
                              uart_ie_reg[1:0] <= WD[1:0];
                              uart_ie_reg[31:2]<=0;
                               end
                
        endcase
            end
            
        end
    end
      always_comb begin 
         if (ready_rec == 0) begin
                    rx_busy_flag = 1;
                end
                else begin
                    rx_busy_flag = 0;
                end
      end
    always@(posedge clk ) begin
          uart_rx_data_reg[31] <= rx_busy_flag;
                if (uart_rx_data_reg[31] == 1'b0) begin
                    uart_rx_data_reg[7:0] <= rec_data;
                    uart_rx_data_reg[30:8] <= 0;
                end
    end
    
    always@(*)begin
        if (~WE & uart_sel) begin                                // read case
                case (A)  
                UART_DATA_REG: RD = uart_data_reg;
                UART_BAUD_REG: RD = uart_baud_divisor_reg;
                UART_CTRL_REG: RD = uart_tx_control_reg; 
                UART_RXDA_REG: RD = uart_rx_data_reg;
                UART_IE_REG:   RD = uart_ie_reg;                               
                endcase 
            end
        
    end
                      // logic for uart ip reg
    always@(posedge clk or negedge rst )begin
        if(~rst) begin
            tx_int_flag <=0;
            rx_int_flag <=0;
        end
        else begin
        if ((uart_ie_reg[0] == 1) && bit_cnt_out == 8)begin
            tx_int_flag <= 1;
        end
        if((uart_ie_reg[1] == 1) && ready_rec == 1) begin
            rx_int_flag <= 1;
        end
    end    
    end
  
   assign uart_data_out = uart_data_reg;
   assign uart_baud_divisor_out = uart_baud_divisor_reg;
   assign uart_tx_control_out = uart_tx_control_reg;
   assign tx_intr = tx_int_flag;
   assign rx_intr = rx_int_flag;
   
 

endmodule