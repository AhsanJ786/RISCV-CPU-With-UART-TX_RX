module uart_system_top(
    input wire clk,           // System clock
    input wire rst,           
    input wire [7:0] data_in, // Data input for UART 
    input wire transfer_byte, // Start transmission signal
    input wire byte_ready,    // Data register to shift register load enable
    input wire load_data_reg, // Load data into data register from data bus
    output wire serial_out,    // Serial output from UART transmitter
    input logic [31:0] dvsr,
    input logic stop_2,
    output wire [3:0] bit_cnt_out
);

    // Signals for UART and Baud Rate Generator
    logic tick;               // Tick from baud rate generator
    logic [31:0] r_reg;
    logic [31:0] r_next;
/*
    // Instance of baud rate generator
    baud_rate_gen baud_gen(
        .clk(clk),
        .rst(rst),
        .dvsr(32'd5), // Example divisor for 9600 baud rate from a 50MHz clock
        .tick(tick)
    );

    // Generate UART clock from baud tick
    assign clk_uart = tick;*/
 always_ff @( posedge clk or negedge rst ) begin 
    if ( !rst)
    r_reg <= 0;
    else
    r_reg <= r_next;   
end
assign r_next = (r_reg == dvsr) ? 0: r_reg+1;
assign tick = (r_reg == 1);

    // Instance of UART transmitter
    uart_transmitter uart_tx(
        .data_in(data_in),
        .transfer_byte(transfer_byte),
        .clk(tick),       // Driven by baud rate tick
        .byte_ready(byte_ready),
        .load_data_reg(load_data_reg),
        .rst(rst),         
        .serial_out(serial_out),
        .bit_cnt_out(bit_cnt_out),
        .stop_2(stop_2)
    );

endmodule