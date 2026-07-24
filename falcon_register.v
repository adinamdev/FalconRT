module falcon_register (
    input [7:0] data_in,
    input clk,
    output reg [7:0] data_out
);

always @(posedge clk) begin
    data_out <= data_in;
end

endmodule