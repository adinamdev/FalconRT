module seven_segment_decoder (
    input  wire [3:0] digit,
    input  wire       blank,

    output reg  [7:0] segments
);

    /*
        DE10-Lite seven-segment outputs are active-low.

        segments[7] = decimal point
        segments[6] = segment G
        segments[5] = segment F
        segments[4] = segment E
        segments[3] = segment D
        segments[2] = segment C
        segments[1] = segment B
        segments[0] = segment A
    */

    always @(*) begin
        if (blank) begin
            segments = 8'b11111111;
        end
        else begin
            case (digit)

                4'd0: segments = 8'b11000000;
                4'd1: segments = 8'b11111001;
                4'd2: segments = 8'b10100100;
                4'd3: segments = 8'b10110000;
                4'd4: segments = 8'b10011001;
                4'd5: segments = 8'b10010010;
                4'd6: segments = 8'b10000010;
                4'd7: segments = 8'b11111000;
                4'd8: segments = 8'b10000000;
                4'd9: segments = 8'b10010000;

                default:
                    segments = 8'b11111111;

            endcase
        end
    end

endmodule