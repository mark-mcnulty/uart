module uart #(
    parameter BAUD_RATE = 9600,
    parameter DATA_SIZE = 8,
    parameter PARITY = 1,
    parameter EVEN_PARITY = 1,
    parameter STOP_PERIOD = 1
) (
    input wire clk,
    input wire rx,
    output wire tx
);


endmodule