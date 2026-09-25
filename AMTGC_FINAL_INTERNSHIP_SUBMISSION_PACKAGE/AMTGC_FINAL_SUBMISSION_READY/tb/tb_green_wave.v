`timescale 1ns/1ps
module tb_green_wave;
    reg clk=0, reset=1, emergency_override=0;
    reg ped_req_a=0, ped_req_b=0;
    reg [2:0] traffic_density_a=0, traffic_density_b=0;
    wire [2:0] light_a, light_b;
    wire ped_grant_a, ped_grant_b, ped_active_a, ped_active_b;
    wire ns_green_a, ns_green_b, emergency_a, emergency_b;
    amtgc_top #(.MIN_GREEN_TIME(3),.MAX_GREEN_TIME(6),.GREEN_STEP(1),.YELLOW_TIME(1),.RED_TIME(1),.PED_TIME(2),.WAVE_DELAY(2)) dut (
        .clk(clk),.reset(reset),.emergency_override(emergency_override),
        .ped_req_a(ped_req_a),.ped_req_b(ped_req_b),
        .traffic_density_a(traffic_density_a),.traffic_density_b(traffic_density_b),
        .light_a(light_a),.light_b(light_b),.ped_grant_a(ped_grant_a),.ped_grant_b(ped_grant_b),
        .ped_active_a(ped_active_a),.ped_active_b(ped_active_b),.ns_green_a(ns_green_a),.ns_green_b(ns_green_b),
        .emergency_a(emergency_a),.emergency_b(emergency_b));
    always #5 clk=~clk;
    integer a_t=-1,b_t=-1; integer a_c=-1,b_c=-1, cyc=0;
    always @(posedge clk) begin
        #1;
        cyc=cyc+1;
        if (ns_green_a && a_t<0) begin a_t=$time; a_c=cyc; end
        if (ns_green_b && b_t<0) begin b_t=$time; b_c=cyc; end
    end
    initial begin
        #12; reset=0;
        repeat(10) @(posedge clk);
        if (a_t<0 || b_t<0) begin $display("FAIL no green-wave events"); $stop; end
        $display("A NS-green first edge = %0t ns",a_t);
        $display("B NS-green first edge = %0t ns",b_t);
        if ((b_c-a_c) != 2) begin $display("FAIL green-wave offset: A_cycle=%0d B_cycle=%0d",a_c,b_c); $stop; end
        $display("Measured offset = %0t (2 clock cycles)",b_t-a_t);
        $display("GREEN-WAVE TEST: PASS");
        $stop;
    end
endmodule
