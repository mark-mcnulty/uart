
module tx_shift_reg #(
    parameter int FRAME_SIZE = 8,                 // number of registers in shift
    parameter bit DEFAULT_OUTPUT = 1'b1,        // Default state of the output, logic 1
    parameter bit LSB_FIRST = 1'b1              // shifts the LSB out first
)(
    input wire                          rst_f,
    input wire                          baud_clk,
    input wire                          load_en,
    input wire                          shift_en,
    input wire [FRAME_SIZE-1:0]         frame_in,
    output wire                         serial_out
);


logic data_out_t;
logic [FRAME_SIZE-1:0] internal_reg;

always_ff @(posedge baud_clk) begin

    if (!rst_f) begin
        data_out_t <= DEFAULT_OUTPUT;
        internal_reg <= {FRAME_SIZE{DEFAULT_OUTPUT}};
    end else if (load_en) begin 
        internal_reg <= frame_in;
    end else if (shift_en) begin
        if (LSB_FIRST) begin
            internal_reg <= {DEFAULT_OUTPUT, internal_reg[FRAME_SIZE-1:1]};
            data_out_t <= internal_reg[0];
        end else begin 
            internal_reg <= {internal_reg[FRAME_SIZE-2:0], DEFAULT_OUTPUT};
            data_out_t <= internal_reg[FRAME_SIZE-1];
        end
    end
end


assign serial_out = data_out_t;

endmodule