module calc_parity #(
    parameter DATA_SIZE = 8,
    parameter bit EVEN_PARITY = 1'b1
)(
    input [DATA_SIZE-1:0]   data_in,
    output                  parity_bit
);

if (EVEN_PARITY) begin : even_parity_assign
    assign parity_bit = ~^data_in;
end else if (EVEN_PARITY == 1'b0) begin : odd_parity_assign
    assign parity_bit = ^data_in;
end 

endmodule


