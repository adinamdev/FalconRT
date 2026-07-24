module vga_controller
(
    input  wire       pixel_clk,
    input  wire       reset,

    output wire       hsync,
    output wire       vsync,
    output wire       visible,

    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y
);

//======================================================
// VGA Timing Parameters
//======================================================
localparam H_VISIBLE = 640;
localparam H_FRONT   = 16;
localparam H_SYNC    = 96;
localparam H_BACK    = 48;
localparam H_TOTAL   = 800;

localparam V_VISIBLE = 480;
localparam V_FRONT   = 10;
localparam V_SYNC    = 2;
localparam V_BACK    = 33;
localparam V_TOTAL   = 525;

//======================================================
// Pixel Counters
//======================================================
reg [9:0] horizontal_count;
reg [9:0] vertical_count;

//======================================================
// Sequential Counter Logic
//======================================================
always @(posedge pixel_clk or posedge reset)
begin
    if (reset)
    begin
        horizontal_count <= 0;
        vertical_count   <= 0;
    end
    else
    begin
        if (horizontal_count == H_TOTAL - 1)
        begin
            horizontal_count <= 0;

            if (vertical_count == V_TOTAL - 1)
                vertical_count <= 0;
            else
                vertical_count <= vertical_count + 1;
        end
        else
        begin
            horizontal_count <= horizontal_count + 1;
        end
    end
end
assign pixel_x = horizontal_count;
assign pixel_y = vertical_count;

//======================================================
// Sync Generation
//======================================================
assign hsync = ~((horizontal_count >= H_VISIBLE + H_FRONT) &&
                 (horizontal_count <  H_VISIBLE + H_FRONT + H_SYNC));

assign vsync = ~((vertical_count >= V_VISIBLE + V_FRONT) &&
                 (vertical_count <  V_VISIBLE + V_FRONT + V_SYNC));

//======================================================
// Visible Region
//======================================================
assign visible = (horizontal_count < H_VISIBLE) &&
                 (vertical_count   < V_VISIBLE);

endmodule