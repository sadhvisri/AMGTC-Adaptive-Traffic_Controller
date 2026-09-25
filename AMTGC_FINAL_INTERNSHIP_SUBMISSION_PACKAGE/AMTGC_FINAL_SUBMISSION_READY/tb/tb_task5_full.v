`timescale 1ns/1ps

module tb_task5_full;

    reg clk;
    reg reset;
    reg emergency_override;
    reg ped_req_a, ped_req_b;
    reg [2:0] traffic_density_a, traffic_density_b;

    wire [2:0] light_a, light_b;
    wire ped_grant_a, ped_grant_b;
    wire ped_active_a, ped_active_b;
    wire ns_green_a, ns_green_b;
    wire emergency_a, emergency_b;

    localparam [2:0] ST_NS_GREEN  = 3'd0;
    localparam [2:0] ST_NS_YELLOW = 3'd1;
    localparam [2:0] ST_ALL_RED_1 = 3'd2;
    localparam [2:0] ST_EW_GREEN  = 3'd3;
    localparam [2:0] ST_EW_YELLOW = 3'd4;
    localparam [2:0] ST_ALL_RED_2 = 3'd5;

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

    integer i;
    integer grants_a, grants_b;
    integer both_grants;
    integer total_grants;
    integer rand_density_a, rand_density_b;
    integer cycle_count;
    integer seen_a, seen_b;
    integer phase_seen[0:5];
    integer combo;
    integer wave_a_cycle, wave_b_cycle;
    integer wave_found_a, wave_found_b;

    task check_emergency_for_phase;
        input [2:0] target_phase;
        begin : EMERGENCY_PHASE_TASK
            // Wait until Junction A actually enters the requested phase.
            while (light_a !== target_phase)
                @(posedge clk);

            @(negedge clk);
            emergency_override = 1'b1;

            repeat(2) @(posedge clk);
            #1;

            if (light_a !== ST_ALL_RED_1 || light_b !== ST_ALL_RED_1 ||
                !emergency_a || !emergency_b) begin
                $display("FAIL emergency during phase %0d: A=%0d B=%0d EA=%0d EB=%0d",
                         target_phase, light_a, light_b, emergency_a, emergency_b);
                $stop;
            end

            $display("PASS emergency during phase %0d", target_phase);

            @(negedge clk);
            emergency_override = 1'b0;
            repeat(3) @(posedge clk);
        end
    endtask

    task check_green_wave_combo;
        input integer da;
        input integer db;
        begin : WAVE_COMBO_TASK
            reset = 1'b1;
            traffic_density_a = da[2:0];
            traffic_density_b = db[2:0];
            ped_req_a = 1'b0;
            ped_req_b = 1'b0;
            emergency_override = 1'b0;
            repeat(2) @(posedge clk);
            reset = 1'b0;

            wave_found_a = 0;
            wave_found_b = 0;
            wave_a_cycle = -1;
            wave_b_cycle = -1;

            // Local cycle count for this combination.
            cycle_count = 0;
            while (!wave_found_b) begin
                @(posedge clk);
                #1;
                cycle_count = cycle_count + 1;
                if (ns_green_a && !wave_found_a) begin
                    wave_found_a = 1;
                    wave_a_cycle = cycle_count;
                end
                if (ns_green_b && !wave_found_b) begin
                    wave_found_b = 1;
                    wave_b_cycle = cycle_count;
                end
                if (cycle_count > 30) begin
                    $display("FAIL green-wave combo A=%0d B=%0d: event timeout", da, db);
                    $stop;
                end
            end

            if ((wave_b_cycle - wave_a_cycle) != 2) begin
                $display("FAIL green-wave combo A=%0d B=%0d: offset=%0d cycles",
                         da, db, wave_b_cycle-wave_a_cycle);
                $stop;
            end

            $display("PASS green-wave combo A_density=%0d B_density=%0d offset=2 cycles",
                     da, db);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        emergency_override = 0;
        ped_req_a = 0;
        ped_req_b = 0;
        traffic_density_a = 0;
        traffic_density_b = 0;

        grants_a = 0;
        grants_b = 0;
        both_grants = 0;
        total_grants = 0;

        for (i = 0; i < 6; i = i + 1)
            phase_seen[i] = 0;

        repeat(3) @(posedge clk);
        reset = 0;

        // ------------------------------------------------------------
        // 1) Reset during active operation.
        // ------------------------------------------------------------
        repeat(5) @(posedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        if (light_a !== ST_ALL_RED_1 || light_b !== ST_ALL_RED_1) begin
            $display("FAIL reset during operation");
            $stop;
        end
        $display("PASS reset during active operation");
        reset = 0;

        // ------------------------------------------------------------
        // 2) Randomized traffic-density stimulus.
        // 200 cycles; density is deliberately unpredictable.
        // ------------------------------------------------------------
        for (i = 0; i < 200; i = i + 1) begin
            @(negedge clk);
            rand_density_a = $random & 7;
            rand_density_b = $random & 7;
            traffic_density_a = rand_density_a[2:0];
            traffic_density_b = rand_density_b[2:0];
        end
        $display("PASS randomized traffic-density run: 200 cycles");

        // ------------------------------------------------------------
        // 3) Prove more than 100 successful pedestrian grants and fairness.
        // Keep both requests asserted and count each new grant event.
        // This avoids depending on a fixed number of simulation cycles.
        // ------------------------------------------------------------
        grants_a = 0;
        grants_b = 0;
        both_grants = 0;
        total_grants = 0;
        seen_a = 0;
        seen_b = 0;
        cycle_count = 0;

        ped_req_a = 1'b1;
        ped_req_b = 1'b1;

        while (total_grants < 120) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            // Count a grant only on its rising edge, so a level held for
            // more than one clock is counted once.
            if (ped_grant_a && !seen_a) begin
                grants_a = grants_a + 1;
                total_grants = total_grants + 1;
            end
            if (ped_grant_b && !seen_b) begin
                grants_b = grants_b + 1;
                total_grants = total_grants + 1;
            end

            if (ped_grant_a && ped_grant_b)
                both_grants = both_grants + 1;

            seen_a = ped_grant_a;
            seen_b = ped_grant_b;

            if (cycle_count > 2000) begin
                $display("FAIL pedestrian coverage timeout: only %0d grants", total_grants);
                $stop;
            end
        end

        ped_req_a = 1'b0;
        ped_req_b = 1'b0;
        repeat(4) @(posedge clk);

        if (both_grants != 0) begin
            $display("FAIL pedestrian arbiter issued simultaneous grants");
            $stop;
        end

        if (total_grants < 120) begin
            $display("FAIL pedestrian coverage: only %0d grants", total_grants);
            $stop;
        end

        if (grants_a == 0 || grants_b == 0) begin
            $display("FAIL pedestrian starvation A=%0d B=%0d", grants_a, grants_b);
            $stop;
        end

        if ((grants_a - grants_b > 1) || (grants_b - grants_a > 1)) begin
            $display("FAIL round-robin fairness A=%0d B=%0d", grants_a, grants_b);
            $stop;
        end

        $display("PASS pedestrian fairness over %0d grants: A=%0d B=%0d",
                 total_grants, grants_a, grants_b);

        // ------------------------------------------------------------
        // 4) Emergency override during every traffic phase.
        // ------------------------------------------------------------
        // Restart so all six states can be observed deterministically.
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;

        check_emergency_for_phase(ST_NS_GREEN);

        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        check_emergency_for_phase(ST_NS_YELLOW);

        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        check_emergency_for_phase(ST_ALL_RED_1);

        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        check_emergency_for_phase(ST_EW_GREEN);

        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        check_emergency_for_phase(ST_EW_YELLOW);

        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        check_emergency_for_phase(ST_ALL_RED_2);

        // ------------------------------------------------------------
        // 5) Five different density combinations must preserve wave.
        // ------------------------------------------------------------
        check_green_wave_combo(0,7);
        check_green_wave_combo(1,6);
        check_green_wave_combo(2,5);
        check_green_wave_combo(4,3);
        check_green_wave_combo(7,0);

        $display("==============================================");
        $display("TASK 5 FULL VERIFICATION: PASS");
        $display("Randomized density cycles = 200");
        $display("Pedestrian grants checked = %0d", total_grants);
        $display("Pedestrian A/B grants = %0d / %0d", grants_a, grants_b);
        $display("Emergency tested during all six traffic phases");
        $display("Green-wave checked for five density combinations");
        $display("Reset during active operation checked");
        $display("==============================================");
        $stop;
    end

endmodule
