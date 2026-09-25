`timescale 1ns/1ps

module amtgc_top #(
    parameter COUNTER_WIDTH       = 8,
    parameter MIN_GREEN_TIME      = 4,
    parameter MAX_GREEN_TIME      = 10,
    parameter GREEN_STEP          = 1,
    parameter YELLOW_TIME         = 2,
    parameter RED_TIME            = 2,
    parameter PED_TIME            = 3,
    parameter WAVE_DELAY          = 2,
    parameter EMERGENCY_RESPONSE  = 2
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       emergency_override,
    input  wire       ped_req_a,
    input  wire       ped_req_b,
    input  wire [2:0] traffic_density_a,
    input  wire [2:0] traffic_density_b,
    output wire [2:0] light_a,
    output wire [2:0] light_b,
    output wire       ped_grant_a,
    output wire       ped_grant_b,
    output wire       ped_active_a,
    output wire       ped_active_b,
    output wire       ns_green_a,
    output wire       ns_green_b,
    output wire       emergency_a,
    output wire       emergency_b
);

    wire ped_pending_a, ped_pending_b;
    wire a_ns_green_pulse;
    reg [COUNTER_WIDTH-1:0] wave_counter;
    reg wave_waiting;
    wire b_wave_start;

    /* Green-wave scheduler. A's one-clock NS-green entry pulse starts a
       countdown. B sees wave_start before the clock edge that completes the
       requested delay, so WAVE_DELAY=2 means two rising clock edges between
       the A and B NS-green start events. */
    assign b_wave_start = wave_waiting && (wave_counter == {{(COUNTER_WIDTH-1){1'b0}},1'b1});

    always @(posedge clk) begin
        if (reset || emergency_override) begin
            wave_counter <= {COUNTER_WIDTH{1'b0}};
            wave_waiting <= 1'b0;
        end else if (a_ns_green_pulse && !wave_waiting) begin
            if (WAVE_DELAY == 0) begin
                wave_counter <= {COUNTER_WIDTH{1'b0}};
                wave_waiting <= 1'b0;
            end else begin
                wave_counter <= WAVE_DELAY - 1'b1;
                wave_waiting <= 1'b1;
            end
        end else if (wave_waiting) begin
            if (wave_counter > 0)
                wave_counter <= wave_counter - 1'b1;
            if (wave_counter == 1)
                wave_waiting <= 1'b0;
        end
    end

    ped_arbiter u_ped_arbiter (
        .clk       (clk),
        .reset     (reset),
        .req_a     (ped_req_a),
        .req_b     (ped_req_b),
        .busy_a    (ped_active_a),
        .busy_b    (ped_active_b),
        .grant_a   (ped_grant_a),
        .grant_b   (ped_grant_b)
    );

    junction_controller #(
        .COUNTER_WIDTH       (COUNTER_WIDTH),
        .MIN_GREEN_TIME      (MIN_GREEN_TIME),
        .MAX_GREEN_TIME      (MAX_GREEN_TIME),
        .GREEN_STEP          (GREEN_STEP),
        .YELLOW_TIME         (YELLOW_TIME),
        .RED_TIME            (RED_TIME),
        .PED_TIME            (PED_TIME),
        .WAVE_DELAY          (WAVE_DELAY),
        .EMERGENCY_RESPONSE  (EMERGENCY_RESPONSE)
    ) u_junction_a (
        .clk                 (clk),
        .reset               (reset),
        .emergency_override  (emergency_override),
        .start_enable        (1'b1),
        .wave_start          (1'b0),
        .ped_request         (ped_req_a),
        .ped_grant           (ped_grant_a),
        .traffic_density     (traffic_density_a),
        .light_state         (light_a),
        .ped_active          (ped_active_a),
        .ns_green_pulse      (a_ns_green_pulse),
        .ns_green_active     (ns_green_a),
        .request_pending     (ped_pending_a),
        .emergency_active    (emergency_a)
    );

    junction_controller #(
        .COUNTER_WIDTH       (COUNTER_WIDTH),
        .MIN_GREEN_TIME      (MIN_GREEN_TIME),
        .MAX_GREEN_TIME      (MAX_GREEN_TIME),
        .GREEN_STEP          (GREEN_STEP),
        .YELLOW_TIME         (YELLOW_TIME),
        .RED_TIME            (RED_TIME),
        .PED_TIME            (PED_TIME),
        .WAVE_DELAY          (WAVE_DELAY),
        .EMERGENCY_RESPONSE  (EMERGENCY_RESPONSE)
    ) u_junction_b (
        .clk                 (clk),
        .reset               (reset),
        .emergency_override  (emergency_override),
        .start_enable        (1'b0),
        .wave_start          (b_wave_start),
        .ped_request         (ped_req_b),
        .ped_grant           (ped_grant_b),
        .traffic_density     (traffic_density_b),
        .light_state         (light_b),
        .ped_active          (ped_active_b),
        .ns_green_pulse      (),
        .ns_green_active     (ns_green_b),
        .request_pending     (ped_pending_b),
        .emergency_active    (emergency_b)
    );

endmodule
