module color_mapper (
    input  wire       visible,
    input  wire       game_over,

    input  wire [3:0] bg_red,
    input  wire [3:0] bg_green,
    input  wire [3:0] bg_blue,

    input  wire       player_active,
    input  wire [3:0] player_red,
    input  wire [3:0] player_green,
    input  wire [3:0] player_blue,

    input  wire       enemy_active,
    input  wire [3:0] enemy_red,
    input  wire [3:0] enemy_green,
    input  wire [3:0] enemy_blue,

    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

    always @(*) begin
        if (!visible) begin
            red   = 4'd0;
            green = 4'd0;
            blue  = 4'd0;
        end
        else if (game_over) begin
            red   = 4'd15;
            green = 4'd0;
            blue  = 4'd0;
        end
        else if (player_active) begin
            red   = player_red;
            green = player_green;
            blue  = player_blue;
        end
        else if (enemy_active) begin
            red   = enemy_red;
            green = enemy_green;
            blue  = enemy_blue;
        end
        else begin
            red   = bg_red;
            green = bg_green;
            blue  = bg_blue;
        end
    end

endmodule