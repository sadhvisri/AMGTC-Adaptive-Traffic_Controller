`timescale 1ns/1ps

module generic_timer #(
    parameter COUNTER_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     start,
    input  wire [COUNTER_WIDTH-1:0] count_target,
    output reg                      done
);

    reg [COUNTER_WIDTH-1:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= {COUNTER_WIDTH{1'b0}};
            done  <= 1'b0;
        end else if (!start) begin
            count <= {COUNTER_WIDTH{1'b0}};
            done  <= 1'b0;
        end else if (count_target == {COUNTER_WIDTH{1'b0}}) begin
            count <= {COUNTER_WIDTH{1'b0}};
            done  <= 1'b1;
        end else if (count >= (count_target - 1'b1)) begin
            count <= count;
            done  <= 1'b1;
        end else begin
            count <= count + 1'b1;
            done  <= 1'b0;
        end
    end

endmodule
