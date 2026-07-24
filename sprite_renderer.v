module sprite_renderer #(
    parameter SPRITE_WIDTH  = 64,
    parameter SPRITE_HEIGHT = 32,
    parameter SCALE         = 1
)(
    input  wire        visible,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,

    input  wire [9:0]  sprite_x,
    input  wire [9:0]  sprite_y,

    input  wire        rom_transparent,
    input  wire [3:0]  rom_red,
    input  wire [3:0]  rom_green,
    input  wire [3:0]  rom_blue,

    output reg  [11:0] rom_address,

    output reg         sprite_active,
    output reg  [3:0]  red,
    output reg  [3:0]  green,
    output reg  [3:0]  blue
);

    integer local_x;
    integer local_y;

    always @(*) begin

        rom_address   = 12'd0;
        sprite_active = 1'b0;

        red   = 4'd0;
        green = 4'd0;
        blue  = 4'd0;

        local_x = 0;
        local_y = 0;

        if (
            visible &&
            (pixel_x >= sprite_x) &&
            (pixel_x < sprite_x + SPRITE_WIDTH * SCALE) &&
            (pixel_y >= sprite_y) &&
            (pixel_y < sprite_y + SPRITE_HEIGHT * SCALE)
        ) begin

            local_x = (pixel_x - sprite_x) / SCALE;
            local_y = (pixel_y - sprite_y) / SCALE;

            rom_address =
                (local_y * SPRITE_WIDTH) + local_x;

            if (!rom_transparent) begin
                sprite_active = 1'b1;

                red   = rom_red;
                green = rom_green;
                blue  = rom_blue;
            end
        end
    end

endmodule