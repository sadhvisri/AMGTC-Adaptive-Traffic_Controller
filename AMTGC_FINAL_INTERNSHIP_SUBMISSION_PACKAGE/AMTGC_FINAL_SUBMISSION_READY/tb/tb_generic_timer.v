`timescale 1ns/1ps

module tb_generic_timer;

    reg clk = 0;
    reg reset = 1;
    reg start = 0;
    reg [7:0] count_target = 0;
    wire done;

    generic_timer #(.COUNTER_WIDTH(8)) dut (
        .clk(clk), .reset(reset), .start(start),
        .count_target(count_target), .done(done)
    );

    always #5 clk = ~clk;

    task run_target;
        input integer target;
        integer i;
        begin
            count_target = target;
            start = 1;
            for (i = 0; i < target + 2; i = i + 1) begin
                @(posedge clk);
                #1;
                if (target > 0 && i == target-1 && !done) begin
                    $display("FAIL timer target=%0d: done missing", target);
                    $stop;
                end
            end
            start = 0;
            @(posedge clk);
            #1;
            if (target == 0 && !done) begin
                $display("FAIL timer target=0: done missing");
                $stop;
            end
            $display("PASS timer target=%0d", target);
        end
    endtask

    initial begin
        #12;
        reset = 0;
        run_target(3);
        run_target(5);
        run_target(10);

        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;
        start = 1;
        count_target = 8;
        repeat(2) @(posedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        if (done !== 1'b0) begin
            $display("FAIL timer reset while counting");
            $stop;
        end
        $display("PASS timer reset while counting");

        reset = 0;
        start = 1;
        count_target = 0;
        @(posedge clk);
        #1;
        if (!done) begin
            $display("FAIL timer count_target=0");
            $stop;
        end
        $display("PASS timer count_target=0");

        $display("========================================");
        $display("GENERIC TIMER TEST: PASS");
        $display("========================================");
        $stop;
    end

endmodule
