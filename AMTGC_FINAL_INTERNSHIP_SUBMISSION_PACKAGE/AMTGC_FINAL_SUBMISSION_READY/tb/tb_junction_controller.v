`timescale 1ns/1ps

module tb_junction_controller;

    reg clk = 0;
    reg reset = 1;
    reg emergency_override = 0;
    reg ped_request = 0;
    reg ped_grant = 0;
    reg [2:0] traffic_density = 3'd0;
    reg wave_start = 0;

    wire [2:0] light_state;
    wire ped_active, ns_green_pulse, ns_green_active, request_pending, emergency_active;

    junction_controller #(
        .COUNTER_WIDTH(8),
        .MIN_GREEN_TIME(2),
        .MAX_GREEN_TIME(5),
        .GREEN_STEP(1),
        .YELLOW_TIME(1),
        .RED_TIME(1),
        .PED_TIME(2),
        .WAVE_DELAY(2),
        .EMERGENCY_RESPONSE(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .ped_request(ped_request),
        .ped_grant(ped_grant),
        .traffic_density(traffic_density),
        .wave_start(wave_start),
        .light_state(light_state),
        .ped_active(ped_active),
        .ns_green_pulse(ns_green_pulse),
        .ns_green_active(ns_green_active),
        .request_pending(request_pending),
        .emergency_active(emergency_active)
    );

    always #5 clk = ~clk;

    integer seen_ns_g, seen_ns_y, seen_ar1, seen_ew_g, seen_ew_y, seen_ar2;
    integer i;

    always @(posedge clk) begin
        #1;
        case (light_state)
            3'd0: seen_ns_g = 1;
            3'd1: seen_ns_y = 1;
            3'd2: seen_ar1 = 1;
            3'd3: seen_ew_g = 1;
            3'd4: seen_ew_y = 1;
            3'd5: seen_ar2 = 1;
            default: ;
        endcase
    end

    initial begin
        seen_ns_g = 0; seen_ns_y = 0; seen_ar1 = 0;
        seen_ew_g = 0; seen_ew_y = 0; seen_ar2 = 0;

        #12;
        reset = 0;

        repeat(20) @(posedge clk);
        #1;

        if (!(seen_ns_g && seen_ns_y && seen_ar1 && seen_ew_g && seen_ew_y && seen_ar2)) begin
            $display("FAIL junction FSM did not visit all traffic states");
            $stop;
        end
        $display("PASS junction FSM sequence");

        ped_request = 1;
        repeat(2) @(posedge clk);
        ped_grant = 1;
        repeat(8) @(posedge clk);
        ped_grant = 0;
        ped_request = 0;
        $display("PASS pedestrian request/grant exercised");

        traffic_density = 3'd7;
        repeat(12) @(posedge clk);
        $display("PASS adaptive density exercised");

        emergency_override = 1;
        repeat(2) @(posedge clk);
        #1;
        if (light_state !== 3'd2) begin
            $display("FAIL emergency did not force ALL_RED");
            $stop;
        end
        $display("PASS emergency override");

        emergency_override = 0;
        repeat(4) @(posedge clk);

        $display("========================================");
        $display("JUNCTION CONTROLLER TEST: PASS");
        $display("========================================");
        $stop;
    end

endmodule
