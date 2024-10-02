module uart_transmitter (
    input wire [7:0] data_in,
    input wire transfer_byte,
    input wire clk,
    input wire byte_ready,
    input wire load_data_reg,
    input wire rst, 
    input wire stop_2,        
    output reg serial_out,
    output wire [3:0] bit_cnt_out
);

    
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam TRANSMIT = 2'b10;
    localparam STOP_BIT = 2'b11;

    
    reg [7:0] data_reg;
    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    reg [1:0] state = IDLE;

    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset all registers and state to initial conditions
            data_reg <= 8'b0;
            shift_reg <= 8'b0;
            bit_cnt <= 4'b0;
            state <= IDLE;
            serial_out <= 1'b1; // Ensure the serial line is idle (high)
        end else begin
            case (state)
                IDLE: begin
                    serial_out <= 1'b1; // Idle line is high
                    if (load_data_reg) begin
                        data_reg <= data_in;  // Load data register when instructed
                    end
                    if (transfer_byte) begin
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    if (byte_ready) begin
                        shift_reg <= data_reg;  // Load shift register
                        bit_cnt <= 0;
                        serial_out <= 1'b0;  // Start bit
                        state <= TRANSMIT;
                    end else begin
                        state <= IDLE;  // Return to IDLE if not ready to transmit
                    end
                end
                TRANSMIT: begin
                    if (bit_cnt < 8) begin
                        serial_out <= shift_reg[0];  // Transmit least significant bit
                        shift_reg <= shift_reg >> 1;  // Shift right
                        bit_cnt <= bit_cnt + 1;
                    end else begin
                        if(stop_2) begin
                        serial_out <= 1'b1;  // Stop bit
                        state <= STOP_BIT;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                end
                STOP_BIT: begin
                        serial_out <= 1'b1;
                        state <= IDLE;
                     
                end
            endcase
        end
    end
assign bit_cnt_out = bit_cnt;
endmodule