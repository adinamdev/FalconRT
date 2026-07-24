module clock_divider (
    input wire clk_in,
    output reg clk_out
);

reg [25:0] count;

initial begin
    count = 0;
    clk_out = 0;
end

always @(posedge clk_in) begin
    if (count == 26'd24_999_999) begin
        count <= 0;
        clk_out <= ~clk_out;
    end
    else begin
        count <= count + 26'd1;
    end
end

endmodule