module uart_res_top(
    input wire clk,           
    input wire rst,           
    input wire serial_in,    
    output wire [7:0] data_out,  
    output wire byte_ready,  
    input wire [31:0] dvsr    
);

    // Signals for UART and Baud Rate Generator
    reg tick;           // Tick from baud rate generator
    reg [31:0] counter; // Counter to divide the clock

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter >= (dvsr/16 - 1)) begin
                counter <= 0;   // Reset counter
                tick <= 1;      // Generate a tick
            end else begin
                counter <= counter + 1;
                tick <= 0;      // Reset tick on other cycles
            end
        end
    end

    // Instance of UART receiver
    uart_receiver uart_rx(
        .clk(tick),        // System clock for the receiver, not the tick
        .rst(rst),
        .serial_in(serial_in),
        .data_out(data_out),
        .byte_ready(byte_ready)
    );

endmodule
