
module rx_packet_detect #(
    parameter THRESHOLD = 8                 // this is how many clocks the incoming packet must go low for to 
                                            // register as an incoming packet
)(
    input           data,
    input           clk,
    input           baud_clk,
    input           rst_f,
    output logic    detected
);

/********************************************************************************
*********************************************************************************
Define Variables
*********************************************************************************
********************************************************************************/
typedef enum {
    IDLE,
    COUNT,
    FOUND, 
    WAIT_FOR_BAUD_LOW, 
    WAIT_FOR_BAUD_HIGH
} fsm_t;

fsm_t fsm_current_state;
fsm_t fsm_next_state;
logic [$clog2(THRESHOLD):0] detect_cnt;
logic signal_low;



/********************************************************************************
*********************************************************************************
FSM
*********************************************************************************
********************************************************************************/
always_comb begin 
    case (fsm_current_state)
        IDLE : begin
            if (signal_low == '1) begin
                fsm_next_state = COUNT;
            end else begin 
                fsm_next_state = IDLE;
            end
        end
        COUNT : begin
            if (signal_low == '0) begin
                fsm_next_state = IDLE;
            end else if (detect_cnt >= THRESHOLD) begin
                fsm_next_state = FOUND;
            end else begin 
                fsm_next_state = COUNT;
            end
        end
        FOUND : begin
            fsm_next_state = IDLE;
        end
        WAIT_FOR_BAUD_LOW : begin 
            if (~baud_clk) begin
                fsm_next_state = WAIT_FOR_BAUD_HIGH;
            end else begin 
                fsm_next_state = WAIT_FOR_BAUD_LOW;
            end
        end
        WAIT_FOR_BAUD_HIGH : begin 
            if (baud_clk) begin 
                fsm_next_state = IDLE;
            end else begin 
                fsm_next_state = WAIT_FOR_BAUD_HIGH;
            end
        end
        default : fsm_next_state = IDLE;
    endcase 
end


always_ff @(posedge clk) begin 
    if (~rst_f) begin
        detected <= 0;
        detect_cnt <= 0;
        signal_low <= 0;
    end else begin
        fsm_current_state <= fsm_next_state;
        case (fsm_current_state) 
            IDLE: begin
                if (data == '0) begin
                    signal_low <= '1;
                    detect_cnt <= '1; 
                    detected <= '0;
                end else begin
                    signal_low <= '0;
                    detect_cnt <= '0;
                    detected <= '0;
                end
            end
            COUNT: begin
                if (data == '1) begin 
                    signal_low <= '0;
                    detect_cnt <= '0;
                    detected <= '0;
                end else begin
                    signal_low <= '1;
                    detect_cnt <= detect_cnt + 1;
                    detected <= '0;
                end
            end
            FOUND: begin
                detected <= '1;
            end
            WAIT_FOR_BAUD_LOW: begin
                detected <= '1;
            end
            WAIT_FOR_BAUD_HIGH : begin 
                detected <= '1;
            end
        endcase

    end
end



endmodule