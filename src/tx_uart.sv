
module tx_uart #(
    parameter CLK_MHZ = 10,
    parameter BAUD_RATE = 9600,
    parameter DATA_SIZE = 8,
    parameter PARITY = 1,
    parameter EVEN_PARITY = 1, 
    parameter STOP_NUM = 1                  // valid 1 or 2
)(
    input                   baud_clk,
    input                   rst_f,
    input                   en,             // this is the signal that will latch the input, when released transmission will start
    input [DATA_SIZE-1:0]   data_in,
    output                  data_out
);
// define variables
typedef enum {
    IDLE,
    LOAD_INPUT,
    SEND_INPUT,
    TRANSMIT
} fsm_state_t;

// fsm variables
fsm_state_t fsm_current_state;
fsm_state_t fsm_next_state;


//tx_shift_reg variables 
localparam START_SIZE = 1;
localparam FRAME_SIZE = STOP_NUM + PARITY + DATA_SIZE + START_SIZE;

logic [FRAME_SIZE-1:0] frame;
logic shift_en;
logic load_en;


/********************************************************************************
*********************************************************************************
TX_SHIFT_REG
*********************************************************************************
********************************************************************************/

if (PARITY) begin : generate_parity_block
    logic parity_bit;
    calc_parity #(
        .DATA_SIZE (DATA_SIZE),
        .EVEN_PARITY(EVEN_PARITY)
    ) u_calc_parity (
        .data_in(data_in),
        .parity_bit(parity_bit)
    );
end


/********************************************************************************
*********************************************************************************
TX_SHIFT_REG
*********************************************************************************
********************************************************************************/

assign frame = {{STOP_NUM{1'b1}}, {PARITY{parity_bit}}, data_in, 1'b0}; 

tx_shift_reg #(
    .FRAME_SIZE(FRAME_SIZE),      
    .DEFAULT_OUTPUT(1'b1),
    .LSB_FIRST(1'b1)
) u_tx_shift_reg (
    .rst_f(rst_f),
    .baud_clk(baud_clk),
    .load_en(load_en),
    .shift_en(shift_en),
    .frame_in(frame),
    .serial_out(data_out)
);


/********************************************************************************
*********************************************************************************
FSM
*********************************************************************************
********************************************************************************/

always_ff @( posedge baud_clk ) begin : fsm_clkd
    if (~rst_f) begin
        fsm_current_state <= IDLE; 
    end else begin
        fsm_current_state <= fsm_next_state;
    end
end

always_comb begin : fsm
    case (fsm_current_state)
        IDLE : begin 
            if (en) begin
                fsm_next_state = LOAD_INPUT;
            end
        end
        LATCH_INPUT : begin
            if (~en) begin
                fsm_next_state = SEND_INPUT;
            end
        end
        TRANSMIT :
        default: 
    endcase
end


endmodule
