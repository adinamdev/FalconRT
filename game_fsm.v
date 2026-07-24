module game_fsm(

    input clk,
    input reset,

    input start_pressed,
    input pause_pressed,
    input collision,
    input restart_pressed,

    output reg show_start_screen,
    output reg game_active,
    output reg game_paused,
    output reg game_over

);

//======================================================
// State Encoding
//======================================================

localparam START_SCREEN = 2'b00;
localparam PLAYING      = 2'b01;
localparam PAUSED       = 2'b10;
localparam GAME_OVER    = 2'b11;


//======================================================
// State Registers
//======================================================

reg [1:0] current_state;
reg [1:0] next_state;


//======================================================
// Sequential State Register
//======================================================

always @(posedge clk or posedge reset)
begin

    if (reset)
        current_state <= START_SCREEN;

    else
        current_state <= next_state;

end


//======================================================
// Next-State Logic
//======================================================

always @(*)
begin

    // Default: stay in the current state
    next_state = current_state;

    case (current_state)

        START_SCREEN:
        begin
            if (start_pressed)
                next_state = PLAYING;
        end

        PLAYING:
        begin
            if (collision)
                next_state = GAME_OVER;

            else if (pause_pressed)
                next_state = PAUSED;
        end

        PAUSED:
        begin
            if (pause_pressed)
                next_state = PLAYING;
        end

        GAME_OVER:
        begin
            if (restart_pressed)
                next_state = START_SCREEN;
        end

        default:
        begin
            next_state = START_SCREEN;
        end

    endcase

end


//======================================================
// Moore Output Logic
//======================================================

always @(*)
begin

    // Default outputs
    show_start_screen = 0;
    game_active       = 0;
    game_paused       = 0;
    game_over         = 0;

    case (current_state)

        START_SCREEN:
            show_start_screen = 1;

        PLAYING:
            game_active = 1;

        PAUSED:
            game_paused = 1;

        GAME_OVER:
            game_over = 1;

        default:
        begin
            show_start_screen = 1;
        end

    endcase

end

endmodule 