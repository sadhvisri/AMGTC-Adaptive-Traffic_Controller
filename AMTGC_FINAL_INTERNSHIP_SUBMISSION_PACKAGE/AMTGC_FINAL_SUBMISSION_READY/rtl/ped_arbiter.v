`timescale 1ns/1ps

module ped_arbiter (
    input  wire clk,
    input  wire reset,
    input  wire req_a,
    input  wire req_b,
    input  wire busy_a,
    input  wire busy_b,
    output reg  grant_a,
    output reg  grant_b
);

    reg last_grant; /* 0 = A was last, 1 = B was last */

    always @(*) begin
        grant_a = 1'b0;
        grant_b = 1'b0;

        if (!busy_a && !busy_b) begin
            if (req_a && req_b) begin
                if (last_grant == 1'b0)
                    grant_b = 1'b1;
                else
                    grant_a = 1'b1;
            end else if (req_a) begin
                grant_a = 1'b1;
            end else if (req_b) begin
                grant_b = 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            last_grant <= 1'b1; /* first simultaneous request goes to A */
        end else if (grant_a) begin
            last_grant <= 1'b0;
        end else if (grant_b) begin
            last_grant <= 1'b1;
        end
    end

endmodule
