
module tx_uart #(
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



/********************************************************************************
*********************************************************************************
Define Variables
*********************************************************************************
********************************************************************************/
typedef enum {
    IDLE,
    LOAD_INPUT,
    SEND_INPUT,
    SHIFT_TO_DEFAULT
} fsm_state_t;


//tx_shift_reg variables 
localparam START_SIZE = 1;
localparam FRAME_SIZE = STOP_NUM + PARITY + DATA_SIZE + START_SIZE;

// fsm variables
fsm_state_t fsm_current_state;
fsm_state_t fsm_next_state;
logic [$clog2(FRAME_SIZE):0] send_cnt;

logic [FRAME_SIZE-1:0] frame;
logic shift_en;
logic load_en;


/********************************************************************************
*********************************************************************************
TX_SHIFT_REG
*********************************************************************************
********************************************************************************/
logic parity_bit;
if (PARITY) begin : generate_parity_block
    calc_parity #(
        .DATA_SIZE (DATA_SIZE),
        .EVEN_PARITY(EVEN_PARITY)
    ) u_calc_parity (
        .data_in(data_in),
        .parity_bit(parity_bit)
    );
end else begin : generate_empty_parity
    assign parity_bit = 1'b0;
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
        load_en <= '0;
        shift_en <= '0;
        send_cnt <= '0;
    end else begin
        fsm_current_state <= fsm_next_state;

        if (fsm_current_state == IDLE) begin 
            load_en <= '0;
            shift_en <= '0;
            send_cnt <= '0;
        end else if (fsm_current_state == LOAD_INPUT) begin
            load_en <= '1;
            shift_en <= '0;
            send_cnt <= '0;
        end else if (fsm_current_state == SEND_INPUT) begin
            load_en <= '0;
            shift_en <= '1;
            send_cnt <= send_cnt + 1;
        end else if (fsm_current_state == SHIFT_TO_DEFAULT) begin
            load_en <= '0;
            shift_en <= '1;
            send_cnt <= 0;
        end 
    end
end

always_comb begin : fsm
    case (fsm_current_state)
        IDLE : begin 
            if (en) begin
                fsm_next_state = LOAD_INPUT;
            end
        end
        LOAD_INPUT : begin
            if (~en) begin
                fsm_next_state = SEND_INPUT;
            end
        end
        SEND_INPUT : begin
            if (send_cnt >= FRAME_SIZE) begin
                fsm_next_state = SHIFT_TO_DEFAULT;
            end
        end
        SHIFT_TO_DEFAULT : begin
            fsm_next_state = IDLE;
        end
        default: fsm_next_state = IDLE;
    endcase
end


endmodule
