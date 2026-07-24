module background_renderer (
    input  wire       pixel_clk,
    input  wire       reset,
    input  wire       frame_tick,

    input  wire       visible,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,

    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);
    reg [9:0] far_scroll;
    reg [9:0] mid_scroll;
    reg [9:0] near_scroll;

    reg [7:0] animation_counter;

    wire [9:0] far_x;
    wire [9:0] mid_x;
    wire [9:0] near_x;

    wire [9:0] near_x_previous;
    wire [9:0] pixel_y_previous;

    wire far_star;
    wire mid_star;
    wire near_star;

    wire near_star_right;
    wire near_star_down;
    wire near_star_diagonal;

    wire twinkle;

    assign far_x  = pixel_x + far_scroll;
    assign mid_x  = pixel_x + mid_scroll;
    assign near_x = pixel_x + near_scroll;

    assign near_x_previous  = near_x - 10'd1;
    assign pixel_y_previous = pixel_y - 10'd1;

    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            far_scroll        <= 10'd0;
            mid_scroll        <= 10'd0;
            near_scroll       <= 10'd0;
            animation_counter <= 8'd0;
        end
        else if (frame_tick) begin
            animation_counter <= animation_counter + 8'd1;

            if (animation_counter[1:0] == 2'b00)
                far_scroll <= far_scroll + 10'd1;

            if (animation_counter[0] == 1'b0)
                mid_scroll <= mid_scroll + 10'd1;

            near_scroll <= near_scroll + 10'd2;
        end
    end

    assign far_star =
        (
            far_x[5:0] ==
            {
                pixel_y[2:0],
                pixel_y[8:6]
            }
        ) &&
        (
            pixel_y[5:0] ==
            {
                far_x[8:6],
                far_x[5:3]
            }
        );

    assign mid_star =
        (
            mid_x[4:0] ==
            {
                pixel_y[1:0],
                pixel_y[7:5]
            }
        ) &&
        (
            pixel_y[4:0] ==
            {
                mid_x[7:5],
                pixel_y[4:3]
            }
        );

    assign near_star =
        (
            near_x[3:0] ==
            {
                pixel_y[1:0],
                pixel_y[7:6]
            }
        ) &&
        (
            pixel_y[3:0] ==
            {
                near_x[7:6],
                near_x[3:2]
            }
        ) &&
        (
            near_x[5] ^ pixel_y[5]
        );

    assign near_star_right =
        (
            near_x_previous[3:0] ==
            {
                pixel_y[1:0],
                pixel_y[7:6]
            }
        ) &&
        (
            pixel_y[3:0] ==
            {
                near_x_previous[7:6],
                near_x_previous[3:2]
            }
        ) &&
        (
            near_x_previous[5] ^ pixel_y[5]
        );

    assign near_star_down =
        (
            near_x[3:0] ==
            {
                pixel_y_previous[1:0],
                pixel_y_previous[7:6]
            }
        ) &&
        (
            pixel_y_previous[3:0] ==
            {
                near_x[7:6],
                near_x[3:2]
            }
        ) &&
        (
            near_x[5] ^ pixel_y_previous[5]
        );

    assign near_star_diagonal =
        (
            near_x_previous[3:0] ==
            {
                pixel_y_previous[1:0],
                pixel_y_previous[7:6]
            }
        ) &&
        (
            pixel_y_previous[3:0] ==
            {
                near_x_previous[7:6],
                near_x_previous[3:2]
            }
        ) &&
        (
            near_x_previous[5] ^
            pixel_y_previous[5]
        );

    assign twinkle =
        animation_counter[4] ^
        pixel_x[5] ^
        pixel_y[5];

    always @(*) begin
        red   = 4'd0;
        green = 4'd0;
        blue  = 4'd0;

        if (visible) begin
            red   = 4'd0;
            green = 4'd0;
            blue  = 4'd2;

            if (
                (pixel_y >= 10'd80) &&
                (pixel_y <= 10'd185) &&
                (pixel_x[7] ^ pixel_x[6])
            ) begin
                red   = 4'd1;
                green = 4'd0;
                blue  = 4'd3;
            end

            if (pixel_y >= 10'd370) begin
                red   = 4'd0;
                green = 4'd1;
                blue  = 4'd3;
            end

            if (far_star) begin
                red   = 4'd3;
                green = 4'd4;
                blue  = 4'd6;
            end

            if (mid_star) begin
                if (twinkle) begin
                    red   = 4'd8;
                    green = 4'd10;
                    blue  = 4'd15;
                end
                else begin
                    red   = 4'd5;
                    green = 4'd7;
                    blue  = 4'd11;
                end
            end

            if (
                near_star ||
                near_star_right ||
                near_star_down ||
                near_star_diagonal
            ) begin
                red   = 4'd12;
                green = 4'd14;
                blue  = 4'd15;
            end
        end
    end

endmodule