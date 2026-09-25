`timescale 1ns/1ps

module junction_controller #(
    parameter COUNTER_WIDTH      = 8,
    parameter MIN_GREEN_TIME     = 4,
    parameter MAX_GREEN_TIME     = 10,
    parameter GREEN_STEP         = 1,
    parameter YELLOW_TIME        = 2,
    parameter RED_TIME           = 2,
    parameter PED_TIME           = 3,
    parameter WAVE_DELAY         = 2,
    parameter EMERGENCY_RESPONSE = 2
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     emergency_override,
    input  wire                     start_enable,
    input  wire                     wave_start,
    input  wire                     ped_request,
    input  wire                     ped_grant,
    input  wire [2:0]               traffic_density,
    output reg  [2:0]               light_state,
    output reg                      ped_active,
    output reg                      ns_green_pulse,
    output reg                      ns_green_active,
    output reg                      request_pending,
    output reg                      emergency_active
);

    localparam [2:0] ST_NS_GREEN  = 3'd0;
    localparam [2:0] ST_NS_YELLOW = 3'd1;
    localparam [2:0] ST_ALL_RED_1 = 3'd2;
    localparam [2:0] ST_EW_GREEN  = 3'd3;
    localparam [2:0] ST_EW_YELLOW = 3'd4;
    localparam [2:0] ST_ALL_RED_2 = 3'd5;
    localparam [2:0] ST_PED       = 3'd6;

    reg [2:0] state, next_state;
    reg [COUNTER_WIDTH-1:0] phase_target;
    reg [COUNTER_WIDTH-1:0] sampled_green_time;
    reg ped_pending;
    reg started;
    reg wave_pending;

    wire timer_done;
    wire timer_start;

    assign timer_start = (state == next_state) && started &&
                         !reset && !emergency_override;

    generic_timer #(.COUNTER_WIDTH(COUNTER_WIDTH)) u_phase_timer (
        .clk          (clk),
        .reset        (reset),
        .start        (timer_start),
        .count_target (phase_target),
        .done         (timer_done)
    );

    function [COUNTER_WIDTH-1:0] calc_green_time;
        input [2:0] density;
        reg [COUNTER_WIDTH+3:0] calc;
        begin
            calc = MIN_GREEN_TIME + density * GREEN_STEP;
            if (calc > MAX_GREEN_TIME)
                calc_green_time = MAX_GREEN_TIME;
            else
                calc_green_time = calc[COUNTER_WIDTH-1:0];
        end
    endfunction

    always @(*) begin
        next_state = state;
        case (state)
            ST_NS_GREEN:  if (timer_done) next_state = ST_NS_YELLOW;
            ST_NS_YELLOW: if (timer_done) next_state = ST_ALL_RED_1;
            ST_ALL_RED_1: begin
                if (timer_done) begin
                    if (ped_pending && ped_grant) next_state = ST_PED;
                    else next_state = ST_EW_GREEN;
                end
            end
            ST_EW_GREEN:  if (timer_done) next_state = ST_EW_YELLOW;
            ST_EW_YELLOW: if (timer_done) next_state = ST_ALL_RED_2;
            ST_ALL_RED_2: begin
                if (timer_done) begin
                    if (ped_pending && ped_grant)
                        next_state = ST_PED;
                    else if (wave_pending)
                        next_state = ST_NS_GREEN;
                    else
                        next_state = ST_NS_GREEN;
                end
            end
            ST_PED: if (timer_done) next_state = ST_NS_GREEN;
            default: next_state = ST_ALL_RED_1;
        endcase

        if (emergency_override)
            next_state = ST_ALL_RED_1;
    end

    always @(*) begin
        case (state)
            ST_NS_GREEN:  phase_target = sampled_green_time;
            ST_NS_YELLOW: phase_target = YELLOW_TIME;
            ST_ALL_RED_1: phase_target = RED_TIME;
            ST_EW_GREEN:  phase_target = sampled_green_time;
            ST_EW_YELLOW: phase_target = YELLOW_TIME;
            ST_ALL_RED_2: phase_target = RED_TIME;
            ST_PED:       phase_target = PED_TIME;
            default:      phase_target = RED_TIME;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state              <= ST_ALL_RED_1;
            sampled_green_time <= MIN_GREEN_TIME;
            ped_pending        <= 1'b0;
            request_pending    <= 1'b0;
            ped_active         <= 1'b0;
            ns_green_pulse     <= 1'b0;
            ns_green_active    <= 1'b0;
            emergency_active   <= 1'b0;
            light_state        <= ST_ALL_RED_1;
            started            <= 1'b0;
            wave_pending       <= 1'b0;
        end else begin
            ns_green_pulse <= 1'b0;

            if (ped_request)
                ped_pending <= 1'b1;

            if (wave_start)
                wave_pending <= 1'b1;

            if (emergency_override) begin
                emergency_active <= 1'b1;
                state            <= ST_ALL_RED_1;
                ped_active       <= 1'b0;
                ns_green_active  <= 1'b0;
                request_pending  <= ped_pending | ped_request;
            end else if (emergency_active) begin
                emergency_active <= 1'b0;
                state            <= ST_ALL_RED_1;
                ped_active       <= 1'b0;
                ns_green_active  <= 1'b0;
            end else if (!started && (start_enable || wave_start)) begin
                started            <= 1'b1;
                state              <= ST_NS_GREEN;
                sampled_green_time <= calc_green_time(traffic_density);
                ns_green_pulse     <= 1'b1;
                ns_green_active    <= 1'b1;
                wave_pending       <= 1'b0;
            end else if (state != next_state) begin
                state <= next_state;

                if (next_state == ST_NS_GREEN) begin
                    sampled_green_time <= calc_green_time(traffic_density);
                    ns_green_pulse     <= 1'b1;
                    ns_green_active    <= 1'b1;
                    wave_pending       <= 1'b0;
                end else begin
                    ns_green_active <= 1'b0;
                end

                if (next_state == ST_PED) begin
                    ped_active  <= 1'b1;
                    ped_pending <= 1'b0;
                end else begin
                    ped_active <= 1'b0;
                end
            end

            request_pending <= ped_pending;
            light_state     <= state;
        end
    end

endmodule
