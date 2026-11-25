

module uart #(
    parameter BAUD_RATE = 9600,
    parameter DATA_SIZE = 8,
    parameter PARITY = 1,
    parameter EVEN_PARITY = 1,
    parameter STOP_PERIOD = 1
) (
    input wire clk,                 // needs to be 8 or 16x line rate
    input wire rx,
    output wire tx
);

// sends lsb to msb framed by start and stop bits

/*
some sort of state machine will need to used to get the framing
idle logic high (1)
start bit (logic low (0))
Parity bit: if a parity bit is used, it would be placed after all of the data bits. 
The parity bit is a way for the receiving UART to tell if any data has changed during transmission.

Stop (logic high (1)): 
*/



endmodule