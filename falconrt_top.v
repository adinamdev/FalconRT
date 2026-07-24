module falconrt_top (
    input  wire       MAX10_CLK1_50,
    input  wire [9:0] SW,

    output wire [9:0] LEDR,

    output wire [7:0] HEX0,
    output wire [7:0] HEX1,
    output wire [7:0] HEX2,
    output wire [7:0] HEX3,
    output wire [7:0] HEX4,
    output wire [7:0] HEX5,

    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    //==================================================
    // Sprite dimensions
    //==================================================

    localparam [9:0] PLAYER_WIDTH  = 10'd128;
    localparam [9:0] PLAYER_HEIGHT = 10'd64;

    localparam [9:0] ENEMY_WIDTH   = 10'd64;
    localparam [9:0] ENEMY_HEIGHT  = 10'd32;


    //==================================================
    // Player and enemy positions
    //==================================================

    reg [9:0] player_x;
    reg [9:0] player_y;

    reg [9:0] enemy_x;
    reg [9:0] enemy_y;


    //==================================================
    // Game state
    //==================================================

    reg  game_over;
    wire collision;
    wire enemy_wrap;


    //==================================================
    // Score
    //==================================================

    reg [3:0] score_ones;
    reg [3:0] score_tens;


    //==================================================
    // VGA timing
    //==================================================

    reg        pixel_clk;

    wire       frame_tick;
    wire       visible;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;


    //==================================================
    // Existing demonstration signals
    //==================================================

    wire [7:0] player_data;
    wire       slow_clk;


    //==================================================
    // Background colors
    //==================================================

    wire [3:0] background_red;
    wire [3:0] background_green;
    wire [3:0] background_blue;


    //==================================================
    // Player sprite signals
    //==================================================

    wire [11:0] player_rom_address;

    wire        player_rom_transparent;
    wire [3:0]  player_rom_red;
    wire [3:0]  player_rom_green;
    wire [3:0]  player_rom_blue;

    wire        player_active;
    wire [3:0]  player_red;
    wire [3:0]  player_green;
    wire [3:0]  player_blue;


    //==================================================
    // Enemy sprite signals
    //==================================================

    wire [11:0] enemy_rom_address;

    wire        enemy_rom_transparent;
    wire [3:0]  enemy_rom_red;
    wire [3:0]  enemy_rom_green;
    wire [3:0]  enemy_rom_blue;

    wire        enemy_active;
    wire [3:0]  enemy_red;
    wire [3:0]  enemy_green;
    wire [3:0]  enemy_blue;


    //==================================================
    // Final VGA colors
    //==================================================

    wire [3:0] final_red;
    wire [3:0] final_green;
    wire [3:0] final_blue;


    //==================================================
    // Existing slow clock divider
    //==================================================

    clock_divider slow_clock (
        .clk_in  (MAX10_CLK1_50),
        .clk_out (slow_clk)
    );


    //==================================================
    // Existing register demonstration
    //==================================================

    falcon_register player_register (
        .data_in  (SW[7:0]),
        .clk      (slow_clk),
        .data_out (player_data)
    );


    //==================================================
    // Generate 25 MHz VGA pixel clock
    //==================================================

    always @(posedge MAX10_CLK1_50 or posedge SW[9]) begin
        if (SW[9])
            pixel_clk <= 1'b0;
        else
            pixel_clk <= ~pixel_clk;
    end


    //==================================================
    // VGA timing controller
    //==================================================

    vga_controller vga_timing (
        .pixel_clk (pixel_clk),
        .reset     (SW[9]),

        .hsync     (VGA_HS),
        .vsync     (VGA_VS),
        .visible   (visible),

        .pixel_x   (pixel_x),
        .pixel_y   (pixel_y)
    );


    //==================================================
    // One update per displayed frame
    //==================================================

    assign frame_tick =
        (pixel_x == 10'd639) &&
        (pixel_y == 10'd479);


    //==================================================
    // Enemy wrap event
    //
    // The enemy moves three pixels per frame.
    // Its position reaches 2 before respawning.
    //
    // The old score condition checked enemy_x < 2,
    // which never became true.
    //==================================================

    assign enemy_wrap =
        frame_tick &&
        !game_over &&
        (enemy_x < 10'd3);


    //==================================================
    // Bounding-box collision detection
    //==================================================

    assign collision =
        (player_x < enemy_x + ENEMY_WIDTH) &&
        (player_x + PLAYER_WIDTH > enemy_x) &&
        (player_y < enemy_y + ENEMY_HEIGHT) &&
        (player_y + PLAYER_HEIGHT > enemy_y);


    //==================================================
    // Stored game-over state
    //==================================================

    always @(posedge pixel_clk or posedge SW[9]) begin
        if (SW[9])
            game_over <= 1'b0;
        else if (frame_tick && collision)
            game_over <= 1'b1;
    end


    //==================================================
    // Score counter
    //==================================================

    always @(posedge pixel_clk or posedge SW[9]) begin
        if (SW[9]) begin
            score_ones <= 4'd0;
            score_tens <= 4'd0;
        end
        else if (enemy_wrap) begin

            if (
                (score_tens == 4'd9) &&
                (score_ones == 4'd9)
            ) begin
                score_tens <= 4'd9;
                score_ones <= 4'd9;
            end
            else if (score_ones == 4'd9) begin
                score_ones <= 4'd0;
                score_tens <= score_tens + 4'd1;
            end
            else begin
                score_ones <= score_ones + 4'd1;
            end
        end
    end


    //==================================================
    // Player movement
    //
    // SW0 = left
    // SW1 = right
    // SW2 = up
    // SW3 = down
    //==================================================

    always @(posedge pixel_clk or posedge SW[9]) begin
        if (SW[9]) begin
            player_x <= 10'd80;
            player_y <= 10'd208;
        end
        else if (frame_tick && !game_over) begin

            // Horizontal movement
            if (SW[0] && !SW[1]) begin
                if (player_x >= 10'd3)
                    player_x <= player_x - 10'd3;
                else
                    player_x <= 10'd0;
            end
            else if (SW[1] && !SW[0]) begin
                if (player_x <= 10'd509)
                    player_x <= player_x + 10'd3;
                else
                    player_x <= 10'd512;
            end

            // Vertical movement
            if (SW[2] && !SW[3]) begin
                if (player_y >= 10'd3)
                    player_y <= player_y - 10'd3;
                else
                    player_y <= 10'd0;
            end
            else if (SW[3] && !SW[2]) begin
                if (player_y <= 10'd413)
                    player_y <= player_y + 10'd3;
                else
                    player_y <= 10'd416;
            end
        end
    end


    //==================================================
    // Enemy movement
    //==================================================

    always @(posedge pixel_clk or posedge SW[9]) begin
        if (SW[9]) begin
            enemy_x <= 10'd575;
            enemy_y <= 10'd224;
        end
        else if (frame_tick && !game_over) begin

            if (enemy_x >= 10'd3) begin
                enemy_x <= enemy_x - 10'd3;
            end
            else begin
                enemy_x <= 10'd575;

                // Move enemy to a new vertical lane
                if (enemy_y >= 10'd410)
                    enemy_y <= 10'd30;
                else
                    enemy_y <= enemy_y + 10'd73;
            end
        end
    end


    //==================================================
    // Animated parallax background renderer
    //==================================================

 background_renderer background (
    .visible (visible),
    .pixel_x (pixel_x),
    .pixel_y (pixel_y),
    .red     (background_red),
    .green   (background_green),
    .blue    (background_blue)
);

    //==================================================
    // Player sprite ROM
    //==================================================

    player_sprite_rom player_sprite_memory (
        .address     (player_rom_address),

        .transparent (player_rom_transparent),
        .red         (player_rom_red),
        .green       (player_rom_green),
        .blue        (player_rom_blue)
    );


    //==================================================
    // Player sprite renderer
    //==================================================

    sprite_renderer #(
        .SPRITE_WIDTH  (64),
        .SPRITE_HEIGHT (32),
        .SCALE         (2)
    ) player_sprite_renderer (
        .visible         (visible),
        .pixel_x         (pixel_x),
        .pixel_y         (pixel_y),

        .sprite_x        (player_x),
        .sprite_y        (player_y),

        .rom_transparent (player_rom_transparent),
        .rom_red         (player_rom_red),
        .rom_green       (player_rom_green),
        .rom_blue        (player_rom_blue),

        .rom_address     (player_rom_address),

        .sprite_active   (player_active),
        .red             (player_red),
        .green           (player_green),
        .blue            (player_blue)
    );


    //==================================================
    // Enemy sprite ROM
    //==================================================

    enemy_sprite_rom enemy_sprite_memory (
        .address     (enemy_rom_address),

        .transparent (enemy_rom_transparent),
        .red         (enemy_rom_red),
        .green       (enemy_rom_green),
        .blue        (enemy_rom_blue)
    );


    //==================================================
    // Enemy sprite renderer
    //==================================================

    sprite_renderer #(
        .SPRITE_WIDTH  (64),
        .SPRITE_HEIGHT (32),
        .SCALE         (1)
    ) enemy_sprite_renderer (
        .visible         (visible),
        .pixel_x         (pixel_x),
        .pixel_y         (pixel_y),

        .sprite_x        (enemy_x),
        .sprite_y        (enemy_y),

        .rom_transparent (enemy_rom_transparent),
        .rom_red         (enemy_rom_red),
        .rom_green       (enemy_rom_green),
        .rom_blue        (enemy_rom_blue),

        .rom_address     (enemy_rom_address),

        .sprite_active   (enemy_active),
        .red             (enemy_red),
        .green           (enemy_green),
        .blue            (enemy_blue)
    );


    //==================================================
    // Layer priority
    //
    // Player
    // Enemy
    // Background
    //==================================================

    color_mapper color_mapper0 (
        .visible       (visible),
        .game_over     (game_over),

        .bg_red        (background_red),
        .bg_green      (background_green),
        .bg_blue       (background_blue),

        .player_active (player_active),
        .player_red    (player_red),
        .player_green  (player_green),
        .player_blue   (player_blue),

        .enemy_active  (enemy_active),
        .enemy_red     (enemy_red),
        .enemy_green   (enemy_green),
        .enemy_blue    (enemy_blue),

        .red           (final_red),
        .green         (final_green),
        .blue          (final_blue)
    );


    //==================================================
    // Seven-segment score displays
    //==================================================

    seven_segment_decoder score_ones_display (
        .digit    (score_ones),
        .blank    (1'b0),
        .segments (HEX0)
    );

    seven_segment_decoder score_tens_display (
        .digit    (score_tens),
        .blank    (1'b0),
        .segments (HEX1)
    );

    assign HEX2 = 8'hFF;
    assign HEX3 = 8'hFF;
    assign HEX4 = 8'hFF;
    assign HEX5 = 8'hFF;


    //==================================================
    // VGA outputs
    //==================================================

    assign VGA_R = final_red;
    assign VGA_G = final_green;
    assign VGA_B = final_blue;


    //==================================================
    // LED outputs
    //==================================================

    assign LEDR[7:0] = player_data;
    assign LEDR[8]   = collision;
    assign LEDR[9]   = game_over;

endmodule