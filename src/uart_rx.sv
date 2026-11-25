module uart_rx #(
    parameter BAUD_RATE = 9600,
    parameter DATA_SIZE = 8,
    parameter PARITY = 1,
    parameter EVEN_PARITY = 1,
    parameter STOP_PERIOD = 1
) (
    input   wire                    clk,
    input   wire                    rx_data,             // 8x to 16x the baud_rate
    input   wire                    rst_f, 
    output  logic [DATA_SIZE-1:0]   rx_fifo
);

// define variables for fsm
enum {
    RESET,
    IDLE,
} fsm_state;


// need a state machine
always_ff @( posedge clk ) begin : fsm_rx

    case (fsm_state)
        RESET : 
        IDLE : 
        default: 
    endcase
    
end

endmodule