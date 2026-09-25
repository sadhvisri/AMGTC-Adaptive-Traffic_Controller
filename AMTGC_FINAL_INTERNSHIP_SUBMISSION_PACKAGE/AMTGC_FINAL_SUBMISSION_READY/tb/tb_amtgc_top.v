`timescale 1ns/1ps

module tb_amtgc_top;

    reg clk = 0;
    reg reset = 1;
    reg emergency_override = 0;
    reg ped_req_a = 0;
    reg ped_req_b = 0;
    reg [2:0] traffic_density_a = 0;
    reg [2:0] traffic_density_b = 0;

    wire [2:0] light_a, light_b;
    wire ped_grant_a, ped_grant_b;
    wire ped_active_a, ped_active_b;
    wire ns_green_a, ns_green_b;
    wire emergency_a, emergency_b;

    amtgc_top #(
        .COUNTER_WIDTH(8),
        .MIN_GREEN_TIME(3),
        .MAX_GREEN_TIME(6),
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
        .ped_req_a(ped_req_a),
        .ped_req_b(ped_req_b),
        .traffic_density_a(traffic_density_a),
        .traffic_density_b(traffic_density_b),
        .light_a(light_a),
        .light_b(light_b),
        .ped_grant_a(ped_grant_a),
        .ped_grant_b(ped_grant_b),
        .ped_active_a(ped_active_a),
        .ped_active_b(ped_active_b),
        .ns_green_a(ns_green_a),
        .ns_green_b(ns_green_b),
        .emergency_a(emergency_a),
        .emergency_b(emergency_b)
    );

    always #5 clk = ~clk;

    integer a_count, b_count, both_grants;
    integer i;
    integer first_a, first_b;
    integer density;
    integer wave_a_time, wave_b_time;
    integer wave_checked;
    integer wave_a_cycle, wave_b_cycle, cycle_count;

    always @(posedge clk) begin
        #1;
        cycle_count = cycle_count + 1;
        if (ns_green_a && wave_a_time < 0) begin
            wave_a_time = $time;
            wave_a_cycle = cycle_count;
        end
        if (ns_green_b && wave_b_time < 0) begin
            wave_b_time = $time;
            wave_b_cycle = cycle_count;
        end
    end

    initial begin
        a_count = 0;
        b_count = 0;
        both_grants = 0;
        first_a = -1;
        first_b = -1;
        wave_a_time = -1;
        wave_b_time = -1;
        wave_checked = 0;
        wave_a_cycle = -1;
        wave_b_cycle = -1;
        cycle_count = 0;

        #12;
        reset = 0;

        repeat(8) @(posedge clk);
        if (wave_a_time < 0 || wave_b_time < 0) begin
            $display("FAIL green-wave event was not observed");
            $stop;
        end
        if ((wave_b_cycle - wave_a_cycle) != 2) begin
            $display("FAIL green-wave offset: A=%0t B=%0t cycles A=%0d B=%0d", wave_a_time, wave_b_time, wave_a_cycle, wave_b_cycle);
            $stop;
        end
        $display("PASS green-wave offset = %0t (2 clock cycles)", wave_b_time - wave_a_time);

        /* Normal operation and density sweep */
        for (density = 0; density < 8; density = density + 1) begin
            traffic_density_a = density[2:0];
            traffic_density_b = 7-density;
            repeat(12) @(posedge clk);
        end

        /* Repeated simultaneous pedestrian requests */
        for (i = 0; i < 110; i = i + 1) begin
            @(negedge clk);
            ped_req_a = 1;
            ped_req_b = 1;
            @(posedge clk);
            #1;
            if (ped_grant_a) a_count = a_count + 1;
            if (ped_grant_b) b_count = b_count + 1;
            if (ped_grant_a && ped_grant_b) both_grants = both_grants + 1;
            @(negedge clk);
            ped_req_a = 0;
            ped_req_b = 0;
            repeat(2) @(posedge clk);
        end

        if (both_grants != 0) begin
            $display("FAIL arbiter granted both A and B simultaneously");
            $stop;
        end
        if (a_count == 0 || b_count == 0) begin
            $display("FAIL arbiter starvation: A=%0d B=%0d", a_count, b_count);
            $stop;
        end
        $display("PASS pedestrian fairness: A grants=%0d B grants=%0d", a_count, b_count);

        /* Emergency */
        @(negedge clk);
        emergency_override = 1;
        repeat(2) @(posedge clk);
        #1;
        if (light_a !== 3'd2 || light_b !== 3'd2) begin
            $display("FAIL emergency: A=%0d B=%0d", light_a, light_b);
            $stop;
        end
        $display("PASS emergency override for both junctions");

        @(negedge clk);
        emergency_override = 0;
        repeat(6) @(posedge clk);

        /* Reset during operation */
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        if (light_a !== 3'd2 || light_b !== 3'd2) begin
            $display("FAIL active reset");
            $stop;
        end
        @(negedge clk);
        reset = 0;
        repeat(10) @(posedge clk);

        $display("========================================");
        $display("AMTGC INTEGRATION TEST: PASS");
        $display("A pedestrian grants = %0d", a_count);
        $display("B pedestrian grants = %0d", b_count);
        $display("========================================");
        $stop;
    end

endmodule
